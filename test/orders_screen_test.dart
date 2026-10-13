import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/screens/customer/customer_pages.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

Map<String, dynamic> line(int menuItemId, String name, int price, int qty,
        {bool available = true, String? image}) =>
    {
      'id': menuItemId * 10, 'menu_item_id': menuItemId, 'quantity': qty,
      'name': name, 'price': price, 'image_url': image,
      'is_available': available,
    };

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  testWidgets('previous orders show the dish photo and can be reordered',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.login(
        token: 't', userId: 7, role: 'customer', name: 'Ama',
        email: 'ama@example.com');
    final cart = CartProvider();

    final client = MockClient((request) async => json([
          {
            'id': 12, 'total_amount': 11000, 'status': 'delivered',
            'restaurant_id': 3, 'user_id': 7,
            'restaurant_name': 'Sweet Bite Foods',
            'fulfillment_method': 'delivery',
            'created_at': '2026-10-01T17:07:00Z', 'is_rated': true,
            'items': [
              line(1, 'Jollof', 4000, 2, image: 'https://img.test/jollof.jpg'),
              line(2, 'Kelewele', 3000, 1, available: false),
            ],
          },
        ]));

    final router = GoRouter(initialLocation: '/orders', routes: [
      GoRoute(path: '/orders', builder: (_, __) => const CustomerOrdersScreen()),
      GoRoute(path: '/cart', builder: (_, __) => const Text('cart page')),
    ]);

    await http.runWithClient(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: cart),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
    }, () => client);

    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('Sweet Bite Foods'), findsOneWidget);
    expect(find.textContaining('Delivered'), findsOneWidget);
    final photo = tester.widget<Image>(find.byType(Image));
    expect((photo.image as NetworkImage).url, 'https://img.test/jollof.jpg');

    await tester.tap(find.byKey(const Key('reorder-12')));
    await tester.pumpAndSettle();

    expect(find.text('cart page'), findsOneWidget);
    expect(cart.restaurantId, 3);
    expect(cart.restaurantName, 'Sweet Bite Foods');
    // The unavailable dish is left out; quantities are kept.
    expect(cart.items.map((i) => i.menuItem.name), ['Jollof']);
    expect(cart.items.single.quantity, 2);
    expect(cart.items.single.menuItem, isA<MenuItem>());
  });
}
