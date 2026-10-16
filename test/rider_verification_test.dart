import 'dart:convert';

import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/rider_verification.dart';
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

Future<AuthProvider> signIn(WidgetTester tester, String role) async {
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = const Size(430, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthProvider();
  await auth.login(token: 't', userId: 5, role: role, name: 'Yaw Boateng');
  return auth;
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('a new rider sends their details for approval', (tester) async {
    final auth = await signIn(tester, 'rider');
    Map<String, dynamic>? sent;
    var data = <String, dynamic>{'status': 'unsubmitted', 'can_work': false, 'missing': <String>[]};
    final client = MockClient((request) async {
      if (request.method == 'PUT') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        data = {...data, 'status': 'pending', 'vehicle': 'motorbike'};
      }
      return json(data);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(builder: (context, setState) => RiderVerificationPanel(
                data: data, onChanged: (d) => setState(() => data = d))),
          ),
        ),
      ));
      await settle(tester);
      expect(find.text('Riders are checked before their first job'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('verify-card')), 'GHA-123456789-0');
      await tester.enterText(find.byKey(const Key('verify-licence')), 'DL12345');
      await tester.enterText(find.byKey(const Key('verify-plate')), 'GR 1234-24');
      await tester.enterText(find.byKey(const Key('verify-emergency-name')), 'Akos');
      await tester.enterText(find.byKey(const Key('verify-emergency-phone')), '0245550000');
      await tester.tap(find.byKey(const Key('verify-submit')));
      await settle(tester);
    }, () => client);
    expect(sent!['ghana_card'], 'GHA-123456789-0');
    expect(sent!['vehicle'], 'motorbike');
    expect(find.byKey(const Key('verification-pending')), findsOneWidget);
  });

  testWidgets('without a photo and phone, sending waits', (tester) async {
    final auth = await signIn(tester, 'rider');
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(
        home: Scaffold(
          body: RiderVerificationPanel(
            data: const {'status': 'rejected', 'can_work': false, 'missing': ['phone', 'photo'],
                'rejection_reason': 'The plate number does not match'},
            onChanged: (_) {},
          ),
        ),
      ),
    ));
    await settle(tester);
    expect(find.textContaining('The plate number does not match'), findsOneWidget);
    expect(find.text('Add your photo and phone number first (steps 1 and 2).'), findsOneWidget);
  });

  testWidgets('an admin approves a rider', (tester) async {
    final auth = await signIn(tester, 'admin');
    final approved = <String>[];
    var riders = [
      {'rider_id': 7, 'name': 'Yaw', 'email': 'y@x.com', 'phone': '024 111 2222', 'status': 'pending',
       'ghana_card': 'GHA-123456789-0', 'vehicle': 'motorbike', 'vehicle_label': 'Motorbike',
       'plate': 'GR 1234-24', 'licence_number': 'DL12345', 'emergency_name': 'Akos',
       'emergency_phone': '0245550000'},
    ];
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/approve')) {
        approved.add(request.url.path);
        riders = [];
      }
      return json(riders);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: RiderApprovalsPage())),
      ));
      await settle(tester);
      expect(find.text('GHA-123456789-0'), findsOneWidget);
      await tester.tap(find.byKey(const Key('rider-approve-7')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('rider-approve-confirm')));
      await settle(tester);
    }, () => client);
    expect(approved, ['/admin/riders/7/approve']);
    expect(find.text('No riders waiting'), findsOneWidget);
  });
}
