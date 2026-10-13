import 'package:findfood_app/services/api_service.dart';
import 'package:findfood_app/utils/friendly_error.dart';
import 'package:findfood_app/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('friendlyError', () {
    test('a sleeping server reads as waking up, not a failure', () {
      final e = friendlyError(ServerTimeoutException());
      expect(e.kind, ErrorKind.waking);
      expect(e.title, 'Waking up FindFood…');
    });

    test('status codes never reach people', () {
      expect(friendlyError(Exception('Failed to load orders (401)')).kind,
          ErrorKind.signedOut);
      expect(friendlyError(Exception('Failed to load menu (404)')).kind,
          ErrorKind.notFound);
      expect(friendlyError(Exception('Failed to load restaurants (502)')).kind,
          ErrorKind.server);
      for (final raw in [
        'Failed to load orders (401)',
        'Failed to load restaurants (503)',
        "type 'Null' is not a subtype of type 'String'",
        'ClientException: XMLHttpRequest error.',
      ]) {
        final shown = friendlyMessage(Exception(raw));
        expect(shown, isNot(contains('(')), reason: raw);
        expect(shown, isNot(contains('Exception')), reason: raw);
        expect(shown, isNot(contains('XMLHttpRequest')), reason: raw);
      }
    });

    test('offline errors say so', () {
      expect(friendlyError(Exception('ClientException: XMLHttpRequest error.')).kind,
          ErrorKind.offline);
    });

    test('messages written for people are kept', () {
      expect(friendlyMessage(Exception('That code is not right. 1 attempt left.')),
          'That code is not right. 1 attempt left.');
      expect(friendlyMessage(Exception('Invalid Credentials')), 'Invalid Credentials');
    });

    test('already-translated text keeps its meaning', () {
      final once = friendlyMessage(ServerTimeoutException());
      expect(friendlyError(once).kind, ErrorKind.waking);
      final signedOut = friendlyMessage(Exception('Failed to load orders (401)'));
      expect(friendlyError(signedOut).kind, ErrorKind.signedOut);
    });
  });

  testWidgets('a sleeping server is retried automatically until it answers',
      (tester) async {
    ErrorView.autoRetryEvery = const Duration(milliseconds: 200);
    var attempts = 0;
    Object? error = ServerTimeoutException();
    late StateSetter rebuild;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (context, setState) {
          rebuild = setState;
          return error == null
              ? const Text('Restaurants loaded')
              : ErrorView(
                  error: error!,
                  onRetry: () async {
                    attempts++;
                    // Still asleep on the first retry, awake on the second.
                    rebuild(() => error = attempts < 2 ? ServerTimeoutException() : null);
                  },
                );
        }),
      ),
    ));

    expect(find.text('Waking up FindFood…'), findsOneWidget);
    expect(find.text('Retrying automatically'), findsOneWidget);
    expect(find.byKey(const Key('error-retry')), findsNothing);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(attempts, 2);
    expect(find.text('Restaurants loaded'), findsOneWidget);
  });

  testWidgets('an ended session offers to sign in instead of an error code',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          body: ErrorView(
            error: Exception('Failed to load orders (401)'),
            onRetry: () async {},
          ),
        ),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Text('Sign-in page')),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Please sign in again'), findsOneWidget);
    expect(find.textContaining('401'), findsNothing);
    await tester.tap(find.byKey(const Key('error-sign-in')));
    await tester.pumpAndSettle();
    expect(find.text('Sign-in page'), findsOneWidget);
  });
}
