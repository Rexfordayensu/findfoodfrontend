import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/order_tracking_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Order order(String status, {String method = 'pickup', DateTime? completedAt}) =>
    Order(
      id: 9,
      totalAmount: 15000,
      status: status,
      restaurantId: 1,
      userId: 7,
      fulfillmentMethod: method,
      completedAt: completedAt,
    );

Future<void> show(WidgetTester tester, Order order) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final requests = <String>[];
  await http.runWithClient(() async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(home: OrderTrackingScreen(order: order)),
    ));
    await tester.pump(const Duration(seconds: 5));
  }, () => MockClient((request) async {
        requests.add(request.url.path);
        return http.Response('[]', 200);
      }));
}

void main() {
  testWidgets('a picked-up order shows every step done, not in progress',
      (tester) async {
    await show(tester,
        order('picked_up', completedAt: DateTime(2026, 10, 13, 1, 5)));

    expect(find.text('In progress...'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(4));
    expect(find.text('Completed at 01:05'), findsOneWidget);
    expect(find.text('Live'), findsNothing);
    expect(find.text('Picked up'), findsWidgets);
  });

  testWidgets('a delivered order shows every step done', (tester) async {
    await show(tester, order('delivered', method: 'delivery'));

    expect(find.text('In progress...'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(5));
  });

  testWidgets('an order being prepared shows that step in progress',
      (tester) async {
    await show(tester, order('preparing'));

    expect(find.text('In progress...'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('a cancelled order has nothing in progress', (tester) async {
    await show(tester, order('cancelled'));

    expect(find.text('In progress...'), findsNothing);
    expect(find.text('Live'), findsNothing);
  });
}
