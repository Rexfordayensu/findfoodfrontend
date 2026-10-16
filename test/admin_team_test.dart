import 'dart:convert';

import 'package:findfood_app/screens/admin/admin_dashboard.dart';
import 'package:findfood_app/screens/admin/team_page.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<AuthProvider> owner(WidgetTester tester) async {
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = const Size(430, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 1, role: 'admin', name: 'Rexford');
  return auth;
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  test('admins only see the pages their role allows', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 2, role: 'admin', name: 'Kojo');
    expect(auth.can('commission'), isTrue, reason: 'role unknown yet: the server decides');
    auth.applyAdminFields({'admin_role': 'support', 'permissions': ['view', 'orders', 'reports']});
    expect(auth.adminRoleLabel, 'Support');
    expect(auth.can('reports'), isTrue);
    expect(auth.can('commission'), isFalse);
    expect(auth.can('team'), isFalse);
    final visible = adminDestinations
        .where((d) => d.permission == null || auth.can(d.permission!))
        .map((d) => d.key);
    expect(visible, ['overview', 'riders', 'users', 'reports', 'settings']);
    auth.applyAdminFields({'admin_role': 'owner', 'permissions': ['view']});
    expect(auth.can('team'), isTrue, reason: 'owners can do everything');
  });

  testWidgets('the owner invites a support admin', (tester) async {
    final auth = await owner(tester);
    Map<String, dynamic>? invited;
    var members = [
      {'id': 1, 'name': 'Rexford', 'email': 'rex@example.com', 'admin_role': 'owner',
       'is_active': true, 'invited': false},
    ];
    final client = MockClient((request) async {
      if (request.url.path == '/admin/team/invite') {
        invited = jsonDecode(request.body) as Map<String, dynamic>;
        members = [...members, {'id': 9, 'name': 'Kojo', 'email': 'kojo@example.com',
            'admin_role': 'support', 'is_active': true, 'invited': true}];
        return json(members.last);
      }
      return json({'members': members, 'roles': [], 'support_refund_limit': 20000});
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: TeamPage())),
      ));
      await settle(tester);
      expect(find.text('Rexford (you)'), findsOneWidget);
      expect(find.textContaining('up to GH₵ 200.00'), findsOneWidget);
      await tester.tap(find.byKey(const Key('team-invite')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('invite-name')), 'Kojo');
      await tester.enterText(find.byKey(const Key('invite-email')), 'kojo@example.com');
      await tester.tap(find.byKey(const Key('role-support')));
      await tester.tap(find.byKey(const Key('invite-send')));
      await settle(tester);
    }, () => client);
    expect(invited, {'name': 'Kojo', 'email': 'kojo@example.com', 'admin_role': 'support'});
    expect(find.text("Invited · hasn't set a password yet"), findsOneWidget);
  });

  testWidgets('the activity log shows who did what', (tester) async {
    final auth = await owner(tester);
    final client = MockClient((request) async => json([
          {'id': 3, 'action': 'commission.change', 'summary': 'Commission changed to 12%',
           'admin_name': 'Rexford', 'admin_role': 'owner',
           'created_at': DateTime.now().toUtc().toIso8601String()},
        ]));
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: ActivityLogPage())),
      ));
      await settle(tester);
    }, () => client);
    expect(find.text('Commission changed to 12%'), findsOneWidget);
    expect(find.text('Rexford (Owner) · just now'), findsOneWidget);
  });
}
