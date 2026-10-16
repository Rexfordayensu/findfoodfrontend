import 'dart:convert';

import 'package:findfood_app/screens/admin/broadcast_page.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/platform_banner.dart';
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

Future<AuthProvider> admin(WidgetTester tester) async {
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = const Size(430, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 1, role: 'admin', name: 'Rex');
  return auth;
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('an admin sends news to customers', (tester) async {
    final auth = await admin(tester);
    Map<String, dynamic>? sent;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return json({'id': 1, 'sent_to': 41}, 201);
      }
      return json({
        'reach': {
          'customers': {'news': 41, 'important': 45}, 'riders': {'news': 5, 'important': 5},
          'restaurants': {'news': 3, 'important': 3}, 'everyone': {'news': 49, 'important': 53},
        },
        'history': [],
      });
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: AnnouncementsPage())),
      ));
      await settle(tester);
      expect(find.text('Send to 41 people'), findsOneWidget);
      await tester.tap(find.text('Important'));
      await settle(tester);
      expect(find.text('Send to 45 people'), findsOneWidget);
      await tester.tap(find.text('Offers & news'));
      await tester.enterText(find.byKey(const Key('announce-title')), 'Free delivery this weekend');
      await tester.enterText(find.byKey(const Key('announce-body')), 'Use code WEEKEND.');
      await settle(tester);
      expect(find.byKey(const Key('announce-preview')), findsOneWidget);
      await tester.tap(find.byKey(const Key('announce-send')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('announce-confirm')));
      await settle(tester);
    }, () => client);
    expect(sent, {'audience': 'customers', 'kind': 'news',
        'title': 'Free delivery this weekend', 'body': 'Use code WEEKEND.'});
  });

  testWidgets('an admin pauses delivery', (tester) async {
    final auth = await admin(tester);
    Map<String, dynamic>? saved;
    var settings = <String, dynamic>{
      'ordering_paused': false, 'delivery_paused': false, 'pause_message': '', 'hours_enabled': false,
      'opens_at': '08:00', 'closes_at': '22:00', 'max_delivery_km': null,
    };
    final client = MockClient((request) async {
      if (request.method == 'PUT') {
        saved = jsonDecode(request.body) as Map<String, dynamic>;
        settings = saved!;
      }
      return json({
        'settings': settings,
        'status': {'ordering_open': true, 'delivery_open': settings['delivery_paused'] != true},
        'history': [],
      });
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: PlatformPage())),
      ));
      await settle(tester);
      expect(find.text('Right now: open for ordering and delivery.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('platform-delivery_paused')));
      await tester.enterText(find.byKey(const Key('platform-message')), 'Heavy rain: back soon.');
      await tester.enterText(find.byKey(const Key('platform-km')), '8');
      await tester.tap(find.byKey(const Key('platform-save')));
      await settle(tester);
    }, () => client);
    expect(saved!['delivery_paused'], true);
    expect(saved!['pause_message'], 'Heavy rain: back soon.');
    expect(saved!['max_delivery_km'], 8.0);
    expect(find.text('Right now: pickup only. Delivery is paused.'), findsOneWidget);
  });

  testWidgets('customers see why they cannot order', (tester) async {
    final client = MockClient((request) async => json({
          'ordering_open': false, 'delivery_open': false,
          'message': "We're closed right now. Ordering opens at 08:00.",
        }));
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PlatformStatusBanner())));
      await settle(tester);
    }, () => client);
    expect(find.text("We're closed right now. Ordering opens at 08:00."), findsOneWidget);
  });
}
