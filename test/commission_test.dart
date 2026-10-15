import 'dart:convert';

import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/commission.dart';
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

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('an admin changes the commission after confirming', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'admin', name: 'Ade');
    Map<String, dynamic>? sent;
    var state = <String, dynamic>{
      'percent': 15, 'share_percent': 85, 'default_percent': 15, 'max_percent': 40,
      'history': <Map<String, dynamic>>[],
    };
    final client = MockClient((request) async {
      if (request.method == 'PUT') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        state = {
          ...state, 'percent': 10, 'share_percent': 90,
          'history': [{'percent': 10, 'previous_percent': 15, 'changed_by': 'Ade',
                       'changed_at': DateTime.now().toUtc().toIso8601String()}],
        };
      }
      return json(state);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: CommissionPage())),
      ));
      await settle(tester);
      expect(find.byKey(const Key('commission-current')), findsOneWidget);
      expect(find.text('restaurants receive 85%'), findsOneWidget);
      expect(find.textContaining('Unchanged since launch'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('commission-field')), '10');
      await tester.pump();
      expect(find.text('GH₵ 45.00'), findsOneWidget, reason: 'the restaurant on a GH₵ 50 order');
      expect(find.text('GH₵ 5.00'), findsOneWidget);
      await tester.tap(find.byKey(const Key('commission-save')));
      await settle(tester);
      expect(find.text('Change commission to 10%?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('commission-confirm')));
      await settle(tester);
    }, () => client);

    expect(sent, {'percent': 10.0});
    expect(find.text('restaurants receive 90%'), findsOneWidget);
    expect(find.text('15% → 10% by Ade'), findsOneWidget);
  });

  testWidgets('an admin gives one restaurant a special rate', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'admin', name: 'Ade');
    Map<String, dynamic>? sent;
    var restaurants = [
      {'id': 4, 'name': "Mama's Kitchen", 'special_percent': null, 'percent': 15,
       'payouts_active': true},
    ];
    final client = MockClient((request) async {
      if (request.url.path == '/admin/restaurants/4/commission') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        restaurants = [{...restaurants.first, 'special_percent': 10, 'percent': 10}];
      }
      return json({'percent': 15, 'share_percent': 85, 'default_percent': 15,
          'max_percent': 40, 'history': [], 'restaurants': restaurants,
          'special_history': []});
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: CommissionPage())),
      ));
      await settle(tester);
      expect(find.text('Standard · 15%'), findsOneWidget);
      await tester.scrollUntilVisible(find.byKey(const Key('restaurant-rate-4')), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byKey(const Key('restaurant-rate-4')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('rate-special-switch')));
      await settle(tester);
      // Drag the slider down to 10%.
      final slider = find.byKey(const Key('rate-slider'));
      final box = tester.getRect(slider);
      await tester.tapAt(Offset(box.left + 24 + (box.width - 48) * 10 / 40, box.center.dy));
      await settle(tester);
      expect(find.text('FindFood keeps 10% · the restaurant receives 90%'), findsOneWidget);
      await tester.tap(find.byKey(const Key('rate-save')));
      await settle(tester);
    }, () => client);
    expect(sent, {'percent': 10.0});
    expect(find.text('Special · 10%'), findsOneWidget);
  });

  test('percentages read naturally', () {
    expect(percentLabel(15), '15%');
    expect(percentLabel(12.5), '12.5%');
    expect(percentLabel(10.0), '10%');
  });
}
