import 'dart:convert';

import 'package:findfood_app/router.dart';
import 'package:findfood_app/screens/auth/google_oauth_flow.dart';
import 'package:findfood_app/services/otp_provider.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:findfood_app/widgets/promotion_card.dart';
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
    PromotionCarousel.autoAdvanceEvery = null;
  });

  test('role names from older servers are cleaned up', () {
    expect(normalizeRole('UserRole.CUSTOMER'), 'customer');
    expect(normalizeRole('userrole.rider'), 'rider');
    expect(normalizeRole(' Restaurant '), 'restaurant');
  });

  testWidgets('after Google sign-in the customer can use every tab',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.initializeFromSecureStorage();
    final navigatorKey = GlobalKey<NavigatorState>();
    late GoRouter router;

    final client = MockClient((request) async {
      if (request.url.path == '/auth/google/exchange') {
        // What the server used to send for Google users.
        return json({
          'access_token': 'jwt', 'token_type': 'bearer', 'user_id': 7,
          'role': 'UserRole.CUSTOMER', 'name': 'Ama', 'email': 'ama@gmail.com',
        });
      }
      return json([]);
    });

    await http.runWithClient(() async {
      router = createAppRouter(auth, navigatorKey: navigatorKey);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OtpProvider()),
          ChangeNotifierProvider(create: (_) => OrderPollingProvider()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pump();

      await GoogleOAuthFlowService.handleCallbackUri(
        Uri.parse('https://findfood-nu.vercel.app/auth/callback'
            '?code=abc&status=success&return_to=%2F'),
        authProvider: auth,
        navigatorKey: navigatorKey,
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(auth.role, 'customer');
      expect(auth.isCustomer, isTrue);
      expect(auth.isEmailVerified, isTrue);

      // Customer pages must open, not bounce back home.
      for (final page in ['/orders', '/profile', '/cart']) {
        router.go(page);
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(router.routerDelegate.currentConfiguration.uri.path, page);
      }
    }, () => client);
  });
}
