import 'dart:async';
import 'dart:convert';

import 'package:findfood_app/services/crash_reporter.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/app_health.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

void main() {
  late List<http.Request> sent;
  late MockClient client;

  setUp(() {
    sent = [];
    client = MockClient((request) async {
      sent.add(request);
      return json({'received': true}, 202);
    });
    CrashReporter.enabled = true;
    CrashReporter.reset(token: () => 'tok', route: () => '/cart');
  });
  tearDown(() => CrashReporter.enabled = false);

  Map<String, dynamic> body(http.Request r) => jsonDecode(r.body) as Map<String, dynamic>;

  test('a crash is sent with where it happened, once a minute at most', () async {
    await http.runWithClient(() async {
      Object? error;
      StackTrace? stack;
      try {
        final List<int> empty = [];
        empty[3];
      } catch (e, s) {
        error = e;
        stack = s;
      }
      await CrashReporter.report(error!, stack);
      await CrashReporter.report(error, stack); // the same crash again
    }, () => client);

    expect(sent, hasLength(1));
    expect(sent.single.url.path, '/client-errors');
    expect(sent.single.headers['Authorization'], 'Bearer tok');
    final report = body(sent.single);
    expect(report['error_type'], 'RangeError');
    expect(report['message'], contains('RangeError'));
    expect(report['route'], '/cart');
    expect(report['app_version'], CrashReporter.appVersion);
    expect(report['stack'], contains('crash_reporter_test.dart'));
  });

  test('network trouble is not a crash', () async {
    await http.runWithClient(() async {
      await CrashReporter.report(http.ClientException('Failed to fetch'), null);
      await CrashReporter.report(TimeoutException('slow'), null);
      await CrashReporter.report(Exception('XMLHttpRequest error.'), null);
    }, () => client);
    expect(sent, isEmpty);
  });

  test('a session sends a limited number of reports', () async {
    await http.runWithClient(() async {
      for (var i = 0; i < CrashReporter.maxPerSession + 5; i++) {
        await CrashReporter.report(StateError('Bad state number $i'), null);
      }
    }, () => client);
    expect(sent, hasLength(CrashReporter.maxPerSession));
  });

  test('reporting never throws, even when the server is down', () async {
    final down = MockClient((_) async => throw http.ClientException('offline'));
    await http.runWithClient(
        () => CrashReporter.report(StateError('boom'), null), () => down);
  });

  testWidgets('admins see open crashes and can mark one fixed', (tester) async {
    LiveRefresh.interval = null;
    AuthProvider.refreshInterval = null;
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'admin', name: 'Ade');

    var open = [
      {
        'id': 7, 'source': 'app', 'error_type': 'TypeError',
        'message': 'Null check operator used on a null value', 'count': 12,
        'route': '/cart', 'role': 'customer', 'app_version': '1.0.0',
        'stack': '#0 CartScreen._total (cart_screen.dart:120:7)',
        'first_seen': DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String(),
        'last_seen': DateTime.now().toUtc().toIso8601String(),
        'resolved': false,
      },
    ];
    var resolvedId = 0;
    final admin = MockClient((request) async {
      if (request.url.path == '/admin/errors') return json(open);
      final match = RegExp(r'^/admin/errors/(\d+)/resolve$').firstMatch(request.url.path);
      if (match != null) {
        resolvedId = int.parse(match.group(1)!);
        open = [];
        return json({'id': resolvedId, 'resolved': true});
      }
      return json([]);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: AppHealthPanel()))),
      ));
      await tester.pumpAndSettle();
      expect(find.text('App health'), findsOneWidget);
      expect(find.textContaining('12×'), findsOneWidget);
      expect(find.text('12 crashes reported'), findsOneWidget);

      await tester.tap(find.byKey(const Key('app-error-7')));
      await tester.pumpAndSettle();
      expect(find.textContaining('cart_screen.dart:120'), findsOneWidget);
      expect(find.text('Last seen by a customer'), findsOneWidget);
      await tester.tap(find.byKey(const Key('app-error-resolve')));
      await tester.pumpAndSettle();
    }, () => admin);

    expect(resolvedId, 7);
    expect(find.text('App health'), findsNothing, reason: 'nothing left open');
  });
}
