import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/order_tracking_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:findfood_app/widgets/order_issues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

Order order({String status = 'delivered', DateTime? completedAt,
        DateTime? collectedAt, String? issueStatus}) =>
    Order(
      id: 9, totalAmount: 5000, status: status, restaurantId: 3, userId: 7,
      restaurantName: 'Mama Yaa', fulfillmentMethod: 'delivery', riderId: 2,
      completedAt: completedAt, collectedAt: collectedAt, issueStatus: issueStatus,
    );

Future<void> pump(WidgetTester tester, String role, Widget home, http.Client client) async {
  FlutterSecureStorage.setMockInitialValues({});
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 7, role: role, name: 'Ama');
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await http.runWithClient(() async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(home: Scaffold(body: home)),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }, () => client);
}

Future<void> frames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
  });

  test('who can report what, and when', () {
    final now = DateTime(2026, 10, 14, 12);
    expect(reportableReasons(order(completedAt: now.subtract(const Duration(hours: 2))), now).keys,
        containsAll(['wrong_item', 'missing_item', 'damaged', 'other']));
    expect(reportableReasons(order(completedAt: now.subtract(const Duration(days: 3))), now), isEmpty);
    expect(reportableReasons(
        order(completedAt: now.subtract(const Duration(hours: 1)), issueStatus: 'open'), now), isEmpty);
    expect(reportableReasons(order(status: 'out_for_delivery',
        collectedAt: now.subtract(const Duration(minutes: 20))), now), isEmpty);
    expect(reportableReasons(order(status: 'out_for_delivery',
        collectedAt: now.subtract(const Duration(minutes: 75))), now).keys, ['not_delivered']);
  });

  testWidgets('a customer reports a wrong item from order tracking', (tester) async {
    Map<String, dynamic>? sent;
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/orders/9/issues') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return json({'id': 1, 'order_id': 9, 'reason': 'wrong_item',
            'reason_label': 'Wrong item', 'status': 'open'}, 201);
      }
      return json([]);
    });
    final delivered = order(completedAt: DateTime.now().subtract(const Duration(hours: 1)));
    await pump(tester, 'customer', OrderTrackingScreen(order: delivered), client);

    await http.runWithClient(() async {
      await tester.tap(find.byKey(const Key('tracking-report-problem')));
      await frames(tester);
      await tester.tap(find.byKey(const Key('issue-reason-wrong_item')));
      await tester.enterText(find.byKey(const Key('issue-details')), 'Got jollof, not waakye');
      await tester.tap(find.byKey(const Key('issue-submit')));
      await frames(tester);
    }, () => client);

    expect(sent, {'reason': 'wrong_item', 'details': 'Got jollof, not waakye'});
    expect(find.byKey(const Key('issue-status-card')), findsOneWidget);
    expect(find.text('Problem reported'), findsOneWidget);
    expect(find.byKey(const Key('tracking-report-problem')), findsNothing);
  });

  testWidgets('a refunded report shows the outcome and the admin note', (tester) async {
    final client = MockClient((request) async => request.url.path == '/orders/9/issues'
        ? json([{'id': 1, 'status': 'refunded', 'resolution_note': 'Sorry about that!'}])
        : json([]));
    await pump(tester, 'customer',
        OrderTrackingScreen(order: order(
            completedAt: DateTime.now().subtract(const Duration(hours: 3)),
            issueStatus: 'refunded')),
        client);
    expect(find.text('Refunded'), findsOneWidget);
    expect(find.text('“Sorry about that!”'), findsOneWidget);
  });

  testWidgets('an admin sees open reports and refunds one', (tester) async {
    var open = [
      {'id': 4, 'order_id': 9, 'reason': 'wrong_item', 'reason_label': 'Wrong item',
       'status': 'open', 'details': 'Got jollof, not waakye', 'customer_name': 'Ama Mensah',
       'restaurant_name': 'Mama Yaa', 'rider_name': 'Kofi', 'order_total': 5000,
       'items': [{'name': 'Waakye', 'quantity': 1}],
       'created_at': DateTime.now().toUtc().toIso8601String()},
    ];
    Map<String, dynamic>? resolved;
    final client = MockClient((request) async {
      if (request.url.path == '/admin/issues/4/resolve') {
        resolved = jsonDecode(request.body) as Map<String, dynamic>;
        open = [];
        return json({'id': 4, 'status': 'refunded'});
      }
      if (request.url.path == '/admin/issues') return json(open);
      return json([]);
    });
    await pump(tester, 'admin', const SingleChildScrollView(child: AdminIssuesPanel()), client);
    expect(find.text('Problem reports'), findsOneWidget);
    expect(find.text('Order #9 · Wrong item'), findsOneWidget);

    await http.runWithClient(() async {
      await tester.tap(find.byKey(const Key('admin-issue-4')));
      await frames(tester);
      expect(find.text('“Got jollof, not waakye”'), findsOneWidget);
      expect(find.textContaining('Ordered: 1× Waakye'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('issue-note')), 'Sorry about that!');
      await tester.tap(find.byKey(const Key('issue-refund')));
      await frames(tester);
    }, () => client);

    expect(resolved, {'action': 'refund', 'note': 'Sorry about that!'});
    expect(find.text('Problem reports'), findsNothing, reason: 'nothing left to review');
  });
}
