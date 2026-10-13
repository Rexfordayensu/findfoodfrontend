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
    // The kitchen note applies to delivery orders too.
    await tester.scrollUntilVisible(
        find.text('Kitchen note (optional)'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Kitchen note (optional)'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pickup'));
    await tester.pumpAndSettle();

    expect(find.text('Delivery address'), findsNothing);
    expect(find.text('Pickup location'), findsOneWidget);
    expect(find.text('Collect from Test Restaurant'), findsOneWidget);
    expect(find.text('24 Market Road, Accra'), findsOneWidget);
    expect(find.text('Pickup name'), findsOneWidget);
    expect(find.text('Pickup phone number'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('Kitchen note (optional)'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Kitchen note (optional)'), findsOneWidget);
    // Total and the order button stay pinned at the bottom.
    expect(find.text('Place order'), findsNothing); // signed out
    expect(find.text('Sign in to order'), findsOneWidget);
  });
}
