import 'dart:convert';

import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/payouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  Future<void> pump(WidgetTester tester, Widget child) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 3, role: 'restaurant', name: 'Esi');
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    ));
    await settle(tester);
  }

  testWidgets('a restaurant adds its mobile money account for payouts', (tester) async {
    Map<String, dynamic>? saved;
    var active = false;
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/restaurants/mine/payout':
          if (request.method == 'PUT') {
            saved = jsonDecode(request.body) as Map<String, dynamic>;
            active = true;
            return json({'active': true, 'type': 'momo', 'provider_name': 'MTN Mobile Money',
                'account_last4': '4567', 'account_name': 'ESI MENSAH',
                'commission_percent': 15, 'share_percent': 85});
          }
          return json({'active': active, 'commission_percent': 15, 'share_percent': 85});
        case '/payouts/providers':
          return json(request.url.queryParameters['type'] == 'momo'
              ? [{'code': 'MTN', 'name': 'MTN Mobile Money'}, {'code': 'VOD', 'name': 'Telecel Cash'}]
              : [{'code': 'GCB', 'name': 'GCB Bank'}]);
      }
      return json({});
    });
    await http.runWithClient(() async {
      await pump(tester, const PayoutReminderBanner());
      expect(find.byKey(const Key('payout-reminder')), findsOneWidget);
      await tester.tap(find.byKey(const Key('payout-reminder')));
      await settle(tester);
      expect(find.text('You receive 85% of every order, paid automatically by Paystack.'),
          findsOneWidget);

      // Missing details are caught before sending.
      await tester.tap(find.byKey(const Key('payout-save')));
      await settle(tester);
      expect(saved, isNull);
      expect(find.text('Choose your network.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('payout-provider')));
      await settle(tester);
      await tester.tap(find.text('MTN Mobile Money').last);
      await settle(tester);
      await tester.enterText(find.byKey(const Key('payout-number')), '024 123 4567');
      await tester.tap(find.byKey(const Key('payout-save')));
      await settle(tester);
    }, () => client);
    expect(saved, {'type': 'momo', 'provider_code': 'MTN', 'account_number': '024 123 4567'});
    expect(find.byKey(const Key('payout-reminder')), findsNothing, reason: 'payouts are set up');
  });

  testWidgets('switching to bank shows banks', (tester) async {
    final client = MockClient((request) async => request.url.path == '/payouts/providers'
        ? json(request.url.queryParameters['type'] == 'bank'
            ? [{'code': 'GCB', 'name': 'GCB Bank'}]
            : [{'code': 'MTN', 'name': 'MTN Mobile Money'}])
        : json({'active': false}));
    await http.runWithClient(() async {
      await pump(tester, Builder(
        builder: (context) => TextButton(
            onPressed: () => showPayoutSheet(context), child: const Text('Open')),
      ));
      await tester.tap(find.text('Open'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('payout-type-bank')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('payout-provider')));
      await settle(tester);
      expect(find.text('GCB Bank'), findsWidgets);
    }, () => client);
  });

  testWidgets('earnings show the 85% share, what was paid and what is owed', (tester) async {
    await pump(tester, EarningsSplitCard(
      onSetUpPayouts: () {},
      data: const {
        'total_revenue': 10000, 'your_earnings': 8500, 'paid_automatically': 4250,
        'owed_by_findfood': 4250, 'delivered_orders': 2,
        'payout': {'active': true, 'provider_name': 'MTN Mobile Money', 'account_last4': '4567',
                   'commission_percent': 15, 'share_percent': 85},
      },
    ));
    expect(find.text('Your earnings · 85% of sales'), findsOneWidget);
    expect(find.text('GH₵ 85.00'), findsOneWidget);
    expect(find.text('−GH₵ 15.00'), findsOneWidget);
    expect(find.text('Paid to MTN Mobile Money ••4567'), findsOneWidget);
    expect(find.text('FindFood owes you'), findsOneWidget);
    expect(find.byKey(const Key('earnings-setup-payouts')), findsNothing);
  });

  testWidgets('without a payout account, earnings invite setting one up', (tester) async {
    var opened = 0;
    await pump(tester, EarningsSplitCard(
      onSetUpPayouts: () => opened++,
      data: const {'total_revenue': 5000, 'your_earnings': 4250, 'paid_automatically': 0,
          'owed_by_findfood': 4250, 'payout': {'active': false, 'share_percent': 85,
          'commission_percent': 15}},
    ));
    await tester.tap(find.byKey(const Key('earnings-setup-payouts')));
    expect(opened, 1);
  });
}
