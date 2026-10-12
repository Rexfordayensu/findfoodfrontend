import 'dart:async';
import 'dart:convert';

import 'package:findfood_app/services/api_service.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/account_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

Future<AuthProvider> signedIn() async {
  FlutterSecureStorage.setMockInitialValues({});
  final auth = AuthProvider();
  await auth.login(
      token: 'token',
      userId: 7,
      role: 'rider',
      name: 'Kofi',
      email: 'old@example.com');
  return auth;
}

Widget app(AuthProvider auth) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: appScaffoldMessengerKey,
        home: const Scaffold(
          body: SingleChildScrollView(
              child: AccountSettingsSection(role: 'rider')),
        ),
      ),
    );

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('email change sends a code and applies the verified address',
      (tester) async {
    final auth = await signedIn();
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add('${request.method} ${request.url.path} ${request.body}');
      switch (request.url.path) {
        case '/auth/me':
          return json({
            'id': 7,
            'name': 'Kofi',
            'email': 'old@example.com',
            'role': 'rider',
            'provider': 'local',
            'pending_email': null
          });
        case '/auth/me/email/request':
          return json(
              {'message': 'We sent a 6-digit code to new@example.com.'});
        case '/auth/me/email/verify':
          final otp = jsonDecode(request.body)['otp'];
          return otp == '123456'
              ? json({
                  'id': 7,
                  'name': 'Kofi',
                  'email': 'new@example.com',
                  'role': 'rider',
                  'provider': 'local'
                })
              : json({'detail': 'Invalid code.'}, 400);
      }
      return json({'detail': 'unexpected'}, 404);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(app(auth));
      await tester.tap(find.byKey(const Key('settings-change-email')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('email-new-field')), 'new@example.com');
      await tester.enterText(
          find.byKey(const Key('email-password-field')), 'Password123!');
      await tester.tap(find.byKey(const Key('email-send-code')));
      await tester.pumpAndSettle();
      expect(find.text('We sent a 6-digit code to new@example.com.'),
          findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('email-code-field')), '000000');
      await tester.tap(find.byKey(const Key('email-verify')));
      await tester.pumpAndSettle();
      expect(find.text('Invalid code.'), findsOneWidget);
      expect(auth.email, 'old@example.com');

      await tester.enterText(
          find.byKey(const Key('email-code-field')), '123456');
      await tester.tap(find.byKey(const Key('email-verify')));
      await tester.pumpAndSettle();
    }, () => client);

    expect(auth.email, 'new@example.com');
    expect(find.text('Email updated to new@example.com.'), findsOneWidget);
    expect(
        requests.any((r) => r.contains('"password":"Password123!"')), isTrue);
  });

  testWidgets('password form validates before calling the server',
      (tester) async {
    final auth = await signedIn();
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return json({'message': 'Password changed successfully.'});
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(app(auth));
      await tester.tap(find.byKey(const Key('settings-change-password')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('password-current-field')), 'old');
      await tester.enterText(
          find.byKey(const Key('password-new-field')), 'short');
      await tester.enterText(
          find.byKey(const Key('password-confirm-field')), 'short');
      await tester.tap(find.byKey(const Key('password-save')));
      await tester.pumpAndSettle();
      expect(find.text('New password must be at least 8 characters.'),
          findsOneWidget);
      expect(calls, 0);

      await tester.enterText(
          find.byKey(const Key('password-new-field')), 'LongEnough1!');
      await tester.enterText(
          find.byKey(const Key('password-confirm-field')), 'LongEnough1!');
      await tester.tap(find.byKey(const Key('password-save')));
      await tester.pumpAndSettle();
    }, () => client);

    expect(calls, 1);
    expect(find.text('Password changed.'), findsOneWidget);
  });

  test('an expired session signs the user out', () async {
    final auth = await signedIn();
    final client =
        MockClient((_) async => json({'detail': 'Token has expired.'}, 401));

    await http.runWithClient(() async {
      await expectLater(ApiService.getMyOrders('token'), throwsException);
      await Future<void>.delayed(Duration.zero);
    }, () => client);

    expect(auth.isLoggedIn, isFalse);
    expect(auth.token, isNull);
  });

  test('a suspended account is signed out', () async {
    final auth = await signedIn();
    final client = MockClient((_) async => json(
        {'detail': 'This account has been suspended. Contact support.'}, 403));

    await http.runWithClient(() async {
      await expectLater(ApiService.getMyOrders('token'), throwsException);
      await Future<void>.delayed(Duration.zero);
    }, () => client);

    expect(auth.isLoggedIn, isFalse);
  });

  test('session refresh swaps in a fresh token', () async {
    final auth = await signedIn();
    final client = MockClient((request) async {
      expect(request.url.path, '/auth/refresh');
      expect(request.headers['Authorization'], 'Bearer token');
      return json({
        'access_token': 'fresh',
        'user_id': 7,
        'role': 'rider',
        'message': 'ok',
        'otp_required': false
      });
    });

    await http.runWithClient(auth.refreshSession, () => client);
    expect(auth.token, 'fresh');
  });

  test('a saved session opens instantly while the server is slow', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'saved',
      'auth_user_id': '7',
      'auth_role': 'rider',
      'auth_name': 'Kofi',
      'auth_email': 'kofi@example.com',
    });
    final serverAnswered = Completer<void>();
    final client = MockClient((_) async {
      await serverAnswered.future; // a sleeping server
      return json({'id': 7, 'name': 'Kofi Mensah', 'email': 'kofi@example.com',
          'role': 'rider'});
    });

    await http.runWithClient(() async {
      final auth = AuthProvider();
      await auth.initializeFromSecureStorage();
      expect(auth.isInitialized, isTrue, reason: 'does not wait for the server');
      expect(auth.isLoggedIn, isTrue);
      expect(auth.role, 'rider');
      expect(auth.name, 'Kofi');

      serverAnswered.complete();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(auth.name, 'Kofi Mensah', reason: 'refreshed in the background');
    }, () => client);
  });

  test('a rejected saved session is signed out in the background', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'stale',
      'auth_user_id': '7',
      'auth_role': 'customer',
    });
    final client = MockClient((_) async => json({'detail': 'Token has expired.'}, 401));

    await http.runWithClient(() async {
      final auth = AuthProvider();
      await auth.initializeFromSecureStorage();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(auth.isLoggedIn, isFalse);
    }, () => client);
  });

  test('a timed-out request explains itself', () {
    expect(ServerTimeoutException().toString(),
        contains('taking too long to respond'));
  });
}
