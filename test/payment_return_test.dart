import 'dart:convert';

import 'package:findfood_app/screens/customer/payment_return_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

Map<String, dynamic> order(int id, String status) => {
      'id': id, 'total_amount': 4500, 'status': status, 'restaurant_id': 1,
      'user_id': 7, 'restaurant_name': "Mama's Kitchen",
      'fulfillment_method': 'delivery', 'delivery_address': 'Labone',
      'items': [],
    };

Future<Widget> app(String location) async {
  FlutterSecureStorage.setMockInitialValues({});
  final auth = AuthProvider();
  await auth.login(
      token: 'token', userId: 7, role: 'customer', name: 'Ama',
      email: 'ama@example.com');
  final router = GoRouter(initialLocation: location, routes: [
    GoRoute(
      path: '/payment/callback',
      builder: (_, state) =>
          PaymentReturnScreen(reference: state.uri.queryParameters['reference']),
    ),
    GoRoute(
      path: '/order-tracking/:id',
      builder: (_, state) =>
          Scaffold(body: Text('tracking ${state.pathParameters['id']}')),
    ),
    GoRoute(path: '/orders', builder: (_, __) => const Text('orders page')),
  ]);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => CartProvider()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    PaymentReturnScreen.retryEvery = const Duration(milliseconds: 10);
    PaymentReturnScreen.maxAttempts = 3;
  });

  testWidgets('confirmed payment opens live tracking for the order',
      (tester) async {
    var checks = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/payments/PSK-1/verify') {
        checks++;
        // Paystack is still settling on the first check.
        return json({
          'reference': 'PSK-1', 'order_id': 41, 'amount': 4500,
          'customer_email': 'ama@example.com',
          'status': checks == 1 ? 'ongoing' : 'success',
        });
      }
      if (request.url.path == '/orders') return json([order(41, 'pending')]);
      return json([]);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(await app('/payment/callback?reference=PSK-1'));
      await tester.pump();
      expect(find.text('Confirming your payment'), findsOneWidget);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    }, () => client);

    expect(checks, 2);
    expect(find.text('tracking 41'), findsOneWidget);
  });

  testWidgets('abandoned checkout explains and links to orders',
      (tester) async {
    final client = MockClient((request) async => json({
          'reference': 'PSK-2', 'order_id': 42, 'amount': 4500,
          'customer_email': 'ama@example.com', 'status': 'abandoned',
        }));

    await http.runWithClient(() async {
      await tester.pumpWidget(await app('/payment/callback?reference=PSK-2'));
      await tester.pumpAndSettle();
    }, () => client);

    expect(find.text('Payment not completed'), findsOneWidget);
    expect(find.textContaining('Your order is saved'), findsOneWidget);
    await tester.tap(find.byKey(const Key('payment-return-orders')));
    await tester.pumpAndSettle();
    expect(find.text('orders page'), findsOneWidget);
  });

  testWidgets('keeps checking, then offers orders if Paystack is slow',
      (tester) async {
    final client = MockClient((request) async => json({
          'reference': 'PSK-3', 'order_id': 43, 'amount': 4500,
          'customer_email': 'ama@example.com', 'status': 'ongoing',
        }));

    await http.runWithClient(() async {
      await tester.pumpWidget(await app('/payment/callback?reference=PSK-3'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
    }, () => client);

    expect(find.text('Still confirming'), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);
  });
}
