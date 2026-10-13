import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/order_tracking_screen.dart';
import 'package:findfood_app/screens/restaurants/restaurant_dashboard.dart';
import 'package:findfood_app/screens/rider/rider_dashboard.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

Map<String, dynamic> orderJson(String status,
        {String method = 'delivery',
        int? riderId,
        String? deliveryCode,
        String? pickupCode}) =>
    {
      'id': 4, 'total_amount': 4000, 'status': status, 'restaurant_id': 1,
      'user_id': 1, 'restaurant_name': "Mama's Kitchen",
      'fulfillment_method': method, 'delivery_address': 'Labone',
      'rider_id': riderId, 'rider_name': riderId == null ? null : 'Kofi',
      'delivery_code': deliveryCode, 'pickup_code': pickupCode,
      'created_at': DateTime.now().toUtc().toIso8601String(), 'items': [],
    };

Future<AuthProvider> signedIn(String role) async {
  FlutterSecureStorage.setMockInitialValues({});
  final auth = AuthProvider();
  await auth.login(
      token: 't', userId: 1, role: role, name: 'Test',
      email: 'test@example.com', isRestaurantApproved: true);
  return auth;
}

/// Lets a second of frames run; screens with spinners never "settle".
Future<void> frames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> show(WidgetTester tester, AuthProvider auth, Widget home) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const SizedBox()); // start each screen fresh
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(home: home),
  ));
  await frames(tester);
}

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
  });

  testWidgets('customer sees their delivery code only while it is needed',
      (tester) async {
    final auth = await signedIn('customer');
    await http.runWithClient(() async {
      await show(tester, auth, OrderTrackingScreen(
          order: Order.fromJson(orderJson('preparing', riderId: 2,
              deliveryCode: '4821'))));
    }, () => MockClient((_) async => json([])));

    expect(find.text('Delivery code'), findsOneWidget);
    for (final digit in ['4', '8', '2', '1']) {
      expect(find.text(digit), findsOneWidget);
    }
    expect(find.textContaining('Give this code to your rider'), findsOneWidget);

    await http.runWithClient(() async {
      await show(tester, auth, OrderTrackingScreen(
          order: Order.fromJson(orderJson('delivered', riderId: 2,
              deliveryCode: '4821'))));
    }, () => MockClient((_) async => json([])));
    expect(find.text('Delivery code'), findsNothing);
  });

  testWidgets('restaurant hands over to the rider only with the right code',
      (tester) async {
    final auth = await signedIn('restaurant');
    final submitted = <String>[];
    var status = 'ready';
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/orders/4/handover') {
        final code = jsonDecode(request.body)['code'] as String;
        submitted.add(code);
        if (code != '7302') {
          return json({'detail': 'That code is not right. 4 attempts left.'}, 400);
        }
        status = 'out_for_delivery';
        return json(orderJson(status, riderId: 2));
      }
      if (path == '/orders') return json([orderJson(status, riderId: 2)]);
      if (path == '/restaurants/mine') {
        return json({'id': 1, 'name': "Mama's Kitchen", 'cuisine_type': 'Local',
          'address': 'Osu', 'email': 'k@example.com', 'is_active': true,
          'is_approved': true, 'is_open': true});
      }
      return json([]);
    });

    await http.runWithClient(() async {
      await show(tester, auth, const RestaurantDashboard(token: 't'));
      expect(find.text('Rider: Kofi'), findsOneWidget);
      await tester.tap(find.text('Hand over to rider'));
      await frames(tester);
      expect(find.text("Enter Kofi's code"), findsOneWidget);

      await tester.enterText(find.byKey(const Key('handoff-code-input')), '1111');
      await frames(tester);
      expect(find.text('That code is not right. 4 attempts left.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('handoff-code-input')), '7302');
      await frames(tester);
    }, () => client);

    expect(submitted, ['1111', '7302']);
    expect(find.text("Enter Kofi's code"), findsNothing);
    expect(find.text('On the way with Kofi'), findsOneWidget);
  });

  testWidgets('rider shows the pickup code, then completes with the customer\'s',
      (tester) async {
    final auth = await signedIn('rider');
    var status = 'ready';
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/orders/4/deliver') {
        final code = jsonDecode(request.body)['code'] as String;
        if (code != '4821') {
          return json({'detail': 'That code is not right. 4 attempts left.'}, 400);
        }
        status = 'delivered';
        return json(orderJson(status, riderId: 1));
      }
      if (path == '/orders') {
        return json([orderJson(status, riderId: 1,
            pickupCode: status == 'ready' ? '7302' : null)]);
      }
      return json([]);
    });

    await http.runWithClient(() async {
      await show(tester, auth, const RiderDashboard());
      await tester.tap(find.text('My Deliveries'));
      await frames(tester);
      expect(find.byKey(const Key('rider-pickup-code-4')), findsOneWidget);
      expect(find.textContaining('The food is ready'), findsOneWidget);

      // The restaurant enters the code; the rider's list refreshes.
      status = 'out_for_delivery';
      await tester.fling(find.byType(ListView).last, const Offset(0, 400), 1000);
      await frames(tester);
      expect(find.byKey(const Key('rider-pickup-code-4')), findsNothing);

      await tester.tap(find.byKey(const Key('rider-complete-4')));
      await frames(tester);
      await tester.enterText(find.byKey(const Key('handoff-code-input')), '4821');
      await frames(tester);
    }, () => client);

    expect(find.text('Delivery complete. Nice work!'), findsOneWidget);
    expect(find.byKey(const Key('rider-complete-4')), findsNothing);
  });
}
