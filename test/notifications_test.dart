import 'dart:convert';

import 'package:findfood_app/screens/notifications_screen.dart';
import 'package:findfood_app/services/notifications_provider.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/services/push_bridge.dart';
import 'package:findfood_app/widgets/notification_bell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

/// Stands in for the browser: permission, subscription and the icon badge.
class FakePush implements PushBridge {
  String perm = 'default';
  final badges = <int>[];
  String? subscribedWith;
  void Function(Map<String, dynamic>)? handler;

  Map<String, dynamic> get _sub =>
      {'endpoint': 'https://push.example/me', 'keys': {'p256dh': 'k' * 20, 'auth': 'a' * 8}};

  @override
  bool get supported => true;
  @override
  String get permission => perm;
  @override
  bool get needsHomeScreen => false;
  @override
  Future<Map<String, dynamic>?> subscribe(String publicKey) async {
    subscribedWith = publicKey;
    perm = 'granted';
    return _sub;
  }

  @override
  Future<Map<String, dynamic>?> current() async => perm == 'granted' ? _sub : null;
  @override
  Future<String?> unsubscribe() async => 'https://push.example/me';
  @override
  void setBadge(int count) => badges.add(count);
  @override
  void listen(void Function(Map<String, dynamic> message) onMessage) => handler = onMessage;
}

String ago(int minutes) =>
    DateTime.now().toUtc().subtract(Duration(minutes: minutes)).toIso8601String();

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    NotificationsProvider.pollInterval = null;
  });

  late List<Map<String, dynamic>> items;
  late List<String> calls;
  late MockClient client;

  setUp(() {
    items = [
      {'id': 3, 'kind': 'on_the_way', 'title': 'Your order is on the way',
       'body': 'Kofi has collected order #41.', 'link': '/order-tracking/41',
       'created_at': ago(2), 'read': false},
      {'id': 2, 'kind': 'chat', 'title': "Mama's Kitchen · order #41",
       'body': 'Extra shito added', 'link': '/chat/41?with=restaurant',
       'created_at': ago(9), 'read': false},
      {'id': 1, 'kind': 'order_placed', 'title': 'Order placed', 'body': null,
       'link': '/order-tracking/41', 'created_at': ago(60 * 30), 'read': true},
    ];
    calls = [];
    client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      final unread = items.where((n) => n['read'] != true).length;
      switch (request.url.path) {
        case '/notifications':
          return json({'items': items, 'unread': unread});
        case '/notifications/read-all':
          for (final n in items) {
            n['read'] = true;
          }
          return json({'unread': 0});
        case '/push/public-key':
          return json({'key': 'PUBLICKEY'});
        case '/push/subscribe':
          return json({'subscribed': true}, 201);
        case '/push/unsubscribe':
          return json({'subscribed': false});
      }
      final read = RegExp(r'^/notifications/(\d+)/read$').firstMatch(request.url.path);
      if (read != null) {
        items.firstWhere((n) => n['id'] == int.parse(read.group(1)!))['read'] = true;
        return json({'unread': items.where((n) => n['read'] != true).length});
      }
      return json({});
    });
  });

  Future<(AuthProvider, NotificationsProvider, FakePush)> pump(WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    final push = FakePush();
    final notes = NotificationsProvider(bridge: push);
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Center(child: NotificationBell()))),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          path: '/order-tracking/:id',
          builder: (_, state) =>
              Scaffold(body: Text('Tracking ${state.pathParameters['id']}'))),
    ]);
    await http.runWithClient(() async {
      await auth.login(token: 't', userId: 7, role: 'customer', name: 'Ama');
      notes.updateAuth(auth);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: notes),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
    }, () => client);
    return (auth, notes, push);
  }

  testWidgets('the bell shows the unread count, and the app icon matches', (tester) async {
    final (_, notes, push) = await pump(tester);
    expect(notes.unread, 2);
    expect(
        find.descendant(
            of: find.byKey(const Key('notification-bell')), matching: find.text('2')),
        findsOneWidget);
    expect(push.badges.last, 2, reason: 'the installed app icon shows the same number');
    expect(calls, contains('GET /push/public-key'),
        reason: 'fetched early so a tap can prompt straight away');
  });

  testWidgets('the centre lists read and unread; opening one marks it read', (tester) async {
    final (_, notes, push) = await pump(tester);
    await http.runWithClient(() async {
      await tester.tap(find.byKey(const Key('notification-bell')));
      await tester.pumpAndSettle();
      expect(find.text('Your order is on the way'), findsOneWidget);
      expect(find.text('Order placed'), findsOneWidget, reason: 'read ones are listed too');
      expect(find.byKey(const Key('notification-unread-dot')), findsNWidgets(2));
      expect(find.text('TODAY'), findsOneWidget);

      await tester.tap(find.byKey(const Key('notifications-unread')));
      await tester.pumpAndSettle();
      expect(find.text('Order placed'), findsNothing);
      await tester.tap(find.byKey(const Key('notifications-all')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('notification-3')));
      await tester.pumpAndSettle();
    }, () => client);

    expect(find.text('Tracking 41'), findsOneWidget);
    expect(calls, contains('POST /notifications/3/read'));
    expect(notes.unread, 1);
    expect(push.badges.last, 1);
  });

  testWidgets('mark all read clears the badge', (tester) async {
    final (_, notes, push) = await pump(tester);
    await http.runWithClient(() async {
      await tester.tap(find.byKey(const Key('notification-bell')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('notifications-read-all')));
      await tester.pumpAndSettle();
    }, () => client);
    expect(calls, contains('POST /notifications/read-all'));
    expect(notes.unread, 0);
    expect(push.badges.last, 0);
    expect(find.byKey(const Key('notification-unread-dot')), findsNothing);
  });

  testWidgets('turning on push subscribes this device; signing out forgets it',
      (tester) async {
    final (auth, notes, push) = await pump(tester);
    await http.runWithClient(() async {
      await tester.tap(find.byKey(const Key('notification-bell')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('push-prompt')), findsOneWidget);
      await tester.tap(find.byKey(const Key('push-enable')));
      await tester.pumpAndSettle();
      expect(push.subscribedWith, 'PUBLICKEY');
      expect(calls, contains('POST /push/subscribe'));
      expect(notes.deviceSubscribed, isTrue);
      expect(find.byKey(const Key('push-prompt')), findsNothing);

      // A push arriving refreshes the bell straight away.
      items.insert(0, {'id': 4, 'kind': 'delivered', 'title': 'Delivered. Enjoy your meal!',
          'link': '/order-tracking/41', 'created_at': ago(0), 'read': false});
      push.handler!({'type': 'findfood-push', 'data': {}});
      await tester.pumpAndSettle();
      expect(notes.unread, 3);

      await auth.logout();
      notes.updateAuth(auth);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
    }, () => client);
    expect(calls, contains('POST /push/unsubscribe'));
    expect(notes.unread, 0);
    expect(push.badges.last, 0);
  });

  test('times read naturally', () {
    final now = DateTime(2026, 10, 14, 15, 30);
    expect(notificationTime(now.subtract(const Duration(seconds: 20)), now), 'now');
    expect(notificationTime(now.subtract(const Duration(minutes: 12)), now), '12 min');
    expect(notificationTime(now.subtract(const Duration(hours: 3)), now), '3 h');
    expect(notificationTime(DateTime(2026, 10, 13, 9, 5), now), 'Yesterday 09:05');
    expect(notificationTime(DateTime(2026, 10, 2, 9, 5), now), '2 Oct');
  });
}
