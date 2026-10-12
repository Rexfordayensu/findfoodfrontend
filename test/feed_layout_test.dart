import 'dart:convert';

import 'package:findfood_app/screens/customer/food_feed_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/promotion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Map<String, dynamic> restaurant(int id, String name,
        {bool open = true, double? rating}) =>
    {
      'id': id,
      'name': name,
      'cuisine_type': 'Local',
      'address': 'Osu, Accra',
      'email': 'r$id@example.com',
      'is_active': true,
      'is_approved': true,
      'owner_id': 1,
      'is_open': open,
      'average_rating': rating,
      'rating_count': rating == null ? 0 : 12,
    };

void main() {
  setUpAll(() {
    AuthProvider.refreshInterval = null;
    PromotionCarousel.autoAdvanceEvery = null; // this test only checks sizing
  });

  for (final signedIn in [false, true]) {
    for (final width in [320.0, 375.0, 430.0, 1280.0]) {
      testWidgets(
          'feed fits at ${width.toInt()}px wide (${signedIn ? 'signed in' : 'guest'})',
          (tester) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        FlutterSecureStorage.setMockInitialValues({});
        final auth = AuthProvider();
        if (signedIn) {
          await auth.login(
              token: 't',
              userId: 1,
              role: 'customer',
              name: 'Ama Customer With A Long Name');
        }

        final client = MockClient((request) async {
          if (request.url.path == '/restaurants') {
            return http.Response(
              jsonEncode([
                restaurant(1, "Mama's Kitchen with a fairly long name",
                    open: false, rating: 4.6),
                restaurant(2, 'Short', rating: null),
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.url.path == '/promotions') {
            return http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'restaurant_id': 1,
                  'restaurant_name': "Mama's Kitchen with a fairly long name",
                  'title': 'Christmas Promo with a long headline',
                  'image_url': null,
                  'discount_percent': 20,
                  'is_active': true,
                  'created_at': '2026-10-12T10:00:00Z',
                },
                {
                  'id': 2,
                  'restaurant_id': 2,
                  'restaurant_name': 'Short',
                  'title': 'Lunch deal',
                  'image_url': null,
                  'discount_percent': null,
                  'is_active': true,
                  'created_at': '2026-10-12T10:00:00Z',
                },
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('[]', 200,
              headers: {'content-type': 'application/json'});
        });

        await http.runWithClient(() async {
          final router = GoRouter(routes: [
            GoRoute(
                path: '/',
                builder: (_, __) => const FoodFeedScreen(initialNavIndex: 0)),
          ]);
          await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider.value(value: auth),
              ChangeNotifierProvider(create: (_) => CartProvider()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ));
          for (var i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
        }, () => client);

        expect(find.text('Deals for you'), findsOneWidget);
        expect(find.text('20% OFF'), findsOneWidget);
        expect(find.text('Closed'), findsOneWidget);
        expect(find.text('4.6 (12)'), findsOneWidget);
        expect(find.text('New'), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Header actions must be reachable inside the screen.
        final action = find.byTooltip(signedIn ? 'Profile' : 'Sign in');
        final rect = tester.getRect(action);
        expect(rect.right, lessThanOrEqualTo(width),
            reason: 'header action at $rect on a ${width}px screen');
      });
    }
  }
}
