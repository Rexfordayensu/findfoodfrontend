import 'dart:convert';

import 'package:findfood_app/screens/admin/inbox_page.dart';
import 'package:findfood_app/screens/support_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status,
    headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<AuthProvider> signIn(WidgetTester tester, String role) async {
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 3, role: role, name: 'Ama');
  return auth;
}

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
  });

  testWidgets('a customer replies in a support conversation', (tester) async {
    final auth = await signIn(tester, 'customer');
    final sent = <String>[];
    final messages = [
      {'id': 1, 'body': 'Where is my food?', 'from_staff': false, 'sender_name': 'Ama',
       'created_at': DateTime.now().toUtc().toIso8601String()},
      {'id': 2, 'body': 'Your rider is 5 minutes away.', 'from_staff': true, 'sender_name': 'FindFood support',
       'created_at': DateTime.now().toUtc().toIso8601String()},
    ];
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        sent.add(jsonDecode(request.body)['body'] as String);
        messages.add({'id': 3, 'body': sent.last, 'from_staff': false, 'sender_name': 'Ama',
            'created_at': DateTime.now().toUtc().toIso8601String()});
        return json({'id': 9}, 201);
      }
      return json({'id': 9, 'subject': 'My order', 'status': 'open', 'messages': messages});
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: SupportThreadScreen(threadId: 9)),
      ));
      await settle(tester);
      expect(find.text('Your rider is 5 minutes away.'), findsOneWidget);
      expect(find.text('FindFood support'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('support-reply')), 'Thank you!');
      await tester.tap(find.byKey(const Key('support-reply-send')));
      await settle(tester);
    }, () => client);
    expect(sent, ['Thank you!']);
    expect(find.text('Thank you!'), findsOneWidget);
  });

  testWidgets('the admin inbox shows unread conversations', (tester) async {
    final auth = await signIn(tester, 'admin');
    final client = MockClient((request) async => json({
          'counts': {'open': 2, 'unread': 1},
          'threads': [
            {'id': 4, 'subject': 'Refund question', 'status': 'open', 'user_name': 'Kojo', 'user_role': 'rider',
             'last_message': 'When will I be paid?', 'last_from_staff': false, 'unread': 1,
             'updated_at': DateTime.now().toUtc().toIso8601String()},
          ],
        }));
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: SupportInboxPage())),
      ));
      await settle(tester);
    }, () => client);
    expect(find.text('Open (2)'), findsOneWidget);
    expect(find.text('Kojo · Refund question'), findsOneWidget);
    expect(find.text('When will I be paid?'), findsOneWidget);
  });

  testWidgets('an admin hides an abusive review', (tester) async {
    final auth = await signIn(tester, 'admin');
    final hidden = <String>[];
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/hide')) {
        hidden.add(jsonDecode(request.body)['reason'] as String);
        return json({'id': 5, 'hidden': true});
      }
      return json(hidden.isEmpty
          ? [{'id': 5, 'order_id': 12, 'restaurant_name': "Mama's Kitchen", 'customer_name': 'Ama',
              'rating': 1, 'comment': 'Terrible!!', 'hidden': false,
              'created_at': DateTime.now().toUtc().toIso8601String()}]
          : []);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: ReviewsPage())),
      ));
      await settle(tester);
      expect(find.text('"Terrible!!"'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-hide-5')));
      await settle(tester);
      await tester.tap(find.text('Abusive language'));
      await tester.tap(find.byKey(const Key('hide-confirm')));
      await settle(tester);
    }, () => client);
    expect(hidden, ['Abusive language']);
    expect(find.text('No reviews here'), findsOneWidget);
  });
}
