import 'dart:convert';

import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/rating_sheet.dart';
import 'package:findfood_app/widgets/reviews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Order deliveredOrder() => Order(
      id: 9, totalAmount: 5000, status: 'delivered', restaurantId: 3, userId: 7,
      restaurantName: 'Mama Yaa', fulfillmentMethod: 'delivery',
    );

Restaurant restaurant({double? rating, int count = 0}) => Restaurant(
      id: 3, name: 'Mama Yaa', cuisineType: 'Local', address: 'Accra',
      email: 'k@example.com', isActive: true, isApproved: true, ownerId: 1,
      averageRating: rating, ratingCount: count,
    );

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  test('a score appears only once there are enough reviews', () {
    expect(restaurant().ratingLabel, 'New');
    expect(restaurant(rating: 2.0, count: 2).ratingLabel, 'New');
    expect(restaurant(rating: 4.6, count: 5).ratingLabel, '4.6 (5)');
  });

  Future<Map<String, dynamic>?> rate(WidgetTester tester, int stars,
      {List<String> tap = const []}) async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.login(token: 't', userId: 7, role: 'customer', name: 'Ama');
    Map<String, dynamic>? sent;
    final client = MockClient((request) async {
      sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response('{"message":"ok"}', 201,
          headers: {'content-type': 'application/json'});
    });
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showRateOrderSheet(context, deliveredOrder()),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('rate-restaurant-$stars')));
      await tester.tap(find.byKey(const Key('rate-rider-4')));
      await tester.pumpAndSettle();
      for (final tag in tap) {
        await tester.tap(find.byKey(Key('issue-$tag')));
        await tester.pump();
      }
      await tester.ensureVisible(find.byKey(const Key('rate-submit')));
      await tester.tap(find.byKey(const Key('rate-submit')));
      await tester.pumpAndSettle();
    }, () => client);
    return sent;
  }

  testWidgets('a low rating asks what went wrong and sends it', (tester) async {
    final sent = await rate(tester, 2, tap: ['wrong_item', 'late']);
    expect(sent!['restaurant_rating'], 2);
    expect(List<String>.from(sent['issues'] as List)..sort(), ['late', 'wrong_item']);
  });

  testWidgets('a good rating does not ask about problems', (tester) async {
    final sent = await rate(tester, 5);
    expect(find.text('What went wrong?'), findsNothing);
    expect(sent!.containsKey('issues'), isFalse);
  });

  testWidgets('reviews show the verified label, stars and kitchen problems',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ReviewsSection(reviews: [
            Review.fromJson({
              'id': 1, 'rating': 2, 'comment': 'Got jollof instead of waakye',
              'issues': ['wrong_item'], 'reviewer': 'Ama M.', 'verified': true,
              'created_at': DateTime.now().toUtc().toIso8601String(),
            }),
          ]),
        ),
      ),
    ));
    expect(find.text('What customers say'), findsOneWidget);
    expect(find.text('Ama M.'), findsOneWidget);
    expect(find.text('Verified order'), findsOneWidget);
    expect(find.text('Got jollof instead of waakye'), findsOneWidget);
    expect(find.text('Wrong item'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
  });

  testWidgets('no reviews yet invites the first one', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ReviewsSection(reviews: []))));
    expect(find.text('No reviews yet'), findsOneWidget);
  });
}
