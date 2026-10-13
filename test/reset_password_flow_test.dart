import 'dart:convert';

import 'package:findfood_app/router.dart';
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

const token = 'Zx9_resetTokenFromTheEmail_0123456789';

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
    PromotionCarousel.autoAdvanceEvery = null;
  });

  for (final signedIn in [false, true]) {
    testWidgets(
        'the emailed reset link changes the password '
        '(${signedIn ? 'already signed in' : 'signed out'})', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FlutterSecureStorage.setMockInitialValues({});
      final auth = AuthProvider();
      await auth.initializeFromSecureStorage();
      if (signedIn) {
        await auth.login(
            token: 'session', userId: 7, role: 'customer', name: 'Ama',
            email: 'ama@gmail.com', isEmailVerified: true);
      }
      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        if (request.url.path == '/auth/reset-password') {
          final body = jsonDecode(request.body);
          expect(body, {'token': token, 'new_password': 'NewPass123'});
          return http.Response(
              jsonEncode({'message': 'Password reset successfully. You can now sign in.'}),
              200, headers: {'content-type': 'application/json'});
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
          child: MaterialApp.router(routerConfig: router),
        ));
        router.go('/reset-password?token=$token');
        await tester.pumpAndSettle();
        expect(find.text('Create a new password'), findsOneWidget);

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'NewPass123');
        await tester.enterText(fields.at(1), 'NewPass123');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset password'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Password reset successfully! Please log in.'), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(calls, contains('POST /auth/reset-password'));
        // Signed-out users land on sign in; signed-in users are taken home.
        expect(router.routerDelegate.currentConfiguration.uri.path,
            signedIn ? isNot('/reset-password') : '/login');
      }, () => client);
    });
  }
}
