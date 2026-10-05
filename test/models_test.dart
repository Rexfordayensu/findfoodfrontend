import 'package:flutter_test/flutter_test.dart';
import 'package:findfood_app/models/models.dart';

void main() {
  group('model parsing', () {
    test('parses restaurant approval state from backend payload', () {
      final restaurant = Restaurant.fromJson({
        'id': 7,
        'name': 'Mama’s Kitchen',
        'cuisine_type': 'Ghanaian',
        'address': 'Accra',
        'email': 'mama@example.com',
        'is_active': true,
        'is_approved': false,
        'owner_id': 12,
      });

      expect(restaurant.isApproved, isFalse);
      expect(restaurant.ownerId, 12);
    });

    test('serializes payment initialization payload without email or phone number', () {
      final request = PaymentInitializationRequest(orderId: 123, provider: 'paystack');
      final payload = request.toJson();

      expect(payload, {
        'order_id': 123,
        'provider': 'paystack',
      });
      expect(payload.containsKey('email'), isFalse);
      expect(payload.containsKey('phone_number'), isFalse);
    });

    test('parses analytics fields returned by backend endpoints', () {
      final restaurant = RestaurantAnalytics.fromJson({
        'total_orders': 5,
        'delivered_orders': 3,
        'total_revenue': 9000,
        'avg_order_value': 3000,
        'top_items': [
          {'name': 'Jollof', 'count': 4},
        ],
        'daily_revenue': [
          {'day': 'Mon', 'revenue': 1000},
        ],
      });
      final rider = RiderAnalytics.fromJson({
        'total_deliveries': 4,
        'completed_deliveries': 3,
        'total_earnings': 1200,
        'avg_earning_per_delivery': 400,
      });

      expect(restaurant.averageOrderValue, 3000);
      expect(restaurant.bestSellers.single.quantitySold, 4);
      expect(rider.averageEarningPerDelivery, 400);
    });

    test('parses the restaurant name included in an order response', () {
      final order = Order.fromJson({
        'id': 9,
        'total_amount': 2500,
        'status': 'pending',
        'restaurant_id': 4,
        'restaurant_name': 'Test Kitchen',
        'user_id': 2,
        'fulfillment_method': 'pickup',
      });

      expect(order.restaurantName, 'Test Kitchen');
    });
  });
}
