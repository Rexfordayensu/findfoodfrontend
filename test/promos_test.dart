import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/admin/promos_page.dart';
import 'package:findfood_app/screens/customer/cart_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status,
    headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<AuthProvider> signIn(WidgetTester tester, String role) async {
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 3, role: role, name: 'Ama');
  return auth;
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('a customer applies a promo code at checkout', (tester) async {
    final auth = await signIn(tester, 'customer');
    final cart = CartProvider()
      ..addItem(MenuItem(id: 1, name: 'Jollof', price: 5000, isAvailable: true, restaurantId: 7),
          7, 'Test Restaurant');
    Map<String, dynamic>? checked;
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/restaurants/7/delivery-quote':
          return json({'fee': 1000, 'distance_km': null, 'mode': 'flat'});
        case '/promo/check':
          checked = jsonDecode(request.body) as Map<String, dynamic>;
          return checked!['code'] == 'FIRST50'
              ? json({'valid': true, 'code': 'FIRST50', 'discount': 2500, 'message': 'Half off your food'})
              : json({'valid': false, 'discount': 0, 'message': "That promo code isn't valid."});
        case '/me/credit':
          return json({'balance': 0});
      }
      return json({}, 404);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: const MaterialApp(home: CartScreen()),
      ));
      await settle(tester);
      await tester.tap(find.byKey(const Key('promo-open')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('promo-field')), 'nope');
      await tester.tap(find.byKey(const Key('promo-apply')));
      await settle(tester);
      expect(find.text("That promo code isn't valid."), findsOneWidget);
      await tester.enterText(find.byKey(const Key('promo-field')), 'FIRST50');
      await tester.tap(find.byKey(const Key('promo-apply')));
      await settle(tester);
    }, () => client);
    expect(checked, {'code': 'FIRST50', 'restaurant_id': 7, 'subtotal': 5000,
        'delivery_fee': 1000, 'fulfillment_method': 'delivery'});
    expect(find.byKey(const Key('promo-applied')), findsOneWidget);
    expect(find.text('−GH₵ 25.00'), findsOneWidget);
    expect(find.text('GH₵ 35.00'), findsWidgets, reason: 'GH₵ 50 + 10 delivery − 25');
  });

  testWidgets('an admin creates a first-order promo code', (tester) async {
    final auth = await signIn(tester, 'admin');
    Map<String, dynamic>? created;
    var promos = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        created = jsonDecode(request.body) as Map<String, dynamic>;
        final promo = {'id': 1, 'code': 'FIRST50', 'description': '50% off your food (up to GH₵ 20.00)',
            'active': true, 'uses': 0, 'max_uses': null, 'discount_given': 0, 'first_order_only': true,
            'min_order': 0, 'ends_at': null};
        promos = [promo];
        return json(promo, 201);
      }
      return json(promos);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: PromosPage())),
      ));
      await settle(tester);
      expect(find.text('No promo codes yet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('promo-new')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('promo-code')), 'first50');
      await tester.enterText(find.byKey(const Key('promo-value')), '50');
      await tester.enterText(find.byKey(const Key('promo-cap')), '20');
      await tester.tap(find.byKey(const Key('promo-first-order')));
      await tester.tap(find.byKey(const Key('promo-save')));
      await settle(tester);
    }, () => client);
    expect(created, {'code': 'FIRST50', 'kind': 'percent', 'first_order_only': true, 'value': 50,
        'max_discount': 2000});
    expect(find.text('0 used · GH₵ 0.00 given · first orders only'), findsOneWidget);
  });
}
