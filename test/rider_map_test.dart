import 'dart:convert';

import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/map_pins.dart';
import 'package:findfood_app/widgets/rider_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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

Map<String, dynamic> tracking({
  Map<String, dynamic>? rider = const {'lat': 5.59, 'lng': -0.18, 'live': true, 'age_seconds': 8},
  String leg = 'to_customer',
  bool active = true,
}) =>
    {
      'order_id': 7,
      'status': active ? 'out_for_delivery' : 'delivered',
      'restaurant': {'lat': 5.56, 'lng': -0.2, 'name': 'Auntie Ama'},
      'destination': {'lat': 5.6, 'lng': -0.17, 'address': 'Osu'},
      'rider': active ? rider : null,
      'rider_name': active ? 'Kofi' : null,
      'tracking': active,
      'leg': leg,
    };

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  Future<void> pump(WidgetTester tester, Widget child, {String role = 'customer'}) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 3, role: role, name: 'Ama');
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    ));
    await settle(tester);
  }

  String status(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('rider-map-status-7'))).data!;

  test('travel estimates use road distance at city speed', () {
    final km = travelKm(5.56, -0.2, 5.6, -0.17);
    expect(km, closeTo(7.2, 0.3));
    expect(travelMinutes(km), 22);
    expect(travelMinutes(0.01), 1);
  });

  testWidgets('the customer sees how far away their rider is', (tester) async {
    final client = MockClient((request) async {
      expect(request.url.path, '/orders/7/tracking');
      return json(tracking());
    });
    await http.runWithClient(() async {
      await pump(tester, const RiderMapCard(orderId: 7, viewer: MapViewer.customer));
      expect(status(tester), startsWith('Kofi is about '));
      expect(status(tester), contains('min away'));
      expect(find.text('Map © OpenFreeMap · © OpenStreetMap contributors'), findsOneWidget);
    }, () => client);
  });

  testWidgets('the restaurant sees the rider coming to collect', (tester) async {
    final client = MockClient((_) async => json(tracking(leg: 'to_restaurant')));
    await http.runWithClient(() async {
      await pump(tester, const RiderMapCard(orderId: 7, viewer: MapViewer.restaurant), role: 'restaurant');
      expect(status(tester), allOf(startsWith('Kofi is about'), endsWith('from you.')));
    }, () => client);
  });

  testWidgets('an old position shows as last seen, a missing one explains why', (tester) async {
    var body = tracking(rider: {'lat': 5.59, 'lng': -0.18, 'live': false, 'age_seconds': 300});
    final client = MockClient((_) async => json(body));
    await http.runWithClient(() async {
      await pump(tester, const RiderMapCard(orderId: 7, viewer: MapViewer.customer));
      expect(status(tester), 'Kofi was last seen 5 min ago.');
    }, () => client);

    body = tracking(rider: null);
    await http.runWithClient(() async {
      await pump(tester, const RiderMapCard(key: Key('again'), orderId: 7, viewer: MapViewer.customer));
      expect(status(tester), "Waiting for Kofi's location. It shows once their FindFood app is open.");
    }, () => client);
  });

  testWidgets('the full map opens and ends with the delivery', (tester) async {
    final client = MockClient((_) async => json(tracking(active: false)));
    await http.runWithClient(() async {
      await pump(tester, const RiderMapCard(orderId: 7, viewer: MapViewer.customer));
      expect(status(tester), 'Live tracking has ended for this order.');
      await tester.tap(find.byKey(const Key('rider-map-open-7')));
      await settle(tester);
      expect(find.text('Order #7 · live map'), findsOneWidget);
      expect(find.byKey(const Key('rider-map-recenter')), findsOneWidget);
    }, () => client);
  });

  testWidgets('admins see every rider on the road', (tester) async {
    final client = MockClient((request) async {
      expect(request.url.path, '/admin/riders/live');
      return json([
        {'rider_id': 5, 'name': 'Kofi', 'lat': 5.59, 'lng': -0.18, 'live': true, 'age_seconds': 4,
         'orders': [{'id': 7, 'status': 'out_for_delivery', 'restaurant': 'Auntie Ama'}]},
        {'rider_id': 6, 'name': 'Yaw', 'lat': 5.61, 'lng': -0.2, 'live': false, 'age_seconds': 240,
         'orders': [{'id': 9, 'status': 'ready', 'restaurant': 'Chop Bar'}]},
      ]);
    });
    await http.runWithClient(() async {
      FlutterSecureStorage.setMockInitialValues({});
      final auth = AuthProvider();
      await auth.login(token: 't', userId: 1, role: 'admin', name: 'Rex');
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: auth, child: const MaterialApp(home: AdminLiveMapScreen())));
      await settle(tester);
      expect(find.text('2 riders on the road'), findsOneWidget);
      expect(find.text('#7 · Auntie Ama'), findsOneWidget);
      expect(find.text('#9 · Chop Bar  ·  last seen 4 min ago'), findsOneWidget);
      await tester.tap(find.byKey(const Key('live-rider-6')));
      await settle(tester);
    }, () => client);
  });
}
