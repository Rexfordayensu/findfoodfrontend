import 'dart:convert';
import 'dart:typed_data';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/order_tracking_screen.dart';
import 'package:findfood_app/services/order_payment.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/doorstep.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

Map<String, dynamic> orderJson({String status = 'out_for_delivery', String? code,
        String? doorstep, bool? sealed = true}) =>
    {
      'id': 12, 'total_amount': 4500, 'status': status, 'restaurant_id': 3, 'user_id': 7,
      'restaurant_name': 'Mama Yaa', 'fulfillment_method': 'delivery', 'rider_id': 2,
      'rider_name': 'Kofi', 'sealed': sealed, 'doorstep_check': doorstep,
      'delivery_code': code,
      'items': [
        {'menu_item_id': 1, 'quantity': 1, 'name': 'Jollof rice', 'price': 3500},
        {'menu_item_id': 2, 'quantity': 1, 'name': 'Boiled egg', 'price': 1000},
      ],
    };

Future<AuthProvider> signIn(String role) async {
  FlutterSecureStorage.setMockInitialValues({});
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 7, role: role, name: 'Ama');
  return auth;
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
  });

  Future<void> pumpTracking(WidgetTester tester, Map<String, dynamic> order,
      http.Client client) async {
    final auth = await signIn('customer');
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(home: OrderTrackingScreen(order: Order.fromJson(order))),
      ));
      await settle(tester);
    }, () => client);
  }

  testWidgets('the code only shows after the customer ticks every item and the seal',
      (tester) async {
    Map<String, dynamic>? sent;
    final client = MockClient((request) async {
      if (request.url.path == '/orders/12/doorstep-check') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return json(orderJson(code: '4821', doorstep: 'all_there'));
      }
      if (request.url.path == '/orders') return json([orderJson()]);
      return json([]);
    });
    await pumpTracking(tester, orderJson(), client);

    expect(find.byKey(const Key('doorstep-check')), findsOneWidget);
    expect(find.text('4821'), findsNothing);
    final button = find.byKey(const Key('doorstep-all-there'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(sent, isNull, reason: 'nothing ticked yet');

    await http.runWithClient(() async {
      await tester.tap(find.byKey(const Key('doorstep-item-0')));
      await tester.tap(find.byKey(const Key('doorstep-item-1')));
      await tester.pump();
      await tester.tap(button);
      await tester.pump();
      expect(sent, isNull, reason: 'the seal must be checked too');
      await tester.tap(find.byKey(const Key('doorstep-seal')));
      await tester.pump();
      await tester.tap(button);
      await settle(tester);
    }, () => client);

    expect(sent, {'all_there': true});
    expect(find.byKey(const Key('doorstep-check')), findsNothing);
    expect(find.byKey(const Key('tracking-delivery-code')), findsOneWidget);
  });

  testWidgets('flagging a problem at the door still gives the code, with a note',
      (tester) async {
    Map<String, dynamic>? sent;
    final client = MockClient((request) async {
      if (request.url.path == '/orders/12/doorstep-check') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return json(orderJson(code: '4821', doorstep: 'problem'));
      }
      return json([]);
    });
    await pumpTracking(tester, orderJson(), client);
    await http.runWithClient(() async {
      final flag = find.byKey(const Key('doorstep-problem'));
      await tester.ensureVisible(flag);
      await tester.tap(flag);
      await settle(tester);
      await tester.tap(find.byKey(const Key('doorstep-problem-confirm')));
      await settle(tester);
    }, () => client);
    expect(sent, {'all_there': false});
    expect(find.byKey(const Key('doorstep-flagged')), findsOneWidget);
    expect(find.byKey(const Key('tracking-delivery-code')), findsOneWidget);
  });

  testWidgets('before the food is on its way, the code is explained, not shown',
      (tester) async {
    await pumpTracking(tester, orderJson(status: 'preparing'), MockClient((_) async => json([])));
    expect(find.byKey(const Key('code-coming')), findsOneWidget);
    expect(find.byKey(const Key('doorstep-check')), findsNothing);
  });

  testWidgets('the kitchen adds a packing photo and the seal before marking ready',
      (tester) async {
    final auth = await signIn('restaurant');
    var uploads = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/orders/12/pack-photo') {
        uploads++;
        return json({'packed_photo_url': 'https://cdn.test/pack_photos/order_12_a.jpg'});
      }
      return json({});
    });
    pickPackPhoto = () async => (bytes: Uint8List.fromList([1, 2, 3]), name: 'pack.jpg');
    bool? result;
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    result = await showPackSheet(context, Order.fromJson(orderJson(status: 'preparing'))),
                child: const Text('Mark ready'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Mark ready'));
      await settle(tester);
      expect(find.text('1× Jollof rice · 1× Boiled egg'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pack-photo')));
      await settle(tester);
      expect(find.text('Photo added'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pack-ready')));
      await settle(tester);
    }, () => client);
    expect(uploads, 1);
    expect(result, isTrue, reason: 'sealed is ticked by default');
  });

  testWidgets('the restaurant answers a report about its order', (tester) async {
    final auth = await signIn('restaurant');
    Map<String, dynamic>? answer;
    final client = MockClient((request) async {
      if (request.url.path == '/restaurants/mine/issues') {
        return json([
          {'id': 5, 'order_id': 12, 'reason': 'missing_item', 'reason_label': 'Missing item',
           'details': 'No egg', 'status': 'open', 'restaurant_response': null,
           'items': [{'name': 'Boiled egg', 'quantity': 1}]},
        ]);
      }
      if (request.url.path == '/issues/5/restaurant-response') {
        answer = jsonDecode(request.body) as Map<String, dynamic>;
        return json({'id': 5});
      }
      return json([]);
    });
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: RestaurantIssuesBanner())),
      ));
      await settle(tester);
      expect(find.text('1 problem report to answer'), findsOneWidget);
      await tester.tap(find.byKey(const Key('restaurant-issues')));
      await settle(tester);
      expect(find.text('“No egg”'), findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('restaurant-issue-note-5')), 'Egg was in a side bowl');
      await tester.tap(find.byKey(const Key('restaurant-issue-packed-5')));
      await settle(tester);
    }, () => client);
    expect(answer, {'response': 'packed', 'note': 'Egg was in a side bowl'});
    expect(find.textContaining('You said it was packed'), findsOneWidget);
  });

  testWidgets('credit that covers the order pays for it without a payment page',
      (tester) async {
    final auth = await signIn('customer');
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add(request.url.path);
      if (request.url.path == '/me/credit') return json({'balance': 6000, 'entries': []});
      if (request.url.path == '/payments/initialize') {
        return json({'paid': true, 'reference': 'CRD-1', 'amount': 0, 'order_id': 12,
            'provider': 'credit', 'credit_applied': 4500}, 201);
      }
      return json([]);
    });
    bool? paid;
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    paid = await OrderPayment.start(context, Order.fromJson(orderJson(status: 'awaiting_payment'))),
                child: const Text('Pay'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Pay'));
      await settle(tester);
    }, () => client);
    expect(paid, isTrue);
    expect(calls, ['/me/credit', '/payments/initialize'],
        reason: 'no payment method to choose, no redirect');
  });
}
