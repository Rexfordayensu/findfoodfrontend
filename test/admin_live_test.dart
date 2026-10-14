import 'dart:convert';

import 'package:findfood_app/screens/admin/admin_dashboard.dart';
import 'package:findfood_app/utils/time_format.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);
  tearDown(() => LiveRefresh.interval = const Duration(seconds: 10));

  testWidgets('admin dashboard updates itself without reloading',
      (tester) async {
    LiveRefresh.interval = const Duration(seconds: 2);
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'admin', name: 'Ade');

    // The "server" gains orders, a pending restaurant and a failed refund.
    var totalOrders = 3;
    var pending = <Map<String, dynamic>>[];
    var notifications = <Map<String, dynamic>>[];
    var activity = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/admin/stats':
          return json({
            'total_orders': totalOrders,
            'revenue_today': 0,
            'active_riders': 1,
            'total_restaurants': 2,
            'pending_approvals': pending.length,
          });
        case '/admin/restaurants/pending':
          return json(pending);
        case '/admin/notifications':
          return json(notifications);
        case '/admin/activity':
          return json(activity);
      }
      return json([]);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: AdminDashboard()),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('3'), findsWidgets);
      expect(find.textContaining('No activity yet'), findsOneWidget);
      expect(find.text('Local preview'), findsNothing);

      totalOrders = 7;
      activity = [
        {
          'kind': 'order',
          'title': 'Order #42 placed',
          'detail': "Mama's Kitchen",
          'at': DateTime.now().toUtc().toIso8601String(),
        },
      ];
      pending = [
        {
          'id': 9,
          'name': 'New Spot',
          'cuisine_type': 'Local',
          'address': 'Tema'
        }
      ];
      notifications = [
        {
          'kind': 'approval',
          'title': 'Restaurant awaiting approval',
          'detail': ''
        },
        {'kind': 'refund', 'title': 'Refund needs attention', 'detail': ''},
      ];

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    }, () => client);

    expect(find.text('7'), findsWidgets, reason: 'order count refreshed live');
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'background refresh does not flash a spinner');
    expect(find.text('Order #42 placed'), findsOneWidget,
        reason: 'recent activity refreshed live');
    expect(find.text('Just now'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  test('relative activity times', () {
    final now = DateTime(2026, 10, 12, 15, 30);
    expect(relativeTime(now.subtract(const Duration(seconds: 20)), now),
        'Just now');
    expect(relativeTime(now.subtract(const Duration(minutes: 12)), now),
        '12 min ago');
    expect(
        relativeTime(now.subtract(const Duration(hours: 3)), now), '3 h ago');
    expect(relativeTime(DateTime(2026, 10, 11, 22), now), 'Yesterday');
    expect(relativeTime(DateTime(2026, 9, 3, 9), now), '3 Sep');
  });
}
