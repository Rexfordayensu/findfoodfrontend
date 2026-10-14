// End-to-end tests: the real app UI talking over real HTTP to a running
// backend seeded with backend/tools/seed_e2e.py.
//
// Skipped unless run with:
//   flutter test test/e2e_live_test.dart --dart-define=LIVE_E2E=true
// against a backend listening on http://localhost:8000 (ApiService.baseUrl).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:findfood_app/main.dart';
import 'package:findfood_app/services/api_service.dart';
import 'package:findfood_app/services/notifications_provider.dart';
import 'package:findfood_app/services/otp_provider.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:findfood_app/widgets/widgets.dart';

const bool live = bool.fromEnvironment('LIVE_E2E');
const password = 'Password123!';

// IDs created by backend/tools/seed_e2e.py on a fresh database.
const riderId = 2;
const unpaidOrderId = 1;
const paidOrderId = 2;
const deliveredOrderId = 3;
const readyOrderId = 4; // paid, ready, no rider yet

late ThemeProvider theme;

Future<void> startApp(WidgetTester tester, {Size size = const Size(430, 932)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  FlutterSecureStorage.setMockInitialValues({});
  theme = ThemeProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => OrderPollingProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: const FindFoodApp(),
    ),
  );
}

/// Lets real network I/O progress while pumping frames until [finder] matches.
Future<void> waitFor(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 25)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  final onScreen = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .where((t) => t.trim().isNotEmpty)
      .take(40)
      .join(' | ');
  throw TestFailure('Timed out waiting for $finder\nOn screen: $onScreen');
}

Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester);
}

Future<T> api<T>(WidgetTester tester, Future<T> Function() call) async =>
    (await tester.runAsync(call)) as T;

/// Signs in through the real login screen.
Future<void> signIn(WidgetTester tester, String email, String pass) async {
  await waitFor(tester, find.byTooltip('Sign in'));
  await settle(tester, 15); // let the route transition finish before tapping
  await tapAndSettle(tester, find.byTooltip('Sign in'));
  await waitFor(tester, find.widgetWithText(TextFormField, 'Email address'));
  await tester.enterText(find.widgetWithText(TextFormField, 'Email address').first, email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Password').first, pass);
  await tapAndSettle(tester, find.widgetWithText(PrimaryButton, 'Sign in'));
}

String tokenOf(WidgetTester tester) =>
    Provider.of<AuthProvider>(tester.element(find.byType(FindFoodApp)), listen: false)
        .token!;

Future<void> editProfileName(WidgetTester tester, String name) async {
  await tapAndSettle(tester, find.byKey(const Key('settings-edit-profile')));
  await waitFor(tester, find.byKey(const Key('profile-name-field')));
  await tester.enterText(find.byKey(const Key('profile-name-field')), name);
  await tapAndSettle(tester, find.byKey(const Key('profile-save')));
  await waitFor(tester, find.text('Profile updated.'));
  final me = await api(tester, () => ApiService.getMyProfile(tokenOf(tester)));
  expect(me['name'], name);
  final auth = Provider.of<AuthProvider>(
      tester.element(find.byType(FindFoodApp)), listen: false);
  expect(auth.name, name, reason: 'the signed-in session shows the new name');
}

Future<void> finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester, 3);
}

void main() {
  if (!live) {
    test('live end-to-end tests', () {},
        skip: 'Run with --dart-define=LIVE_E2E=true against a seeded backend.');
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    NotificationsProvider.pollInterval = null;
    HttpOverrides.global = null; // use the real network for these tests
    AuthProvider.refreshInterval = null;
  });

  testWidgets('customer: profile settings, orders, cancel, rate, sign out',
      (tester) async {
    await startApp(tester);
    await signIn(tester, 'customer@e2e-findfood.com', password);
    await waitFor(tester, find.text("Mama's Kitchen"));
    expect(find.text('New'), findsWidgets, reason: 'unrated restaurant shows "New"');

    // Header profile button → account settings page.
    await tapAndSettle(tester, find.byTooltip('Profile'));
    await waitFor(tester, find.byKey(const Key('settings-edit-profile')));
    expect(find.text('Ama Customer'), findsOneWidget);
    expect(find.text('customer@e2e-findfood.com'), findsOneWidget);

    await editProfileName(tester, 'Ama Mensah');

    // Notification preferences persist.
    await tapAndSettle(tester, find.byKey(const Key('settings-notifications')));
    await waitFor(tester, find.byKey(const Key('notif-email')));
    await tapAndSettle(tester, find.byKey(const Key('notif-email')));
    await tapAndSettle(tester, find.byKey(const Key('notif-save')));
    await waitFor(tester, find.text('Notification preferences saved.'));
    final prefs = await api(tester, () => ApiService.getNotificationPrefs(tokenOf(tester)));
    expect(prefs['email_notifications'], false);

    // Change password, then prove the new one works.
    await tapAndSettle(tester, find.byKey(const Key('settings-change-password')));
    await tester.enterText(find.byKey(const Key('password-current-field')), password);
    await tester.enterText(find.byKey(const Key('password-new-field')), 'NewPassword456!');
    await tester.enterText(find.byKey(const Key('password-confirm-field')), 'NewPassword456!');
    await tapAndSettle(tester, find.byKey(const Key('password-save')));
    await waitFor(tester, find.text('Password changed.'));
    final relogin = await api(tester, () => ApiService.login('customer@e2e-findfood.com', 'NewPassword456!'));
    expect(relogin['access_token'], isNotNull);

    // Appearance toggle.
    final wasDark = theme.isDark;
    await tapAndSettle(tester, find.byKey(const Key('settings-appearance')));
    expect(theme.isDark, !wasDark);

    // Help page opens.
    await tapAndSettle(tester, find.byKey(const Key('settings-help')));
    await waitFor(tester, find.text('Frequently asked questions'));
    await tapAndSettle(tester, find.byTooltip('Back'));

    // Orders: cancel the unpaid one, cancel the paid one, rate the delivered one.
    await tapAndSettle(tester, find.byKey(const Key('settings-my-orders')));
    await waitFor(tester, find.byKey(const Key('pay-order-$unpaidOrderId')));

    await tapAndSettle(tester, find.byKey(const Key('cancel-order-$unpaidOrderId')));
    await tapAndSettle(tester, find.byKey(const Key('confirm-cancel-order')));
    await waitFor(tester, find.text('Order cancelled.'));

    await tapAndSettle(tester, find.byKey(const Key('cancel-order-$paidOrderId')));
    await tapAndSettle(tester, find.byKey(const Key('confirm-cancel-order')));
    await waitFor(tester, find.text('Order cancelled and refunded.'));

    await tapAndSettle(tester, find.byKey(const Key('rate-order-$deliveredOrderId')));
    await waitFor(tester, find.byKey(const Key('rate-restaurant-5')));
    await tapAndSettle(tester, find.byKey(const Key('rate-restaurant-5')));
    await tapAndSettle(tester, find.byKey(const Key('rate-rider-4')));
    await tapAndSettle(tester, find.byKey(const Key('rate-submit')));
    await waitFor(tester, find.textContaining('You rated this'));

    final orders = await api(tester, () => ApiService.getMyOrders(tokenOf(tester)));
    final statuses = {for (final o in orders) o.id: o.status};
    expect(statuses[unpaidOrderId], 'cancelled');
    expect(statuses[paidOrderId], 'cancelled');
    expect(orders.firstWhere((o) => o.id == deliveredOrderId).isRated, isTrue);
    final restaurants = await api(tester, ApiService.getRestaurants);
    expect(restaurants.single.averageRating, 5.0);

    await finish(tester);
  });

  testWidgets('rider: real earnings and profile settings', (tester) async {
    await startApp(tester);
    await signIn(tester, 'rider@e2e-findfood.com', password);
    await waitFor(tester, find.text('Earnings'));

    await tapAndSettle(tester, find.text('Earnings').last);
    await waitFor(tester, find.byKey(const Key('rider-today-earnings')));
    expect(find.text('GH₵ 4.00'), findsWidgets, reason: '10% of a GH₵ 40 order');
    expect(find.text('★ 4.0'), findsOneWidget, reason: 'customer rated the rider 4');
    expect(find.text('Order #$deliveredOrderId'), findsOneWidget);

    await tapAndSettle(tester, find.text('Profile').last);
    await waitFor(tester, find.byKey(const Key('settings-edit-profile')));
    expect(find.text('Kofi Rider'), findsOneWidget);
    await editProfileName(tester, 'Kofi Mensah');

    await finish(tester);
  });

  testWidgets('handover codes: restaurant checks the rider, rider checks the customer',
      (tester) async {
    LiveRefresh.interval = const Duration(seconds: 2);
    addTearDown(() => LiveRefresh.interval = const Duration(seconds: 10));

    Future<String> login(String email, List<String> passwords) => api(tester, () async {
          for (final pass in passwords) {
            final res = await http.post(Uri.parse('${ApiService.baseUrl}/login'),
                body: {'username': email, 'password': pass});
            if (res.statusCode == 200) {
              return jsonDecode(res.body)['access_token'] as String;
            }
          }
          throw StateError('cannot sign in $email');
        });
    Future<Map<String, dynamic>> orderAs(String token) => api(tester, () async {
          final res = await http.get(Uri.parse('${ApiService.baseUrl}/orders'),
              headers: {'Authorization': 'Bearer $token'});
          return (jsonDecode(res.body) as List)
              .cast<Map<String, dynamic>>()
              .firstWhere((o) => o['id'] == readyOrderId);
        });
    Future<http.Response> handover(String token, String code) => api(tester,
        () => http.post(Uri.parse('${ApiService.baseUrl}/orders/$readyOrderId/handover'),
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode({'code': code})));

    // The rider accepts the job in the app and sees a pickup code.
    await startApp(tester);
    await signIn(tester, 'rider@e2e-findfood.com', password);
    await waitFor(tester, find.text('Accept delivery'));
    await tapAndSettle(tester, find.text('Accept delivery').first);
    await tapAndSettle(tester, find.text('My Deliveries').last);
    final codeCard = find.byKey(const Key('rider-pickup-code-$readyOrderId'));
    await waitFor(tester, codeCard);
    String shownCode() => tester
        .widgetList<Text>(find.descendant(
            of: find.descendant(of: codeCard, matching: find.byKey(const Key('handoff-code-digits'))),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .join();
    final firstCode = shownCode();
    expect(find.text('Jollof Rice'), findsOneWidget, reason: 'packing list shown');

    // Accepted by mistake: release it before collecting, then take it again.
    await tapAndSettle(tester, find.byKey(const Key('rider-release-$readyOrderId')));
    await tapAndSettle(tester, find.byKey(const Key('confirm-release')));
    await waitFor(tester, find.text('Order #$readyOrderId released to other riders.'));
    expect(codeCard, findsNothing);
    await tapAndSettle(tester, find.text('Available').last);
    await waitFor(tester, find.text('Accept delivery'));
    await tapAndSettle(tester, find.text('Accept delivery').first);
    await tapAndSettle(tester, find.text('My Deliveries').last);
    await waitFor(tester, codeCard);

    final pickupCode = tester
        .widgetList<Text>(find.descendant(
            of: find.descendant(of: codeCard, matching: find.byKey(const Key('handoff-code-digits'))),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .join();
    expect(pickupCode, matches(RegExp(r'^\d{4}$')));

    // Nobody sees a code that is not theirs.
    final ownerToken = await login('owner@e2e-findfood.com', [password]);
    final customerToken =
        await login('customer@e2e-findfood.com', [password, 'NewPassword456!']);
    final asCustomer = await orderAs(customerToken);
    final asRestaurant = await orderAs(ownerToken);
    // The customer's code only appears after they've checked their food.
    expect(asCustomer['delivery_code'], isNull);
    expect(asCustomer['pickup_code'], isNull);
    expect(asRestaurant['pickup_code'], isNull);
    expect(asRestaurant['delivery_code'], isNull);
    expect(asRestaurant['rider_name'], isNotNull);

    // The restaurant must enter the rider's current code. The code from the
    // released acceptance is dead, so it counts as a wrong attempt.
    final wrongPickup = firstCode != pickupCode
        ? firstCode
        : (pickupCode == '0000' ? '1111' : '0000');
    final refused = await handover(ownerToken, wrongPickup);
    expect(refused.statusCode, 400);
    expect(jsonDecode(refused.body)['detail'], contains('1 attempt left'));
    final handed = await handover(ownerToken, pickupCode);
    expect(handed.statusCode, 200);
    expect(jsonDecode(handed.body)['status'], 'out_for_delivery');

    // At the door the customer ticks their food; then their code shows.
    final checked = await api(tester,
        () => ApiService.doorstepCheck(customerToken, readyOrderId, true));
    final deliveryCode = checked.deliveryCode!;
    expect(deliveryCode, matches(RegExp(r'^\d{4}$')));
    expect(deliveryCode, isNot(pickupCode));

    // The rider's list updates by itself; they finish with the customer's code.
    final complete = find.byKey(const Key('rider-complete-$readyOrderId'));
    await waitFor(tester, complete);
    expect(codeCard, findsNothing, reason: 'pickup code is gone after handover');
    expect(find.byKey(const Key('rider-release-$readyOrderId')), findsNothing,
        reason: 'a collected job cannot be released');
    final riderToken = tokenOf(tester);
    final lateRelease = await api(tester, () => http.post(
        Uri.parse('${ApiService.baseUrl}/deliveries/$readyOrderId/release'),
        headers: {'Authorization': 'Bearer $riderToken'}));
    expect(lateRelease.statusCode, 400);
    expect(jsonDecode(lateRelease.body)['detail'], contains('already collected'));
    await tapAndSettle(tester, complete);
    await waitFor(tester, find.byKey(const Key('handoff-code-input')));
    final wrongDelivery = deliveryCode == '0000' ? '1111' : '0000';
    await tester.enterText(find.byKey(const Key('handoff-code-input')), wrongDelivery);
    await waitFor(tester, find.textContaining('1 attempt left'));
    await tester.enterText(find.byKey(const Key('handoff-code-input')), deliveryCode);
    await waitFor(tester, find.text('Delivery complete. Nice work!'));

    final finished = await orderAs(customerToken);
    expect(finished['status'], 'delivered');
    expect(finished['collected_at'], isNotNull);

    // Admins see the release and the collection in the activity feed.
    final adminToken = await login('admin@e2e-findfood.com', [password]);
    final activity = await api(tester, () async {
      final res = await http.get(Uri.parse('${ApiService.baseUrl}/admin/activity'),
          headers: {'Authorization': 'Bearer $adminToken'});
      return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    });
    final titles = activity.map((a) => a['title'] as String).toList();
    expect(titles.where((t) => t.endsWith('released order #$readyOrderId')), hasLength(1));
    expect(titles, contains('Order #$readyOrderId collected by rider'));
    expect(finished['delivery_code'], isNull, reason: 'code is hidden once used');

    await finish(tester);
  });

  testWidgets('restaurant: kitchen status and restaurant profile', (tester) async {
    await startApp(tester);
    await signIn(tester, 'owner@e2e-findfood.com', password);
    await waitFor(tester, find.text('Settings'));

    await tapAndSettle(tester, find.text('Settings').last);
    await waitFor(tester, find.byKey(const Key('kitchen-switch')));

    await tapAndSettle(tester, find.byKey(const Key('kitchen-switch')));
    await waitFor(tester, find.text('Kitchen closed. New orders are paused.'));
    var mine = await api(tester, () => ApiService.getMyRestaurant(tokenOf(tester)));
    expect(mine.isOpen, isFalse);

    await tapAndSettle(tester, find.byKey(const Key('settings-restaurant-profile')));
    await waitFor(tester, find.byKey(const Key('restaurant-name-field')));
    await tester.enterText(find.byKey(const Key('restaurant-name-field')), "Mama's Place");
    await tapAndSettle(tester, find.byKey(const Key('restaurant-profile-save')));
    await waitFor(tester, find.text('Restaurant profile updated.'));
    mine = await api(tester, () => ApiService.getMyRestaurant(tokenOf(tester)));
    expect(mine.name, "Mama's Place");
    expect(mine.averageRating, 5.0);

    await editProfileName(tester, 'Esi Mensah');

    // Reopen so other flows keep working.
    await tapAndSettle(tester, find.byKey(const Key('kitchen-switch')));
    await waitFor(tester, find.text('Kitchen is open for orders.'));

    await finish(tester);
  });

  testWidgets('admin: notifications, suspend a user, settings', (tester) async {
    await startApp(tester, size: const Size(1280, 900));
    await signIn(tester, 'admin@e2e-findfood.com', password);
    await waitFor(tester, find.byKey(const Key('notification-bell')));

    // The customer's paid order was cancelled without a configured Paystack
    // key, so the refund is flagged for the admin: in the notification page's
    // "Needs attention", and as a notification of its own.
    await tapAndSettle(tester, find.byKey(const Key('notification-bell')));
    await waitFor(tester, find.text('Refund needs attention'));
    await waitFor(tester, find.textContaining('Refund needs attention: order #'));
    await tapAndSettle(tester, find.byTooltip('Back'));
    await waitFor(tester, find.text('Users'));

    await tapAndSettle(tester, find.text('Users').first);
    await waitFor(tester, find.byKey(const Key('user-actions-$riderId')));
    await tapAndSettle(tester, find.byKey(const Key('user-actions-$riderId')));
    await tapAndSettle(tester, find.text('Suspend account'));
    await tapAndSettle(tester, find.text('Suspend'));
    await waitFor(tester, find.textContaining('suspended.'));

    final riderLogin = await api(tester, () async {
      try {
        await ApiService.login('rider@e2e-findfood.com', password);
        return 'signed in';
      } catch (e) {
        return e.toString();
      }
    });
    expect(riderLogin, contains('suspended'));

    await tapAndSettle(tester, find.text('Settings').first);
    await waitFor(tester, find.byKey(const Key('settings-edit-profile')));
    await editProfileName(tester, 'Ade Mensah');

    await finish(tester);
  });

  testWidgets('chat: messages are delivered live between customer and restaurant',
      (tester) async {
    // The restaurant signs in outside the app and listens on its own socket.
    final ownerToken = await api(tester, () async {
      final res = await http.post(Uri.parse('${ApiService.baseUrl}/login'),
          body: {'username': 'owner@e2e-findfood.com', 'password': password});
      return jsonDecode(res.body)['access_token'] as String;
    });
    final wsBase = ApiService.baseUrl.replaceFirst('http', 'ws');
    final ownerSocket = (await api(tester, () => WebSocket.connect(
        '$wsBase/ws/orders/$deliveredOrderId/chat?token=$ownerToken')));
    final ownerInbox = <Map<String, dynamic>>[];
    final sub = ownerSocket.listen(
        (raw) => ownerInbox.add(jsonDecode(raw as String) as Map<String, dynamic>));

    // The customer test changes this password; work with either.
    final customerPassword = await api(tester, () async {
      try {
        await ApiService.login('customer@e2e-findfood.com', password);
        return password;
      } catch (_) {
        return 'NewPassword456!';
      }
    });

    // The customer opens the chat from order tracking in the app.
    await startApp(tester);
    await signIn(tester, 'customer@e2e-findfood.com', customerPassword);
    await waitFor(tester, find.text('Orders'));
    await tapAndSettle(tester, find.text('Orders').last);
    await waitFor(tester, find.byKey(const Key('order-card-$deliveredOrderId')));
    await tapAndSettle(tester, find.byKey(const Key('order-card-$deliveredOrderId')));
    await waitFor(tester, find.byKey(const Key('tracking-open-chat')));
    await tapAndSettle(tester, find.byKey(const Key('tracking-open-chat')));
    await waitFor(tester, find.textContaining('· Live'));

    // Restaurant -> customer: appears in the open chat without refreshing.
    final fromKitchen = 'Your jollof is ready ${DateTime.now().millisecondsSinceEpoch}';
    final sentAt = DateTime.now();
    await api(tester, () => http.post(
        Uri.parse('${ApiService.baseUrl}/orders/$deliveredOrderId/messages'),
        headers: {
          'Authorization': 'Bearer $ownerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': fromKitchen})));
    await waitFor(tester, find.text(fromKitchen), timeout: const Duration(seconds: 5));
    // ignore: avoid_print
    print('restaurant -> customer shown in app after '
        '${DateTime.now().difference(sentAt).inMilliseconds} ms');
    expect(find.text('Restaurant'), findsWidgets);

    // Customer -> restaurant: typed in the app, received on the kitchen's socket.
    const fromCustomer = 'Great, thank you!';
    await tester.enterText(find.byKey(const Key('chat-input')), fromCustomer);
    await tapAndSettle(tester, find.byKey(const Key('chat-send')));
    await waitFor(tester, find.text(fromCustomer));
    final end = DateTime.now().add(const Duration(seconds: 5));
    while (!ownerInbox.any((m) => m['message'] == fromCustomer) &&
        DateTime.now().isBefore(end)) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    }
    final received = ownerInbox.where((m) => m['message'] == fromCustomer);
    expect(received, hasLength(1), reason: 'restaurant socket receives it once');
    expect(received.single['sender_role'], 'customer');
    expect(find.text(fromCustomer), findsOneWidget, reason: 'shown once in the app');

    await api(tester, () async {
      await sub.cancel();
      await ownerSocket.close();
    });
    await finish(tester);
  });
}
