import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/food_feed_screen.dart';
import 'package:findfood_app/services/local_customer_store.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
  });

  Future<CartProvider> pumpFeed(WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 7, role: 'customer', name: 'Ama');
    final cart = CartProvider();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const FoodFeedScreen()),
      GoRoute(path: '/cart', builder: (_, __) => const Scaffold(body: Text('Basket page'))),
    ]);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: cart),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return cart;
  }

  final client = MockClient((request) async => request.url.path == '/restaurants'
      ? json([
          {'id': 3, 'name': "Mama's Kitchen", 'cuisine_type': 'Ghanaian', 'address': 'Osu',
           'email': 'm@example.com', 'is_approved': true, 'owner_id': 9},
        ])
      : json([]));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Search in the bottom bar opens the search bar at the top', (tester) async {
    await http.runWithClient(() async {
      await pumpFeed(tester);
      expect(find.byKey(const Key('search-title')), findsNothing);
      expect(find.textContaining('Ama'), findsWidgets, reason: 'the greeting');

      await tester.tap(find.text('Search'));
      await settle(tester);
      expect(find.byKey(const Key('search-title')), findsOneWidget);
      expect(find.byKey(const Key('search-cancel')), findsOneWidget);
      final field = tester.widget<TextField>(find.byKey(const Key('feed-search')));
      expect(field.focusNode!.hasFocus, isTrue, reason: 'the keyboard opens');
      expect(find.byKey(const Key('search-suggestions')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('feed-search')), 'jollof');
      await settle(tester);
      await tester.tap(find.byKey(const Key('search-cancel')));
      await settle(tester);
      expect(find.byKey(const Key('search-title')), findsNothing);
      expect(find.byKey(const Key('search-cancel')), findsNothing);
      expect(tester.widget<TextField>(find.byKey(const Key('feed-search'))).controller!.text, '');
      await tester.pumpWidget(const SizedBox());
    }, () => client);
  });

  testWidgets('tapping the search bar itself also opens search; Home closes it',
      (tester) async {
    await http.runWithClient(() async {
      await pumpFeed(tester);
      await tester.tap(find.byKey(const Key('feed-search')));
      await settle(tester);
      expect(find.byKey(const Key('search-title')), findsOneWidget);
      await tester.tap(find.text('Home'));
      await settle(tester);
      expect(find.byKey(const Key('search-title')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
  });

  testWidgets('the basket button shows how many items are in it', (tester) async {
    await http.runWithClient(() async {
      final cart = await pumpFeed(tester);
      expect(find.byKey(const Key('nav-basket-count')), findsNothing);
      final dish = MenuItem(
          id: 1, name: 'Waakye', price: 3500, restaurantId: 3, isAvailable: true);
      cart.addItem(dish, 3, "Mama's Kitchen");
      cart.addItem(dish, 3, "Mama's Kitchen");
      await settle(tester);
      expect((tester.widget<Text>(find.byKey(const Key('nav-basket-count')))).data, '2');
      await tester.tap(find.byKey(const Key('nav-basket')));
      await settle(tester);
      expect(find.text('Basket page'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
  });

  test('half-typed searches are tidied away', () {
    expect(LocalCustomerStore.tidySearches(['profil', 'profile', 'profi', 'prof', 'pro', 'pr']),
        ['profile']);
    expect(LocalCustomerStore.tidySearches(['waakye', 'Jollof', 'jol', 'w', 'pizza']),
        ['waakye', 'Jollof', 'pizza']);
  });

  testWidgets('only real searches are remembered, and only shown while searching',
      (tester) async {
    await http.runWithClient(() async {
      await pumpFeed(tester);
      await tester.tap(find.text('Search'));
      await settle(tester);
      // Typing letter by letter saves nothing.
      for (final partial in ['w', 'wa', 'waa', 'waakye']) {
        await tester.enterText(find.byKey(const Key('feed-search')), partial);
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('search-cancel')));
      await settle(tester);
      expect(await LocalCustomerStore.recentSearches(), isEmpty);

      // Pressing search does.
      await tester.tap(find.text('Search'));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('feed-search')), 'waakye');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(await LocalCustomerStore.recentSearches(), ['waakye']);

      await tester.tap(find.byKey(const Key('search-cancel')));
      await settle(tester);
      expect(find.byKey(const Key('search-recent')), findsNothing,
          reason: 'not on the home screen');
      await tester.tap(find.text('Search'));
      await settle(tester);
      expect(find.byKey(const Key('search-recent')), findsOneWidget);
      await tester.tap(find.byKey(const Key('search-clear-recent')));
      await settle(tester);
      expect(find.byKey(const Key('search-recent')), findsNothing);
      expect(await LocalCustomerStore.recentSearches(), isEmpty);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
  });
}
