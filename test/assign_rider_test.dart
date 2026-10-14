import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/assign_rider.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

Order order({String? offered, DateTime? expires}) => Order.fromJson({
      'id': 12, 'total_amount': 4500, 'status': 'preparing', 'restaurant_id': 3,
      'user_id': 7, 'fulfillment_method': 'delivery', 'delivery_address': 'Labone',
      'offered_rider_name': offered,
      'offer_expires_at': expires?.toUtc().toIso8601String(),
    });

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

  Future<void> pump(WidgetTester tester, String role, Widget child) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: role, name: 'Esi');
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    ));
    await settle(tester);
  }

  testWidgets('a restaurant picks an available rider and sends a request', (tester) async {
    Map<String, dynamic>? sent;
    var changed = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/orders/12/riders') {
        return json({
          'offer': null,
          'riders': [
            {'id': 5, 'name': 'Kofi', 'phone': '024 123 4567', 'online': true,
             'active_deliveries': 0, 'eligible': true, 'reason': null},
            {'id': 6, 'name': 'Yaw', 'online': true, 'active_deliveries': 1,
             'eligible': true, 'reason': null},
            {'id': 7, 'name': 'Abena', 'online': false, 'active_deliveries': 0,
             'eligible': false, 'reason': 'Offline'},
          ],
        });
      }
      if (request.url.path == '/orders/12/rider-offer' && request.method == 'POST') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return json({'id': 1}, 201);
      }
      return json({});
    });
    await http.runWithClient(() async {
      await pump(tester, 'restaurant',
          RiderAssignmentRow(order: order(), onChanged: () async => changed++));
      await tester.tap(find.byKey(const Key('assign-rider-12')));
      await settle(tester);

      expect(find.text('Kofi'), findsOneWidget);
      expect(find.text('Available now'), findsOneWidget);
      expect(find.text('024 123 4567'), findsOneWidget);
      expect(find.text('Available · on 1 delivery'), findsOneWidget);
      expect(find.text('Abena'), findsNothing, reason: 'unavailable riders are tucked away');
      await tester.tap(find.byKey(const Key('assign-rider-show-unavailable')));
      await settle(tester);
      expect(find.text('Offline'), findsOneWidget);
      // Tapping an unavailable rider does nothing.
      await tester.tap(find.byKey(const Key('rider-option-7')));
      await settle(tester);
      expect(sent, isNull);

      await tester.tap(find.byKey(const Key('rider-option-5')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('assign-rider-confirm')));
      await settle(tester);
    }, () => client);
    expect(sent, {'rider_id': 5});
    expect(changed, 1);
  });

  testWidgets('while waiting, the restaurant sees time left and can cancel', (tester) async {
    var withdrawn = false;
    final client = MockClient((request) async {
      if (request.method == 'DELETE' && request.url.path == '/orders/12/rider-offer') {
        withdrawn = true;
        return json({'withdrawn': true});
      }
      return json({});
    });
    await http.runWithClient(() async {
      await pump(tester, 'restaurant', RiderAssignmentRow(
          order: order(offered: 'Kofi', expires: DateTime.now().add(const Duration(seconds: 150))),
          onChanged: () async {}));
      expect(find.textContaining('Waiting for Kofi to accept · 2:'), findsOneWidget);
      await tester.tap(find.byKey(const Key('rider-offer-cancel-12')));
      await settle(tester);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
    expect(withdrawn, isTrue);
  });

  testWidgets('a rider accepts a request from the restaurant', (tester) async {
    var offers = [
      {'id': 9, 'order_id': 12, 'restaurant_name': "Mama's Kitchen",
       'restaurant_address': 'Osu', 'total_amount': 4500, 'seconds_left': 170,
       'items': [{'name': 'Jollof', 'quantity': 1}]},
    ];
    final calls = <String>[];
    var accepted = 0;
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/deliveries/offers') return json(offers);
      if (request.url.path == '/deliveries/offers/9/accept') {
        offers = [];
        return json({
          'id': 12, 'total_amount': 4500, 'status': 'preparing', 'restaurant_id': 3,
          'user_id': 7, 'rider_id': 1, 'pickup_code': '7302'});
      }
      return json({});
    });
    await http.runWithClient(() async {
      await pump(tester, 'rider', RiderOffersPanel(onAccepted: () => accepted++));
      expect(find.text("Mama's Kitchen asked you"), findsOneWidget);
      expect(find.text('Order #12 · 1× Jollof'), findsOneWidget);
      expect(find.textContaining('left to answer'), findsOneWidget);
      await tester.tap(find.byKey(const Key('rider-offer-accept-9')));
      await settle(tester);
      expect(find.byKey(const Key('rider-offers')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
    expect(calls, contains('POST /deliveries/offers/9/accept'));
    expect(accepted, 1);
  });

  testWidgets('a rider declines a request', (tester) async {
    var offers = [
      {'id': 9, 'order_id': 12, 'restaurant_name': "Mama's Kitchen", 'seconds_left': 100,
       'items': []},
    ];
    var declined = false;
    final client = MockClient((request) async {
      if (request.url.path == '/deliveries/offers') return json(offers);
      if (request.url.path == '/deliveries/offers/9/decline') {
        declined = true;
        offers = [];
        return json({'declined': true});
      }
      return json({});
    });
    await http.runWithClient(() async {
      await pump(tester, 'rider', const RiderOffersPanel());
      await tester.tap(find.byKey(const Key('rider-offer-decline-9')));
      await settle(tester);
      expect(find.byKey(const Key('rider-offers')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
    expect(declined, isTrue);
  });

  test('countdowns read as m:ss', () {
    expect(countdown(const Duration(seconds: 179)), '2:59');
    expect(countdown(const Duration(seconds: 5)), '0:05');
    expect(countdown(Duration.zero), '0:00');
  });
}
