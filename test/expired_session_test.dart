import 'dart:convert';

import 'package:findfood_app/router.dart';
import 'package:findfood_app/services/api_service.dart';
import 'package:findfood_app/services/otp_provider.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:findfood_app/widgets/promotion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
    PromotionCarousel.autoAdvanceEvery = null;
  });

  testWidgets('an expired session on Orders signs the user out to sign-in',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.initializeFromSecureStorage();
    await auth.login(token: 'expired', userId: 7, role: 'customer', name: 'Ama',
        email: 'ama@gmail.com', isEmailVerified: true);

    final client = MockClient((request) async {
      if (request.url.path == '/orders') {
        return http.Response(jsonEncode({'detail': 'Token has expired.'}), 401,
            headers: {'content-type': 'application/json'});
      }
      return http.Response('[]', 200, headers: {'content-type': 'application/json'});
    });

    await http.runWithClient(() async {
      final router = createAppRouter(auth);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OtpProvider()),
          ChangeNotifierProvider(create: (_) => OrderPollingProvider()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: appScaffoldMessengerKey,
        ),
      ));
      router.go('/orders');
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(auth.isLoggedIn, isFalse);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
      expect(find.textContaining('(401)'), findsNothing);
    }, () => client);
    expect(ApiService.onSessionInvalid, isNotNull);
  });
}
