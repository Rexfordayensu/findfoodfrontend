import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/cart_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/rider_pay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<AuthProvider> signIn(WidgetTester tester, String role) async {
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = const Size(430, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 1, role: role, name: 'Ade');
  return auth;
}

const settings = {
  'fee_mode': 'flat', 'flat_fee': 1000, 'base_fee': 600, 'per_km': 200,
  'min_fee': 800, 'max_fee': 3000, 'rider_share_percent': 100, 'payout_mode': 'weekly',
  'no_location_fee': 'max',
};

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('an admin switches to distance pricing and automatic payouts', (tester) async {
    final auth = await signIn(tester, 'admin');
    Map<String, dynamic>? sent;
    var current = Map<String, dynamic>.from(settings);
    final client = MockClient((request) async {
      if (request.method == 'PUT') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        current = sent!;
      }
      return json({'settings': current, 'defaults': settings,
          'restaurants_without_location': 2, 'history': []});
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: RiderPayPage())),
      ));
      await settle(tester);
      expect(find.byKey(const Key('delivery-settings')), findsOneWidget);
      expect(find.text('No changes'), findsOneWidget);

      await tester.tap(find.byKey(const Key('fee_mode-distance')));
      await settle(tester);
      expect(find.byKey(const Key('money-per_km')), findsOneWidget);
      expect(find.textContaining('Example: 3 km costs GH₵ 12.00'), findsOneWidget);
      expect(find.textContaining("2 restaurants haven't set their location"), findsOneWidget);
      await tester.enterText(find.byKey(const Key('money-per_km')), '2.50');
      await tester.tap(find.byKey(const Key('payout_mode-automatic')));
      await settle(tester);
      expect(find.textContaining('Confirm transfers with OTP'), findsOneWidget);
      // Customers without a shared location: maximum fee by default.
      await tester.tap(find.byKey(const Key('no_location_fee-flat')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('delivery-settings-save')));
      await settle(tester);
      expect(find.textContaining('Riders will be told'), findsOneWidget);
      await tester.tap(find.byKey(const Key('delivery-settings-confirm')));
      await settle(tester);
    }, () => client);

    expect(sent!['fee_mode'], 'distance');
    expect(sent!['per_km'], 250);
    expect(sent!['payout_mode'], 'automatic');
    expect(sent!['no_location_fee'], 'flat');
    expect(find.text('No changes'), findsOneWidget);
  });

  testWidgets('an admin pays a rider through Paystack and marks another paid', (tester) async {
    final auth = await signIn(tester, 'admin');
    final paid = <String>[];
    var riders = [
      {'id': 5, 'name': 'Kofi', 'owed': 2000, 'owed_deliveries': 2,
       'account': 'MTN ••4987', 'account_name': 'KOFI', 'active': true},
      {'id': 6, 'name': 'Ama', 'owed': 1000, 'owed_deliveries': 1,
       'account': null, 'account_name': null, 'active': false},
    ];
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        final id = int.parse(request.url.pathSegments[2]);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        paid.add('$id:${body['method']}:${body['note'] ?? ''}');
        riders = [for (final r in riders) r['id'] == id ? {...r, 'owed': 0, 'owed_deliveries': 0} : r];
        return json({'id': 1, 'status': body['method'] == 'manual' ? 'paid' : 'processing',
            'amount': 2000});
      }
      return json({'payout_mode': 'weekly',
          'total_owed': riders.fold<int>(0, (s, r) => s + (r['owed'] as int)),
          'riders': riders, 'recent': []});
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: RiderPayPage())),
      ));
      await settle(tester);
      await tester.tap(find.byKey(const Key('rider-pay-tab-payouts')));
      await settle(tester);
      expect(find.text('GH₵ 30.00'), findsOneWidget);
      expect(find.text('No payout account yet'), findsOneWidget);
      expect(find.byKey(const Key('pay-rider-6')), findsNothing, reason: 'Ama has no account');

      await tester.tap(find.byKey(const Key('pay-rider-5')));
      await settle(tester);
      expect(find.text('Pay Kofi GH₵ 20.00?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pay-rider-confirm')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('mark-paid-6')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('manual-note')), 'Cash Friday');
      await tester.tap(find.byKey(const Key('manual-confirm')));
      await settle(tester);
    }, () => client);
    expect(paid, ['5:paystack:', '6:manual:Cash Friday']);
    expect(find.text('GH₵ 0.00'), findsOneWidget);
  });

  testWidgets('a rider sees what is owed and is asked for a MoMo account', (tester) async {
    final auth = await signIn(tester, 'rider');
    final client = MockClient((request) async => json({
          'active': false, 'owed': 1500, 'owed_deliveries': 2, 'paid_total': 4000,
          'payout_mode': 'weekly', 'rider_share_percent': 90,
          'payouts': [{'amount': 4000, 'order_count': 3, 'status': 'paid',
              'paid_at': '2026-10-09T10:00:00Z'}],
        }));
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: RiderPayoutCard())),
      ));
      await settle(tester);
    }, () => client);
    expect(find.text('GH₵ 15.00'), findsOneWidget);
    expect(find.text('GH₵ 40.00'), findsOneWidget);
    expect(find.textContaining('You earn 90% of each delivery fee, paid weekly'), findsOneWidget);
    expect(find.byKey(const Key('rider-add-payout')), findsOneWidget);
    expect(find.text('9 Oct'), findsOneWidget);
  });

  testWidgets('checkout adds the delivery fee to the total, not for pickup', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cart = CartProvider()
      ..addItem(MenuItem(id: 1, name: 'Jollof', price: 5000, isAvailable: true, restaurantId: 7),
          7, 'Test Restaurant');
    final client = MockClient((request) async {
      if (request.url.path == '/restaurants/7/delivery-quote') {
        return json({'fee': 1200, 'distance_km': null, 'mode': 'flat'});
      }
      return http.Response('{}', 404);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: CartScreen()),
      ));
      await settle(tester);
      final fee = find.byKey(const Key('checkout-delivery-fee'));
      await tester.scrollUntilVisible(fee, 200, scrollable: find.byType(Scrollable).first);
      expect(find.descendant(of: fee, matching: find.text('GH₵ 12.00')), findsOneWidget);
      expect(find.text('GH₵ 62.00'), findsWidgets);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await settle(tester);
      await tester.tap(find.text('Pickup'));
      await settle(tester);
      await tester.scrollUntilVisible(fee, 200, scrollable: find.byType(Scrollable).first);
      expect(find.descendant(of: fee, matching: find.text('Free')), findsOneWidget);
      expect(find.text('GH₵ 62.00'), findsNothing);
    }, () => client);
  });

  testWidgets('without a location, checkout explains the higher distance fee', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cart = CartProvider()
      ..addItem(MenuItem(id: 1, name: 'Jollof', price: 5000, isAvailable: true, restaurantId: 7),
          7, 'Test Restaurant');
    final client = MockClient((request) async => request.url.path == '/restaurants/7/delivery-quote'
        ? json({'fee': 3000, 'distance_km': null, 'mode': 'no_location'})
        : http.Response('{}', 404));
    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: CartScreen()),
      ));
      await settle(tester);
      final hint = find.byKey(const Key('checkout-location-hint'));
      await tester.scrollUntilVisible(hint, 200, scrollable: find.byType(Scrollable).first);
      expect(hint, findsOneWidget);
    }, () => client);
  });

  test('restaurant cards show the delivery price', () {
    Restaurant card(int? fee, {bool varies = false}) => Restaurant(
        id: 1, name: 'A', cuisineType: 'Local', address: 'Osu', email: 'a@b.c',
        isActive: true, isApproved: true, ownerId: 1,
        deliveryFeeFrom: fee, deliveryFeeVaries: varies);
    expect(card(0).deliveryLabel, 'Free delivery');
    expect(card(1000).deliveryLabel, 'GH₵ 10.00 delivery');
    expect(card(800, varies: true).deliveryLabel, 'Delivery from GH₵ 8.00');
    expect(card(null).deliveryLabel, isNull);
  });
}
