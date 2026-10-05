import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/cart_screen.dart';
import 'package:findfood_app/services/providers.dart';

void main() {
  testWidgets('pickup checkout shows restaurant address and contact form',
      (tester) async {
    final cart = CartProvider()
      ..addItem(
        MenuItem(
          id: 1,
          name: 'Test meal',
          price: 1200,
          isAvailable: true,
          restaurantId: 7,
        ),
        7,
        'Test Restaurant',
        restaurantAddress: '24 Market Road, Accra',
      );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: CartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery address'), findsOneWidget);
    expect(find.text('Pickup location'), findsNothing);

    await tester.tap(find.text('Pickup'));
    await tester.pumpAndSettle();

    expect(find.text('Delivery address'), findsNothing);
    expect(find.text('Pickup location'), findsOneWidget);
    expect(find.text('Collect from Test Restaurant'), findsOneWidget);
    expect(find.text('24 Market Road, Accra'), findsOneWidget);
    expect(find.text('Pickup name'), findsOneWidget);
    expect(find.text('Pickup phone number'), findsOneWidget);
    expect(find.text('Kitchen note (optional)'), findsOneWidget);
  });
}
