class Restaurant {
  final int id;
  final String name;
  final String cuisineType;
  final String address;
  final String email;
  final bool isActive;
  final bool isApproved;
  final int ownerId;
  final String? imageUrl;
  final String? bannerUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.address,
    required this.email,
    required this.isActive,
    required this.isApproved,
    required this.ownerId,
    this.imageUrl,
    this.bannerUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'],
        name: json['name'],
        cuisineType: json['cuisine_type'],
        address: json['address'],
        email: json['email'],
        isActive: json['is_active'] ?? true,
        isApproved: json['is_approved'] ?? false,
        ownerId: json['owner_id'] ?? 0,
        imageUrl: json['image_url'],
        bannerUrl: json['banner_url'],
      );
}

class MenuItem {
  final int id;
  final String name;
  final String? description;
  final int price; // pesewas
  final bool isAvailable;
  final int restaurantId;
  final String?
      imageUrl; // NEW: uploaded photo path, e.g. /static/menu_images/xyz.jpg

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.isAvailable,
    required this.restaurantId,
    this.imageUrl,
  });

  /// Builds the full URL to display the uploaded image, or null if none set
  String? fullImageUrl(String baseUrl) {
    if (imageUrl == null) return null;
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl;
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = imageUrl!.startsWith('/') ? imageUrl! : '/$imageUrl';
    return '$normalizedBase$normalizedPath';
  }

  String get displayPrice => 'GH₵ ${(price / 100).toStringAsFixed(2)}';

  MenuItem copyWith({bool? isAvailable}) => MenuItem(
        id: id,
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable ?? this.isAvailable,
        restaurantId: restaurantId,
        imageUrl: imageUrl,
      );

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).round(),
        isAvailable: json['is_available'] ?? true,
        restaurantId: json['restaurant_id'],
        imageUrl: json['image_url'],
      );
}

class Order {
  final int id;
  final int totalAmount;
  final String status;
  final int restaurantId;
  final int userId;
  final String? restaurantName;
  final String fulfillmentMethod;
  final String? pickupName;
  final String? pickupPhone;
  final String? kitchenNote;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime? scheduledFor;

  Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.restaurantId,
    required this.userId,
    this.restaurantName,
    this.fulfillmentMethod = 'delivery',
    this.pickupName,
    this.pickupPhone,
    this.kitchenNote,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.scheduledFor,
  });

  String get displayTotal => 'GH₵ ${(totalAmount / 100).toStringAsFixed(2)}';

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        totalAmount: json['total_amount'],
        status: json['status'],
        restaurantId: json['restaurant_id'],
        userId: json['user_id'],
        restaurantName: json['restaurant_name'],
        fulfillmentMethod: json['fulfillment_method'] ?? 'delivery',
        pickupName: json['pickup_name'],
        pickupPhone: json['pickup_phone'],
        kitchenNote: json['kitchen_note'],
        deliveryAddress: json['delivery_address'],
        deliveryLatitude: (json['delivery_latitude'] as num?)?.toDouble(),
        deliveryLongitude: (json['delivery_longitude'] as num?)?.toDouble(),
        scheduledFor: json['scheduled_for'] == null
            ? null
            : DateTime.tryParse(json['scheduled_for'].toString()),
      );

  Order copyWith({
    int? id,
    String? status,
    int? totalAmount,
    int? restaurantId,
    int? userId,
    String? restaurantName,
    String? fulfillmentMethod,
    String? pickupName,
    String? pickupPhone,
    String? kitchenNote,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledFor,

    // You can add other fields here if you need to copy them later
  }) {
    return Order(
      id: id ?? this.id,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      restaurantName: restaurantName ?? this.restaurantName,
      fulfillmentMethod: fulfillmentMethod ?? this.fulfillmentMethod,
      pickupName: pickupName ?? this.pickupName,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      kitchenNote: kitchenNote ?? this.kitchenNote,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      // ... pass your other existing class fields here like:
      // total: total,
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  int get subtotal => menuItem.price * quantity;
  String get displaySubtotal => 'GH₵ ${(subtotal / 100).toStringAsFixed(2)}';
}

class PaymentInitializationRequest {
  final int orderId;
  final String provider;

  PaymentInitializationRequest({
    required this.orderId,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'provider': provider,
      };
}

// ─── CHAT MESSAGE ─────────────────────────────────────────────────────────────
class ChatMessage {
  final int id;
  final int orderId;
  final int senderId;
  final String senderRole;
  final String content;
  final DateTime createdAt;
  final bool isMine;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        orderId: json['order_id'],
        senderId: json['sender_id'],
        senderRole: json['sender_role'],
        content: json['content'] ?? json['message'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
        isMine: json['is_mine'] ?? false,
      );

}

// ─── ANALYTICS ────────────────────────────────────────────────────────────────
class BestSeller {
  final String name;
  final int quantitySold;

  BestSeller({required this.name, required this.quantitySold});

  factory BestSeller.fromJson(Map<String, dynamic> json) => BestSeller(
        name: json['name'] ?? 'Unknown',
      quantitySold: json['count'] ?? json['quantity_sold'] ?? 0,
      );
}

class DailyRevenue {
  final String day;
  final int revenue;

  DailyRevenue({required this.day, required this.revenue});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) => DailyRevenue(
        day: json['day'] ?? '',
        revenue: json['revenue'] ?? 0,
      );
}

class RestaurantAnalytics {
  final int totalOrders;
  final int deliveredOrders;
  final int totalRevenue;
  final int averageOrderValue;
  final List<BestSeller> bestSellers;
  final List<DailyRevenue> dailyRevenue;

  RestaurantAnalytics({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.bestSellers,
    required this.dailyRevenue,
  });

  String get displayRevenue => 'GH₵ ${(totalRevenue / 100).toStringAsFixed(2)}';
  String get displayAvgOrder =>
      'GH₵ ${(averageOrderValue / 100).toStringAsFixed(2)}';

  factory RestaurantAnalytics.fromJson(Map<String, dynamic> json) =>
      RestaurantAnalytics(
        totalOrders: json['total_orders'] ?? 0,
        deliveredOrders: json['delivered_orders'] ?? 0,
        totalRevenue: json['total_revenue'] ?? 0,
        averageOrderValue: json['avg_order_value'] ??
          json['average_order_value'] ??
          0,
        bestSellers: ((json['top_items'] ?? json['best_sellers'] ?? []) as List)
            .map((b) => BestSeller.fromJson(b))
            .toList(),
        dailyRevenue: ((json['daily_revenue'] ?? []) as List)
            .map((d) => DailyRevenue.fromJson(d))
            .toList(),
      );
}

class RiderAnalytics {
  final int totalDeliveries;
  final int completedDeliveries;
  final int totalEarnings;
  final int averageEarningPerDelivery;

  RiderAnalytics({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.totalEarnings,
    required this.averageEarningPerDelivery,
  });

  String get displayEarnings =>
      'GH₵ ${(totalEarnings / 100).toStringAsFixed(2)}';
  String get displayAvg =>
      'GH₵ ${(averageEarningPerDelivery / 100).toStringAsFixed(2)}';

  factory RiderAnalytics.fromJson(Map<String, dynamic> json) => RiderAnalytics(
        totalDeliveries: json['total_deliveries'] ?? 0,
        completedDeliveries: json['completed_deliveries'] ?? 0,
        totalEarnings: json['total_earnings'] ?? 0,
        averageEarningPerDelivery:
          json['avg_earning_per_delivery'] ??
            json['average_earning_per_delivery'] ??
            0,
      );
}

class Promotion {
  final int id;
  final int restaurantId;
  final String title;
  final String? description;
  final String imageUrl;
  final int? discountPercent;
  final bool isActive;

  const Promotion({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.imageUrl,
    this.description,
    this.discountPercent,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'],
        restaurantId: json['restaurant_id'],
        title: json['title'],
        description: json['description'],
        imageUrl: json['image_url'],
        discountPercent: json['discount_percent'],
        isActive: json['is_active'] ?? true,
      );
}

class PasswordResetException implements Exception {
  final String message;
  PasswordResetException(this.message);
  @override
  String toString() => message;
}
