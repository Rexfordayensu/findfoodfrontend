import 'dart:convert';

import 'package:findfood_app/screens/admin/orders_page.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
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

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
  });

  testWidgets('an admin sees a stuck order and cancels it with credit', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'admin', name: 'Rexford');
    Map<String, dynamic>? cancelled;
    var status = 'pending';
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/admin/orders/board') {
        return json({
          'counts': {'attention': 1, 'active': 3},
          'orders': [
            {'id': 41, 'status': status, 'fulfillment_method': 'delivery', 'total_amount': 6000,
             'restaurant_name': "Mama's Kitchen", 'customer_name': 'Ama', 'rider_name': null,
             'created_at': DateTime.now().toUtc().toIso8601String(),
             'attention': {'reason': "The restaurant hasn't started it", 'minutes': 14, 'severity': 'warning'}},
          ],
        });
      }
      if (path == '/admin/orders/41/cancel') {
        cancelled = jsonDecode(request.body) as Map<String, dynamic>;
        status = 'cancelled';
        return json({'id': 41, 'status': 'cancelled'});
      }
      return json({
        'id': 41, 'status': status, 'fulfillment_method': 'delivery', 'total_amount': 6000,
        'amount_paid': 6000, 'delivery_fee': 1000, 'restaurant_name': "Mama's Kitchen",
        'attention': status == 'pending' ? {'reason': "The restaurant hasn't started it", 'minutes': 14} : null,
        'customer': {'name': 'Ama', 'phone': '0241234567'},
        'restaurant': {'name': "Mama's Kitchen", 'phone': null, 'address': 'Osu'},
        'rider': null, 'delivery_address': 'Labone',
        'items': [{'name': 'Jollof', 'quantity': 2, 'price': 2500}],
        'payments': [{'provider': 'paystack', 'reference': 'R1', 'amount': 6000, 'status': 'success'}],
        'timeline': [{'label': 'Ordered', 'at': DateTime.now().toUtc().toIso8601String()}],
        'admin_history': [],
        'can': {'cancel': status == 'pending', 'offer_rider': true, 'release_rider': false, 'refund': true},
      });
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: AdminOrdersPage())),
      ));
      await settle(tester);
      expect(find.text('Needs attention (1)'), findsOneWidget);
      expect(find.text("The restaurant hasn't started it · 14 min"), findsOneWidget);

      await tester.tap(find.byKey(const Key('desk-order-41')));
      await settle(tester);
      expect(find.byKey(const Key('call-customer')), findsOneWidget);
      expect(find.byKey(const Key('call-restaurant')), findsNothing, reason: 'no phone saved');
      await tester.tap(find.byKey(const Key('desk-cancel')));
      await settle(tester);
      await tester.tap(find.text('Restaurant closed'));
      await tester.tap(find.byKey(const Key('cancel-refund-credit')));
      await tester.tap(find.byKey(const Key('cancel-confirm')));
      await settle(tester);
    }, () => client);
    expect(cancelled, {'reason': 'Restaurant closed', 'refund': 'credit'});
  });
}
