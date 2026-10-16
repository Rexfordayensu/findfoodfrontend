import 'dart:convert';

import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/announcement_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('an unseen announcement pops up until "Got it"', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    final opened = <String>[];
    var seen = false;
    final client = MockClient((request) async {
      if (request.url.path == '/announcements/unseen') {
        return json(seen
            ? []
            : [{'id': 7, 'notification_id': 3, 'kind': 'important', 'title': 'Heavy rain today',
                'body': 'Deliveries may take longer.', 'created_at': DateTime.now().toUtc().toIso8601String()}]);
      }
      opened.add(request.url.path);
      seen = true;
      return json({'id': 7});
    });
    final navigatorKey = GlobalKey<NavigatorState>();
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) => AnnouncementGate(navigatorKey: navigatorKey, child: child!),
          home: const Scaffold(body: Text('Orders page')),
        ),
      ));
      await settle(tester);
      expect(find.byKey(const Key('announcement-banner')), findsNothing, reason: 'signed out');
      await auth.login(token: 't', userId: 4, role: 'restaurant', name: 'Esi');
      await settle(tester);
      expect(find.byKey(const Key('announcement-banner')), findsOneWidget);
      expect(find.text('Heavy rain today'), findsOneWidget);
      expect(find.text('IMPORTANT · FROM FINDFOOD'), findsOneWidget);
      await tester.tap(find.byKey(const Key('announcement-got-it')));
      await settle(tester);
    }, () => client);
    expect(opened, ['/announcements/7']);
    expect(find.byKey(const Key('announcement-banner')), findsNothing);
    expect(find.text('Orders page'), findsOneWidget);
  });
}
