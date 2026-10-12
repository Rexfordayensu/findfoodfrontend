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
  final bool isOpen;
  final double? averageRating;
  final int ratingCount;

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
    this.isOpen = true,
    this.averageRating,
    this.ratingCount = 0,
  });

  /// "4.5 (12)" for rated restaurants, "New" otherwise.
  String get ratingLabel => averageRating == null
      ? 'New'
      : '${averageRating!.toStringAsFixed(1)} ($ratingCount)';

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
        isOpen: json['is_open'] ?? true,
        averageRating: (json['average_rating'] as num?)?.toDouble(),
        ratingCount: json['rating_count'] ?? 0,
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

  String get displayPrice => formatCedis(price);

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
  final DateTime? createdAt;
  final DateTime? completedAt;
  final int? riderId;
  final bool isRated;

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
    this.createdAt,
    this.completedAt,
    this.riderId,
    this.isRated = false,
  });

  bool get isCompleted => status == 'delivered' || status == 'picked_up';

  /// Customers can cancel until the kitchen starts cooking.
  bool get isCancellableByCustomer =>
      status == 'awaiting_payment' || status == 'pending';

  String get displayTotal => formatCedis(totalAmount);

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
        scheduledFor: _parseDate(json['scheduled_for']),
        createdAt: _parseDate(json['created_at']),
        completedAt: _parseDate(json['completed_at']),
        riderId: json['rider_id'],
        isRated: json['is_rated'] ?? false,
      );

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

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
    bool? isRated,
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
      createdAt: createdAt,
      completedAt: completedAt,
      riderId: riderId,
      isRated: isRated ?? this.isRated,
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  int get subtotal => menuItem.price * quantity;
  String get displaySubtotal => formatCedis(subtotal);
}

class PaymentProviderOption {
  final String value;
  final String label;
  final bool requiresPhone;

  const PaymentProviderOption({
    required this.value,
    required this.label,
    this.requiresPhone = false,
  });

  factory PaymentProviderOption.fromJson(Map<String, dynamic> json) =>
      PaymentProviderOption(
        value: json['value'],
        label: json['label'] ?? json['value'],
        requiresPhone: json['requires_phone'] ?? false,
      );
}

class PaymentInitializationRequest {
  final int orderId;
  final String provider;
  final String? callbackUrl;

  PaymentInitializationRequest({
    required this.orderId,
    required this.provider,
    this.callbackUrl,
  });

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'provider': provider,
        if (callbackUrl != null) 'callback_url': callbackUrl,
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
        createdAt: DateTime.parse(json['created_at']).toLocal(),
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

  String get displayRevenue => formatCedis(totalRevenue);
  String get displayAvgOrder =>
      formatCedis(averageOrderValue);

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

class RiderDelivery {
  final int orderId;
  final String? restaurantName;
  final String? deliveryAddress;
  final int earning;
  final DateTime? completedAt;

  RiderDelivery({
    required this.orderId,
    this.restaurantName,
    this.deliveryAddress,
    required this.earning,
    this.completedAt,
  });

  factory RiderDelivery.fromJson(Map<String, dynamic> json) => RiderDelivery(
        orderId: json['order_id'],
        restaurantName: json['restaurant_name'],
        deliveryAddress: json['delivery_address'],
        earning: json['earning'] ?? 0,
        completedAt: json['completed_at'] == null
            ? null
            : DateTime.tryParse(json['completed_at'].toString())?.toLocal(),
      );
}

/// "1,234" style grouping for whole numbers.
String formatCount(num value) {
  final digits = value.round().abs().toString();
  final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return value < 0 ? '-$grouped' : grouped;
}

/// Money in Ghana cedis from pesewas, e.g. "GH₵ 21,834.00".
String formatCedis(int pesewas) {
  final cedis = (pesewas.abs() / 100).toStringAsFixed(2).split('.');
  return 'GH₵ ${pesewas < 0 ? '-' : ''}${formatCount(int.parse(cedis[0]))}.${cedis[1]}';
}

class RiderAnalytics {
  final int totalDeliveries;
  final int completedDeliveries;
  final int totalEarnings;
  final int averageEarningPerDelivery;
  final int todayEarnings;
  final int todayDeliveries;
  final int weekEarnings;
  final int monthEarnings;
  final double? averageRating;
  final List<RiderDelivery> recentDeliveries;

  RiderAnalytics({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.totalEarnings,
    required this.averageEarningPerDelivery,
    this.todayEarnings = 0,
    this.todayDeliveries = 0,
    this.weekEarnings = 0,
    this.monthEarnings = 0,
    this.averageRating,
    this.recentDeliveries = const [],
  });

  String get displayEarnings =>
      formatCedis(totalEarnings);
  String get displayAvg =>
      formatCedis(averageEarningPerDelivery);

  factory RiderAnalytics.fromJson(Map<String, dynamic> json) => RiderAnalytics(
        totalDeliveries: json['total_deliveries'] ?? 0,
        completedDeliveries: json['completed_deliveries'] ?? 0,
        totalEarnings: json['total_earnings'] ?? 0,
        averageEarningPerDelivery:
          json['avg_earning_per_delivery'] ??
            json['average_earning_per_delivery'] ??
            0,
        todayEarnings: json['today_earnings'] ?? 0,
        todayDeliveries: json['today_deliveries'] ?? 0,
        weekEarnings: json['week_earnings'] ?? 0,
        monthEarnings: json['month_earnings'] ?? 0,
        averageRating: (json['average_rating'] as num?)?.toDouble(),
        recentDeliveries: ((json['recent_deliveries'] ?? []) as List)
            .map((d) => RiderDelivery.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

class Promotion {
  final int id;
  final int restaurantId;
  final String? restaurantName;
  final String title;
  final String? description;
  /// Null when the backend no longer has the image file.
  final String? imageUrl;
  final int? discountPercent;
  final bool isActive;

  const Promotion({
    required this.id,
    required this.restaurantId,
    this.restaurantName,
    required this.title,
    this.imageUrl,
    this.description,
    this.discountPercent,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'],
        restaurantId: json['restaurant_id'],
        restaurantName: json['restaurant_name'],
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
