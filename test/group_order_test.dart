import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/group_order_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Map<String, dynamic> groupJson({bool host = true, String state = 'open', List<Map<String, dynamic>>? myItems}) {
  final mine = myItems ?? [{'menu_item_id': 1, 'name': 'Jollof', 'price': 2500, 'image_url': null, 'quantity': 1}];
  final people = [
    {'user_id': 1, 'name': 'Ama', 'is_host': true, 'is_me': host, 'items': host ? mine : [
      {'menu_item_id': 1, 'name': 'Jollof', 'price': 2500, 'image_url': null, 'quantity': 1}],
     'subtotal': host ? mine.fold<int>(0, (s, i) => s + (i['price'] as int) * (i['quantity'] as int)) : 2500},
    {'user_id': 2, 'name': 'Kofi', 'is_host': false, 'is_me': !host,
     'items': [{'menu_item_id': 2, 'name': 'Waakye', 'price': 3000, 'image_url': null, 'quantity': 2}], 'subtotal': 6000},
  ];
  return {
    'code': 'abc123', 'link': 'https://findfood-nu.vercel.app/group/abc123', 'state': state,
    'deadline': '2026-10-17T12:00:00Z', 'seconds_left': 754,
    'restaurant': {'id': 7, 'name': "Auntie Ama's", 'address': 'Osu', 'banner_url': null},
    'host_name': 'Ama', 'is_host': host, 'people': people, 'people_count': 2, 'max_people': 10,
    'dish_count': 3, 'total': 8500, 'order_id': state == 'placed' ? 55 : null,
    'order_status': state == 'placed' ? 'preparing' : null,
  };
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  Future<CartProvider> pump(WidgetTester tester, MockClient client) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'customer', name: 'Ama');
    final cart = CartProvider();
    final router = GoRouter(initialLocation: '/group/abc123', routes: [
      GoRoute(path: '/group/:code', builder: (_, s) => GroupOrderScreen(code: s.pathParameters['code']!)),
      GoRoute(path: '/cart', builder: (_, __) => const Scaffold(body: Text('CHECKOUT PAGE'))),
      GoRoute(path: '/order-tracking/:id', builder: (_, s) => Text('TRACKING ${s.pathParameters['id']}')),
    ]);
    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: cart),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await settle(tester);
    }, () => client);
    return cart;
  }

  testWidgets('the host sees everyone\'s food and checks out into the normal checkout', (tester) async {
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path.endsWith('/lock')) return json(groupJson(state: 'locked'));
      return json(groupJson());
    });
    late CartProvider cart;
    await http.runWithClient(() async {
      cart = await pump(tester, client);
      expect(find.text("Auntie Ama's"), findsOneWidget);
      expect(find.text('Hosted by Ama (you)'), findsOneWidget);
      expect(find.text('12:34 left to add food'), findsOneWidget);
      expect(find.text('2 of 10 people'), findsOneWidget);
      expect(find.text('2× Waakye'), findsOneWidget);
      expect(find.byKey(const Key('group-share')), findsOneWidget);
      expect(find.text('Check out · GH₵ 85.00'), findsOneWidget);

      await tester.tap(find.byKey(const Key('group-checkout')));
      await settle(tester);
      expect(find.text('CHECKOUT PAGE'), findsOneWidget);
    }, () => client);
    expect(calls, contains('POST /group-orders/abc123/lock'));
    expect(cart.isGroup, isTrue);
    expect(cart.groupCode, 'abc123');
    expect(cart.groupPeople, 2);
    expect(cart.restaurantId, 7);
    expect(cart.itemCount, 3);
    expect(cart.totalAmount, 8500);
  });

  testWidgets('a friend adds their own food from the menu', (tester) async {
    Map<String, dynamic>? sent;
    final client = MockClient((request) async {
      if (request.url.path == '/restaurants/7/menu') {
        return json([
          {'id': 1, 'name': 'Jollof', 'price': 2500, 'is_available': true, 'restaurant_id': 7},
          {'id': 2, 'name': 'Waakye', 'price': 3000, 'is_available': true, 'restaurant_id': 7},
        ]);
      }
      if (request.method == 'PUT') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return json(groupJson(host: false));
      }
      return json(groupJson(host: false));
    });
    await http.runWithClient(() async {
      await pump(tester, client);
      expect(find.text('Hosted by Ama'), findsOneWidget);
      expect(find.byKey(const Key('group-checkout')), findsNothing, reason: 'only the host checks out');
      expect(find.byKey(const Key('group-member-note')), findsOneWidget);

      await tester.tap(find.byKey(const Key('group-edit-food')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('group-dish-plus-1')));
      await tester.pump();
      expect(find.text('GH₵ 85.00'), findsWidgets);
      await tester.tap(find.byKey(const Key('group-dishes-done')));
      await settle(tester);
    }, () => client);
    expect(sent!['items'], containsAll([
      {'menu_item_id': 2, 'quantity': 2},
      {'menu_item_id': 1, 'quantity': 1},
    ]));
  });

  testWidgets('once placed, everyone follows the order and the host can track it', (tester) async {
    final client = MockClient((_) async => json(groupJson(state: 'placed')));
    await http.runWithClient(() async {
      await pump(tester, client);
      expect(find.text('Being prepared'), findsOneWidget);
      expect(find.byKey(const Key('group-share')), findsNothing);
      expect(find.byKey(const Key('group-edit-food')), findsNothing);
      await tester.tap(find.byKey(const Key('group-track')));
      await settle(tester);
      expect(find.text('TRACKING 55'), findsOneWidget);
    }, () => client);
  });

  test('loading a group fills the cart, and a normal add leaves group mode', () {
    final jollof = MenuItem(id: 1, name: 'Jollof', price: 2500, isAvailable: true, restaurantId: 7);
    final cart = CartProvider()
      ..loadGroup(code: 'abc', people: 2, restaurantId: 7, restaurantName: 'Shop',
          dishes: [(jollof, 1), (jollof, 2)]);
    expect(cart.isGroup, isTrue);
    expect(cart.items.single.quantity, 3, reason: 'the same dish from two people, one line');
    cart.addItem(jollof, 7, 'Shop');
    expect(cart.isGroup, isFalse);
    expect(cart.itemCount, 1, reason: 'a fresh, normal cart');
    cart.loadGroup(code: 'abc', people: 2, restaurantId: 7, restaurantName: 'Shop', dishes: [(jollof, 1)]);
    cart.clearCart();
    expect(cart.isGroup, isFalse);
  });
}
