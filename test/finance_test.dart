import 'dart:convert';

import 'package:findfood_app/screens/admin/finance_page.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('finance shows the period figures and switches ranges', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 1, role: 'admin', name: 'Rex');
    final asked = <String>[];
    final client = MockClient((request) async {
      asked.add(request.url.query);
      return http.Response(jsonEncode({
        'orders': 12, 'customers_paid': 72000, 'credit_used': 1500, 'food_sales': 60000,
        'delivery_fees': 12000, 'commission': 9000, 'paid_to_restaurants_automatically': 51000,
        'owed_to_restaurants': 0, 'rider_pay_earned': 11000, 'rider_pay_paid': 8000,
        'refunds_to_cards': 1000, 'refunds_as_credit': 500, 'findfood_estimate': 8500,
        'daily': [{'date': '2026-10-15', 'orders': 5, 'customers_paid': 30000},
                  {'date': '2026-10-16', 'orders': 7, 'customers_paid': 42000}],
      }), 200, headers: {'content-type': 'application/json'});
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(home: Scaffold(body: FinancePage(today: DateTime(2026, 10, 16)))),
      ));
      await settle(tester);
      expect(asked.last, 'start=2026-09-17&end=2026-10-16');
      expect(find.text('GH₵ 720.00'), findsOneWidget);
      expect(find.text('12 orders · GH₵ 15.00 of it in FindFood credit'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('finance-estimate')), matching: find.text('GH₵ 85.00')),
          findsOneWidget);
      expect(find.text('10/16'), findsOneWidget);
      await tester.tap(find.byKey(const Key('finance-range-last_month')));
      await settle(tester);
    }, () => client);
    expect(asked.last, 'start=2026-09-01&end=2026-09-30');
  });
}
