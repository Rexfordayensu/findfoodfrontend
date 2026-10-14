import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/menu_detail_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('a dish goes in the basket from the Add button or by tapping it', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cart = CartProvider();
    final client = MockClient((request) async {
      if (request.url.path == '/restaurants/3/menu') {
        return json([
          {'id': 1, 'name': 'Waakye and salad', 'price': 5000, 'restaurant_id': 3},
          {'id': 2, 'name': 'Fried rice', 'price': 6000, 'restaurant_id': 3},
        ]);
      }
      return json([]);
    });
    final restaurant = Restaurant.fromJson({
      'id': 3, 'name': "Mama's Kitchen", 'cuisine_type': 'Ghanaian', 'address': 'Osu',
      'email': 'm@example.com', 'is_approved': true, 'owner_id': 9,
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider.value(value: cart),
        ],
        child: MaterialApp(home: MenuDetailScreen(restaurant: restaurant)),
      ));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('menu-add-hint')), findsOneWidget);

      await tester.tap(find.byKey(const Key('menu-add-Waakye and salad')));
      // Let the "+ Add" finish fading into the stepper.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(cart.items.single.quantity, 1);
      expect(find.text('1 in your basket'), findsOneWidget);
      expect(find.byKey(const Key('menu-add-Waakye and salad')), findsNothing,
          reason: 'it becomes a − 1 + control');

      // Tapping the dish itself adds it too.
      await tester.tap(find.text('Fried rice'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(cart.items.map((l) => l.menuItem.id), containsAll([1, 2]));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    }, () => client);
  });
}
