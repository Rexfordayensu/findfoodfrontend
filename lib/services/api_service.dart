import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../widgets/reviews.dart';

// Custom exception for email not verified during login
class EmailNotVerifiedException implements Exception {
  final String message;
  EmailNotVerifiedException(this.message);

  @override
  String toString() => message;
}

class ServerTimeoutException implements Exception {
  @override
  String toString() =>
      'The server is taking too long to respond. Please try again in a moment.';
}

class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);

  @override
  String toString() => message;
}

/// Sends every request through a fresh [http.Client] (so tests can swap it
/// with `http.runWithClient`) and reports rejected sessions: a 401 for a
/// request that carried a token, or a 403 for a suspended account.
class _SessionAwareClient extends http.BaseClient {
  /// Long enough for a sleeping server to wake, short enough not to hang.
  static const _timeout = Duration(seconds: 45);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final inner = http.Client();
    try {
      final http.StreamedResponse response;
      final List<int> bytes;
      try {
        response = await inner.send(request).timeout(_timeout);
        // Buffer the body so the inner client can be closed safely on web too.
        bytes = await response.stream.toBytes().timeout(_timeout);
      } on TimeoutException {
        throw ServerTimeoutException();
      }
      final hadToken =
          request.headers['Authorization']?.startsWith('Bearer ') ?? false;
      if (hadToken) {
        final body = utf8.decode(bytes, allowMalformed: true);
        if (response.statusCode == 401) {
          ApiService.onSessionInvalid?.call('Your session has expired. Please sign in again.');
        } else if (response.statusCode == 403 && body.contains('suspended')) {
          ApiService.onSessionInvalid?.call('This account has been suspended. Contact support.');
        }
      }
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: request,
        headers: response.headers,
        reasonPhrase: response.reasonPhrase,
      );
    } finally {
      inner.close();
    }
  }
}

class ApiService {
  static final http.Client _http = _SessionAwareClient();

  // ── Short-lived memory of public data ──────────────────────────────────────
  // Restaurants, menus, deals and reviews are the same for everyone and
  // change rarely; reusing them for a few seconds makes going back and forth
  // instant. Two screens asking at once share one request. (Web only: the
  // tests swap the HTTP client per test.)
  static Duration publicCacheTtl = const Duration(seconds: 45);
  static final _publicCache = <String, ({DateTime at, Future<http.Response> response})>{};

  static Future<http.Response> _publicGet(String url) {
    if (!kIsWeb) return _http.get(Uri.parse(url));
    final now = DateTime.now();
    final hit = _publicCache[url];
    if (hit != null && now.difference(hit.at) < publicCacheTtl) return hit.response;
    final response = _http.get(Uri.parse(url)).then((r) {
      if (r.statusCode != 200) _publicCache.remove(url); // don't keep errors
      return r;
    }, onError: (Object e) {
      _publicCache.remove(url);
      throw e;
    });
    _publicCache[url] = (at: now, response: response);
    return response;
  }

  /// Forget remembered public data (e.g. after pulling to refresh).
  static void clearPublicCache() => _publicCache.clear();

  /// Fetch a restaurant's menu in the background, so opening it is instant.
  static void prefetchMenu(int restaurantId) {
    getMenu(restaurantId).catchError((_) => <MenuItem>[]);
  }

  /// Called when the backend rejects the stored session; AuthProvider signs
  /// the user out in response.
  static void Function(String message)? onSessionInvalid;
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kReleaseMode
        ? 'https://findfooddelivery-backend.onrender.com' //  Used automatically when built for production/Vercel
        : 'http://localhost:8000', // Used automatically when running local development debug sessions
  );

  static MediaType _imageMediaType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    final subtype = switch (extension) {
      'png' => 'png',
      'webp' => 'webp',
      'jpg' || 'jpeg' => 'jpeg',
      _ => 'jpeg',
    };
    return MediaType('image', subtype);
  }

  // ── Safe decoder ──────────────────────────────────────────────────────────
  static Map<String, dynamic> _decode(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    if (ct.contains('application/json')) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    // Some deployments omit or mislabel the JSON content type. Decode the
    // body when it is valid JSON so successful auth payloads are not lost.
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Fall through to the plain-text error below.
    }
    return {
      'detail': response.body.isNotEmpty
          ? response.body
          : 'Server error (${response.statusCode})'
    };
  }

  static List<dynamic> _decodeList(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    if (ct.contains('application/json')) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
    }
    return [];
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    late final http.Response response;
    try {
      response = await _http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: Uri(queryParameters: {
          'username': email.trim().toLowerCase(),
          'password': password,
        }).query,
      );
    } on http.ClientException {
      throw Exception('Unable to connect to the backend. Please try again.');
    }
    final data = _decode(response);

    final isEmailUnverified = data['is_verified'] == false ||
        data['email_verified'] == false ||
        data['is_email_verified'] == false ||
        data['requires_verification'] == true ||
        data['detail']?.toString().toLowerCase().contains('verify') == true;

    if (isEmailUnverified) {
      throw EmailNotVerifiedException(data['detail'] ?? 'Email not verified');
    }

    if (response.statusCode == 200) return data;
    if (response.statusCode == 403) {
      throw Exception(data['detail'] ?? 'Invalid email or password');
    }
    if (response.statusCode == 422) {
      throw Exception(data['detail'] ?? 'Please check your login details');
    }
    throw Exception(data['detail'] ?? 'Login failed');
  }

  /// Throws [SessionExpiredException] when the server rejects the token, and a
  /// plain [Exception] for network/server problems (session may still be valid).
  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    if (response.statusCode == 401 || response.statusCode == 404) {
      throw SessionExpiredException(
          data['detail']?.toString() ?? 'Your session has expired.');
    }
    throw Exception(data['detail'] ?? 'Unable to restore your session');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String cuisineType, // Strictly required parameter
    required String address, // Strictly required parameter
  }) async {
    // 1. Build the baseline request body
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };

    // 2. Only expose/send these fields to the backend if registering a restaurant
    if (role == 'restaurant' || role == 'vendor') {
      requestBody['cuisine_type'] = cuisineType;
      requestBody['address'] = address;
    }

    // 3. Make the API call
    final response = await _http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    final data = _decode(response);
    if (response.statusCode == 201) return data;
    throw Exception(data['detail'] ?? 'Registration failed');
  }

  // ── FORGOT / RESET PASSWORD ───────────────────────────────────────────────

  /// Called from forgot_password_screen.dart Step 1
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw PasswordResetException(
      data['detail']?.toString() ?? 'Failed to send reset link.',
    );
  }

  /// Called from forgot_password_screen.dart Step 2
  static Future<void> resetPassword(String token, String newPassword) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'new_password': newPassword}),
    );
    if (response.statusCode == 200) return;
    final data = _decode(response);
    throw PasswordResetException(
      data['detail']?.toString() ?? 'Failed to reset password.',
    );
  }

  // ── RESTAURANTS ───────────────────────────────────────────────────────────

  static Future<List<Restaurant>> getRestaurants() async {
    final response = await _publicGet('$baseUrl/restaurants');
    if (response.statusCode == 200) {
      return _decodeList(response).map((r) => Restaurant.fromJson(r)).toList();
    }
    throw Exception('Failed to load restaurants (${response.statusCode})');
  }

  static Future<Restaurant> createRestaurant({
    required String token,
    required String name,
    required String cuisineType,
    required String address,
    required String email,
    required String password,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/restaurants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'cuisine_type': cuisineType,
        'address': address,
        'email': email,
        'password': password,
      }),
    );
    final data = _decode(response);
    if (response.statusCode == 201) return Restaurant.fromJson(data);
    throw Exception(data['detail'] ?? 'Failed to create restaurant');
  }

   static Future<List<Promotion>> getMyPromotions({
    required String token,
    required int restaurantId, 
  }) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/$restaurantId/promotions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return _decodeList(response).map((p) => Promotion.fromJson(p)).toList();
    }
    throw Exception(_decode(response)['detail'] ?? 'Failed to load promotions');
  }

  /// Current deals across all restaurants, for the customer feed.
  static Future<List<Promotion>> getActivePromotions() async {
    final response = await _publicGet('$baseUrl/promotions');
    if (response.statusCode == 200) {
      return _decodeList(response).map((p) => Promotion.fromJson(p)).toList();
    }
    throw Exception(_decode(response)['detail'] ?? 'Failed to load deals');
  }

  /// Turns a stored image path into a loadable URL (relative paths are
  /// served by the backend).
  static String? imageUrl(String? path, {int? width}) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return sizedImage(path, width: width);
    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  /// A Cloudinary photo resized for where it's shown (and compressed as far
  /// as it can go without visible loss): much less to download than the
  /// original upload. Other URLs are left as they are.
  static String sizedImage(String url, {int? width}) {
    const marker = '/image/upload/';
    final at = url.indexOf(marker);
    if (width == null || at < 0 || !url.startsWith('https://res.cloudinary.com/')) return url;
    final rest = url.substring(at + marker.length);
    // Already transformed (a transformation segment comes before the version).
    if (!rest.startsWith('v') && rest.contains(',')) return url;
    return '${url.substring(0, at + marker.length)}q_auto,c_limit,w_$width/$rest';
  }

  static Future<List<Promotion>> getPromotions(int restaurantId) async {
    final response = await _publicGet('$baseUrl/restaurants/$restaurantId/promotions');
    if (response.statusCode == 200) {
      return _decodeList(response).map((p) => Promotion.fromJson(p)).toList();
    }
    throw Exception(_decode(response)['detail'] ?? 'Failed to load promotions');
  }

  static Future<Promotion> createPromotion({
    required String token,
    required int restaurantId,
    required String title,
    String? description,
    int? discountPercent,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/restaurants/$restaurantId/promotions'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (discountPercent != null) {
      request.fields['discount_percent'] = discountPercent.toString();
    }
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: _imageMediaType(filename),
    ));
    final response = await http.Response.fromStream(await _http.send(request));
    final data = _decode(response);
    if (response.statusCode == 201) return Promotion.fromJson(data);
    throw Exception(data['detail'] ?? 'Failed to create promotion');
  }

  static Future<void> deletePromotion({
    required String token,
    required int restaurantId,
    required int promotionId,
  }) async {
    final response = await _http.delete(
      Uri.parse('$baseUrl/restaurants/$restaurantId/promotions/$promotionId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(
          _decode(response)['detail'] ?? 'Failed to delete promotion');
    }
  }

  // ── MENU ──────────────────────────────────────────────────────────────────

  static Future<List<MenuItem>> getMenu(int restaurantId) async {
    final response = await _publicGet('$baseUrl/restaurants/$restaurantId/menu');
    if (response.statusCode == 200) {
      return _decodeList(response).map((m) => MenuItem.fromJson(m)).toList();
    }
    throw Exception('Failed to load menu (${response.statusCode})');
  }

  static Future<List<MenuItem>> getManagedMenu({
    required String token,
    required int restaurantId,
  }) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/$restaurantId/menu/manage'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return _decodeList(response).map((item) => MenuItem.fromJson(item)).toList();
    }
    final data = _decode(response);
    throw Exception(data['detail'] ?? 'Failed to load menu for management');
  }

  static Future<MenuItem> addMenuItem({
    required String token,
    required int restaurantId,
    required String name,
    required String? description,
    required dynamic price,
  }) async {
    // FIX: Passing fields directly into the URI query string parameters
    // to satisfy the backend validation requiring 'menu_input' in the query location.
    final response = await _http.post(
      Uri.parse('$baseUrl/restaurants/$restaurantId/menu'
          '?name=${Uri.encodeComponent(name)}'
          '&description=${Uri.encodeComponent(description ?? "")}'
          '&price=${double.tryParse(price.toString()) ?? 0.0}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      final data = _decode(response);
      return MenuItem.fromJson(data);
    } else {
      throw Exception(
          'Failed to add item (${response.statusCode}): ${response.body}');
    }
  }

  // ── ORDERS ────────────────────────────────────────────────────────────────

  static Future<Order> placeOrder({
    required String token,
    required int restaurantId,
    required List<Map<String, int>> items,
    String fulfillmentMethod = 'delivery',
    String? pickupName,
    String? pickupPhone,
    String? kitchenNote,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledFor,
    String? promoCode,
  }) async {
    final payload = <String, dynamic>{
      'restaurant_id': restaurantId,
      'items': items,
      'fulfillment_method': fulfillmentMethod,
      if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
    };
    if (pickupName != null && pickupName.trim().isNotEmpty) {
      payload['pickup_name'] = pickupName.trim();
    }
    if (pickupPhone != null && pickupPhone.trim().isNotEmpty) {
      payload['pickup_phone'] = pickupPhone.trim();
    }
    if (kitchenNote != null && kitchenNote.trim().isNotEmpty) {
      payload['kitchen_note'] = kitchenNote.trim();
    }
    if (deliveryAddress != null && deliveryAddress.trim().isNotEmpty) {
      payload['delivery_address'] = deliveryAddress.trim();
    }
    if (deliveryLatitude != null && deliveryLongitude != null) {
      payload['delivery_latitude'] = deliveryLatitude;
      payload['delivery_longitude'] = deliveryLongitude;
    }
    if (scheduledFor != null) {
      payload['scheduled_for'] = scheduledFor.toUtc().toIso8601String();
    }
    final response = await _http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    final data = _decode(response);
    if (response.statusCode == 201) return Order.fromJson(data);
    throw Exception(data['detail'] ?? 'Failed to place order');
  }

  static Future<List<Order>> getMyOrders(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return _decodeList(response).map((o) => Order.fromJson(o)).toList();
    }
    throw Exception('Failed to load orders (${response.statusCode})');
  }

  static Future<Order> updateOrderStatus(
      String token, int orderId, String newStatus, {bool? sealed}) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status').replace(
      queryParameters: {
        'new_status': newStatus,
        if (sealed != null) 'sealed': '$sealed',
      },
    );

    final response = await _http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? 'Failed to update order status');
    }
    return Order.fromJson(data);
  }

  // ── HANDOVERS (4-digit codes) ─────────────────────────────────────────────

  static Future<Order> _handoffCall(
      String token, String path, String fallbackError,
      {String? code}) async {
    final response = await _http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: code == null ? null : jsonEncode({'code': code}),
    );
    final data = _decode(response);
    if (response.statusCode != 200) {
      final detail = data['detail'];
      throw Exception(detail is String ? detail : fallbackError);
    }
    return Order.fromJson(data);
  }

  /// A rider takes a job; the result carries their pickup code.
  static Future<Order> acceptDelivery(String token, int orderId) =>
      _handoffCall(token, '/deliveries/$orderId/accept',
          'Could not accept this delivery.');

  /// A rider gives a job back before collecting the food.
  static Future<Order> releaseDelivery(String token, int orderId) =>
      _handoffCall(token, '/deliveries/$orderId/release',
          'Could not release this delivery.');

  /// The restaurant hands the food to the rider (rider's code) or, for
  /// pickup orders, to the customer (customer's code).
  static Future<Order> handOverOrder(String token, int orderId, String code) =>
      _handoffCall(token, '/orders/$orderId/handover',
          'Could not hand over this order.',
          code: code);

  /// The rider completes the delivery with the customer's code.
  static Future<Order> completeDelivery(
          String token, int orderId, String code) =>
      _handoffCall(token, '/orders/$orderId/deliver',
          'Could not complete this delivery.',
          code: code);

  // ── DELIVERIES (Rider) ────────────────────────────────────────────────────

  static Future<List<Order>> getAvailableDeliveries(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/deliveries/available'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return _decodeList(response).map((o) => Order.fromJson(o)).toList();
    }
    throw Exception('Failed to load deliveries (${response.statusCode})');
  }

  // ── PAYMENTS ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> initializePayment({
    required String token,
    required int orderId,
    required String provider,
    String? callbackUrl,
  }) async {
    final request = PaymentInitializationRequest(
      orderId: orderId,
      provider: provider,
      callbackUrl: callbackUrl,
    );

    final response = await _http.post(
      Uri.parse('$baseUrl/payments/initialize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    final data = _decode(response);
    if (response.statusCode == 200 || response.statusCode == 201) return data;

    if (response.statusCode == 400) {
      throw Exception('Please select a valid payment method.');
    }
    if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please sign in again.');
    }
    if (response.statusCode == 403) {
      throw Exception('You are not allowed to initialize this payment.');
    }
    if (response.statusCode == 404) {
      throw Exception('Order not found.');
    }
    if (response.statusCode == 409) {
      throw Exception(data['detail'] ?? 'This order has already been paid.');
    }
    if (response.statusCode == 422) {
      throw Exception('The selected payment method is not available.');
    }
    if (response.statusCode >= 500) {
      throw Exception(
          'Payment service is currently unavailable. Please try again shortly.');
    }

    throw Exception(data['detail'] ?? 'Failed to initialize payment');
  }

  /// Verify a payment by reference via backend
  static Future<Map<String, dynamic>> verifyPayment({
    required String token,
    required String reference,
  }) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/payments/${Uri.encodeComponent(reference)}/verify'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to verify payment');
  }

  // ── ADMIN ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getPendingRestaurants(
      String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/restaurants/pending'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception(
        _decode(response)['detail'] ?? 'Failed to load pending restaurants');
  }

  static Future<void> approveRestaurant(String token, int restaurantId) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/admin/restaurants/$restaurantId/approve'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      final data = _decode(response);
      throw Exception(data['detail'] ?? 'Failed to approve');
    }
  }

  static Future<void> rejectRestaurant(String token, int restaurantId) async {
    final response = await _http.delete(
      Uri.parse('$baseUrl/admin/restaurants/$restaurantId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = _decode(response);
      throw Exception(data['detail'] ?? 'Failed to reject');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load users');
  }

  static Future<Map<String, dynamic>> getPlatformStats(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception('Failed to load stats');
  }

// ── MENU CRUD (edit/delete/toggle) ────────────────────────────────────────
  static Future<Restaurant> getMyRestaurant(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/mine'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return Restaurant.fromJson(data);
    throw Exception(data['detail'] ?? 'Failed to load your restaurant');
  }

  static Future<MenuItem> updateMenuItem({
    required String token,
    required int itemId,
    required String name,
    required String? description,
    required int price,
    required int restaurantId,
  }) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/menu/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
          {'name': name, 'description': description, 'price': price}),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return MenuItem.fromJson(data);
    throw Exception(data['detail'] ?? 'Failed to update item');
  }

  static Future<bool> toggleMenuItem(String token, int itemId) async {
    final response = await _http.patch(
      Uri.parse('$baseUrl/menu/$itemId/toggle'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data['is_available'] == true;
    throw Exception(data['detail'] ?? 'Failed to toggle item');
  }

  static Future<void> deleteMenuItem(String token, int itemId) async {
    final url = Uri.parse('$baseUrl/menu/$itemId');

    final response = await _http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode != 200) {
      _decode(response);
      throw Exception("Backend error: ${response.body}");
    }
  }

  // ── ANALYTICS ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRestaurantAnalytics(
      String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/mine/analytics'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to load analytics');
  }

  // ── EMAIL OTP VERIFICATION ────────────────────────────────────────────────

  /// Verify email with OTP
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'otp': otp.trim(),
      }),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Verification failed');
  }

  /// Resend OTP to email
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
      }),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to resend OTP');
  }

  // ── LOGIN OTP (Passwordless) ─────────────────────────────────────────────

  /// Request a login OTP for an email (passwordless login start)
  static Future<void> requestLoginOtp({
    required String email,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/login/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );

    if (response.statusCode == 200) return;
    final data = _decode(response);
    throw Exception(data['detail'] ?? 'Failed to request login OTP');
  }

  /// Verify login OTP and return the same login payload as password login
  static Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/login/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'otp': otp.trim(),
      }),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Login verification failed');
  }

  /// Resend login OTP
  static Future<Map<String, dynamic>> resendLoginOtp({
    required String email,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/login/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to resend login OTP');
  }

  static Future<Map<String, dynamic>> getRiderAnalytics(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/riders/me/analytics'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to load analytics');
  }

  // ── SCHEDULED ORDERS ──────────────────────────────────────────────────────
  // ── CHAT ──────────────────────────────────────────────────────────────────
  /// Order chats are private between two people: [withRole] is the other
  /// person ('customer', 'restaurant' or 'rider').
  static Uri chatUri(int orderId, String withRole) =>
      Uri.parse('$baseUrl/orders/$orderId/messages')
          .replace(queryParameters: {'with': withRole});

  static Future<List<Map<String, dynamic>>> getChatMessages({
    required String token,
    required int orderId,
    required String withRole,
  }) async {
    final response = await _http.get(
      chatUri(orderId, withRole),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception(_decode(response)['detail'] ?? 'Failed to load messages');
  }

  static Future<Map<String, dynamic>> sendChatMessage({
    required String token,
    required int orderId,
    required String withRole,
    required String message,
  }) async {
    final response = await _http.post(
      chatUri(orderId, withRole),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message}),
    );
    final data = _decode(response);
    if (response.statusCode == 200 || response.statusCode == 201) return data;
    throw Exception(data['detail'] ?? 'Failed to send message');
  }

  // ── RATINGS ───────────────────────────────────────────────────────────────
  static Future<void> submitRating({
    required String token,
    required int orderId,
    required int restaurantRating,
    int? riderRating, // omitted for pickup orders
    String? comment,
    List<String> issues = const [],
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/orders/$orderId/rate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'restaurant_rating': restaurantRating,
        if (riderRating != null) 'rider_rating': riderRating,
        if (comment != null) 'comment': comment,
        if (issues.isNotEmpty) 'issues': issues,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Failed to submit rating'));
    }
  }

  // ── PROBLEM REPORTS ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> reportOrderIssue({
    required String token,
    required int orderId,
    required String reason,
    String? details,
    String? photoUrl,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/orders/$orderId/issues'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'reason': reason,
        if (details != null && details.isNotEmpty) 'details': details,
        if (photoUrl != null) 'photo_url': photoUrl,
      }),
    );
    if (response.statusCode == 201) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not send your report'));
  }

  /// Uploads a photo of what arrived; returns its URL for [reportOrderIssue].
  static Future<String> uploadIssuePhoto({
    required String token,
    required int orderId,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/orders/$orderId/issues/photo'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
      contentType: _imageMediaType(filename),
    ));
    final response = await http.Response.fromStream(await _http.send(request));
    if (response.statusCode == 200) return '${_decode(response)['photo_url']}';
    throw Exception(_errorDetail(response, 'Could not upload your photo'));
  }

  static Future<List<Map<String, dynamic>>> getOrderIssues(
      String token, int orderId) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/orders/$orderId/issues'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Could not load your report'));
  }

  static Future<List<Map<String, dynamic>>> getAdminIssues(String token,
      {String status = 'open'}) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/issues?status=$status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Could not load problem reports'));
  }

  static Future<Map<String, dynamic>> resolveIssue({
    required String token,
    required int issueId,
    required String action, // 'refund' or 'dismiss'
    String? note,
    int? amount, // pesewas for a partial refund; null refunds the whole order
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/admin/issues/$issueId/resolve'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'action': action,
        if (note != null && note.isNotEmpty) 'note': note,
        if (amount != null) 'amount': amount,
      }),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not resolve the report'));
  }

  /// Public reviews of a restaurant, newest first.
  static Future<List<Review>> getRestaurantReviews(int restaurantId) async {
    final response = await _publicGet('$baseUrl/restaurants/$restaurantId/reviews');
    if (response.statusCode == 200) {
      return _decodeList(response).map((r) => Review.fromJson(r)).toList();
    }
    throw Exception('Failed to load reviews (${response.statusCode})');
  }

  static Future<void> changeMyPassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final data = _decode(response);
      throw Exception(data['detail'] ?? 'Failed to change password');
    }
  }

  static Future<Map<String, dynamic>> getMyProfile(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to load profile');
  }

  static Future<Map<String, dynamic>> updateMyProfile({
    required String token,
    required String name,
    String? phone,
  }) async {
    final response = await _http.patch(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name.trim(),
        if (phone != null) 'phone': phone.trim(),
      }),
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to update profile');
  }

  static Future<Map<String, dynamic>> getNotificationPrefs(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/auth/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to load notification preferences');
  }

  static Future<void> updateNotificationPrefs({
    required String token,
    required bool emailNotifications,
    required bool pushNotifications,
    required bool orderAlerts,
    bool? promotions,
  }) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/auth/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email_notifications': emailNotifications,
        'push_notifications': pushNotifications,
        'order_alerts': orderAlerts,
        if (promotions != null) 'promotions': promotions,
      }),
    );
    if (response.statusCode == 200) return;
    final data = _decode(response);
    throw Exception(data['detail'] ?? 'Failed to save notification preferences');
  }

  static Future<void> removeMenuItemImage(
      {required String token,
      required int restaurantId,
      required int itemId}) async {
    final response = await _http.delete(
      Uri.parse('$baseUrl/restaurants/$restaurantId/menu/$itemId/image'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      final data = _decode(response);
      throw Exception(data['detail'] ?? 'Failed to remove image');
    }
  }

  static Future<MenuItem> uploadMenuItemImage(
      {required String token,
      required int restaurantId,
      required int itemId,
      required Uint8List imageBytes,
      required String filename}) async {
    final url =
        Uri.parse('$baseUrl/restaurants/$restaurantId/menu/$itemId/image');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      // ignore: avoid_single_cascade_in_expression_statements
      ..files.add(
        http.MultipartFile.fromBytes(
          'file', // Must match the name parameter expected by your FastAPI backend (e.g., File(...))
          imageBytes,
          filename: filename,
          contentType: _imageMediaType(filename),
        ),
      );

    final streamedResponse = await _http.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return MenuItem.fromJson(
        (data['menu_item'] as Map<String, dynamic>?) ?? data,
      );
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getRevenueDetails(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/revenue'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['detail'] ?? 'Failed to load revenue details');
  }

  static Future<List<Map<String, dynamic>>> getAllOrdersAdmin(
      String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load orders');
  }

// Exchange Google OAuth Authorization Code for a token payload map
  static Future<Map<String, dynamic>> exchangeGoogleOAuthCode(
      String authCode) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/google/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': authCode}),
    );
    final data = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? 'Google Authentication Failed');
    }
    return data;
  }

  // Upload restaurant banner using raw image bytes (Flutter Web compatible)
  static Future<String?> uploadRestaurantBanner({
    required String token,
    required int restaurantId,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final url = Uri.parse('$baseUrl/restaurants/$restaurantId/upload-banner');
    final request = http.MultipartRequest('POST', url);

    // Add Authorization bearer security token header
    request.headers['Authorization'] = 'Bearer $token';

    // Attach the raw web image file bytes
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
        contentType: _imageMediaType(filename),
      ),
    );

    final streamedResponse = await _http.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    final data = _decode(response);
    if (response.statusCode == 200) return data['banner_url']?.toString();
    throw Exception(data['detail'] ?? 'Failed to upload restaurant banner');
  }

  // ── SESSION ───────────────────────────────────────────────────────────────

  static Map<String, String> _jsonAuth(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static String _errorDetail(http.Response response, String fallback) {
    final detail = _decode(response)['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty && detail.first is Map) {
      return (detail.first as Map)['msg']?.toString() ?? fallback;
    }
    return fallback;
  }

  /// Exchanges a still-valid token for a fresh one.
  static Future<Map<String, dynamic>> refreshToken(String token) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Unable to refresh your session'));
  }

  // ── ACCOUNT: EMAIL CHANGE ─────────────────────────────────────────────────

  static Future<String> requestEmailChange({
    required String token,
    required String newEmail,
    required String password,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/me/email/request'),
      headers: _jsonAuth(token),
      body: jsonEncode({'new_email': newEmail.trim(), 'password': password}),
    );
    if (response.statusCode == 200) {
      return _decode(response)['message']?.toString() ?? 'Code sent.';
    }
    throw Exception(_errorDetail(response, 'Could not start the email change'));
  }

  static Future<Map<String, dynamic>> verifyEmailChange({
    required String token,
    required String otp,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/auth/me/email/verify'),
      headers: _jsonAuth(token),
      body: jsonEncode({'otp': otp.trim()}),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not verify the code'));
  }

  // ── RESTAURANT PROFILE ────────────────────────────────────────────────────

  static Future<Restaurant> updateMyRestaurant({
    required String token,
    String? name,
    String? cuisineType,
    String? address,
    bool? isOpen,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (cuisineType != null) 'cuisine_type': cuisineType.trim(),
      if (address != null) 'address': address.trim(),
      if (isOpen != null) 'is_open': isOpen,
    };
    final response = await _http.patch(
      Uri.parse('$baseUrl/restaurants/mine'),
      headers: _jsonAuth(token),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) return Restaurant.fromJson(_decode(response));
    throw Exception(_errorDetail(response, 'Failed to update restaurant'));
  }

  // ── ORDERS: CANCEL ────────────────────────────────────────────────────────

  /// Cancels (customer) or rejects (restaurant) an order; paid orders are
  /// refunded by the backend.
  static Future<Order> cancelOrder(String token, int orderId) =>
      updateOrderStatus(token, orderId, 'cancelled');

  // ── PAYMENTS: PROVIDERS & MOMO ────────────────────────────────────────────

  static Future<List<PaymentProviderOption>> getPaymentProviders() async {
    final response = await _http.get(Uri.parse('$baseUrl/payments/providers'));
    if (response.statusCode == 200) {
      return _decodeList(response)
          .map((p) => PaymentProviderOption.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_errorDetail(response, 'Failed to load payment methods'));
  }

  static Future<Map<String, dynamic>> initiateMomoPayment({
    required String token,
    required int orderId,
    required String phoneNumber,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/payments/momo/initiate'),
      headers: _jsonAuth(token),
      body: jsonEncode({
        'order_id': orderId,
        'provider': 'mtn_momo',
        'phone_number': phoneNumber.trim(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decode(response);
    }
    throw Exception(_errorDetail(response, 'MoMo payment could not be started'));
  }

  static Future<String> checkMomoStatus({
    required String token,
    required String referenceId,
  }) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/payments/momo/status/${Uri.encodeComponent(referenceId)}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return _decode(response)['status']?.toString() ?? 'pending';
    }
    throw Exception(_errorDetail(response, 'Could not check MoMo payment'));
  }

  // ── ADMIN: USERS & NOTIFICATIONS ──────────────────────────────────────────

  static Future<void> setUserActive({
    required String token,
    required int userId,
    required bool isActive,
  }) async {
    final response = await _http.patch(
      Uri.parse('$baseUrl/admin/users/$userId/status'),
      headers: _jsonAuth(token),
      body: jsonEncode({'is_active': isActive}),
    );
    if (response.statusCode == 200) return;
    throw Exception(_errorDetail(response, 'Failed to update the account'));
  }

  /// Recent platform events (orders, payments, ratings, sign-ups...).
  static Future<List<Map<String, dynamic>>> getAdminActivity(String token,
      {int limit = 20}) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/activity?limit=$limit'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Failed to load activity'));
  }

  static Future<List<Map<String, dynamic>>> getAdminNotifications(
      String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Failed to load notifications'));
  }

  // ── NOTIFICATIONS AND WEB PUSH ──────────────────────────────────────────────

  /// The bell's list (read and unread, newest first) and the unread count.
  static Future<Map<String, dynamic>> getNotifications(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/notifications?limit=100'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load notifications'));
  }

  /// Marks one notification read; returns the new unread count.
  static Future<int> markNotificationRead(String token, int id) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return (_decode(response)['unread'] as num).toInt();
    throw Exception(_errorDetail(response, 'Could not update the notification'));
  }

  static Future<void> markAllNotificationsRead(String token) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Could not update notifications'));
    }
  }

  static Future<String> getPushPublicKey() async {
    final response = await _http.get(Uri.parse('$baseUrl/push/public-key'));
    if (response.statusCode == 200) return '${_decode(response)['key']}';
    throw Exception(_errorDetail(response, 'Notifications are unavailable right now'));
  }

  static Future<void> subscribePush(String token, Map<String, dynamic> subscription) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/push/subscribe'),
      headers: _jsonAuth(token),
      body: jsonEncode({
        'endpoint': subscription['endpoint'],
        'keys': subscription['keys'],
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorDetail(response, 'Could not turn on notifications'));
    }
  }

  static Future<void> unsubscribePush(String token, String endpoint) async {
    await _http.post(
      Uri.parse('$baseUrl/push/unsubscribe'),
      headers: _jsonAuth(token),
      body: jsonEncode({'endpoint': endpoint}),
    );
  }

  /// Online riders are told about new delivery jobs.
  static Future<void> setRiderOnline(String token, bool online) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/riders/me/online'),
      headers: _jsonAuth(token),
      body: jsonEncode({'online': online}),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Could not change your status'));
    }
  }

  // ── CRASH REPORTS ───────────────────────────────────────────────────────────

  /// Sends an app crash to the server (see CrashReporter).
  static Future<void> reportClientError({
    String? token,
    required String errorType,
    required String message,
    String? stack,
    String? route,
    String? appVersion,
  }) async {
    await _http.post(
      Uri.parse('$baseUrl/client-errors'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'error_type': errorType,
        'message': message,
        if (stack != null) 'stack': stack.length > 8000 ? stack.substring(0, 8000) : stack,
        if (route != null) 'route': route,
        if (appVersion != null) 'app_version': appVersion,
      }),
    );
  }

  static Future<List<Map<String, dynamic>>> getErrorReports(String token,
      {String status = 'open'}) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/errors?status=$status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Could not load app errors'));
  }

  static Future<void> resolveErrorReport(String token, int id) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/admin/errors/$id/resolve'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Could not update the error'));
    }
  }

  // ── PACKING PROOF, DOORSTEP CHECK, RESTAURANT ANSWERS, CREDIT ───────────────

  /// The kitchen's photo of the packed order.
  static Future<String> uploadPackPhoto({
    required String token,
    required int orderId,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/orders/$orderId/pack-photo'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes('file', imageBytes,
        filename: filename, contentType: _imageMediaType(filename)));
    final response = await http.Response.fromStream(await _http.send(request));
    if (response.statusCode == 200) return '${_decode(response)['packed_photo_url']}';
    throw Exception(_errorDetail(response, 'Could not upload the photo'));
  }

  /// Sets the signed-in user's profile photo; returns their profile.
  static Future<Map<String, dynamic>> uploadAvatar({
    required String token,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/me/avatar'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes('file', imageBytes,
        filename: filename, contentType: _imageMediaType(filename)));
    final response = await http.Response.fromStream(await _http.send(request));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not upload your photo'));
  }

  static Future<Map<String, dynamic>> deleteAvatar(String token) async {
    final response = await _http.delete(
      Uri.parse('$baseUrl/auth/me/avatar'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not remove your photo'));
  }

  /// The customer checked their food; returns the order with their code.
  static Future<Order> doorstepCheck(String token, int orderId, bool allThere) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/orders/$orderId/doorstep-check'),
      headers: _jsonAuth(token),
      body: jsonEncode({'all_there': allThere}),
    );
    if (response.statusCode == 200) return Order.fromJson(_decode(response));
    throw Exception(_errorDetail(response, 'Could not save your check'));
  }

  static Future<List<Map<String, dynamic>>> getRestaurantIssues(String token,
      {String status = 'open'}) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/mine/issues?status=$status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Could not load problem reports'));
  }

  static Future<void> answerIssue({
    required String token,
    required int issueId,
    required String response,
    String? note,
  }) async {
    final result = await _http.post(
      Uri.parse('$baseUrl/issues/$issueId/restaurant-response'),
      headers: _jsonAuth(token),
      body: jsonEncode({
        'response': response,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );
    if (result.statusCode != 200) {
      throw Exception(_errorDetail(result, 'Could not send your answer'));
    }
  }

  /// FindFood credit: {'balance': pesewas, 'entries': [...]}.
  static Future<Map<String, dynamic>> getMyCredit(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/me/credit'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load your credit'));
  }

  // ── RESTAURANTS CHOOSING A RIDER ────────────────────────────────────────────

  /// Riders the restaurant can ask for this order, and any open request.
  static Future<Map<String, dynamic>> getOrderRiders(String token, int orderId) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/orders/$orderId/riders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load riders'));
  }

  static Future<void> offerRider(String token, int orderId, int riderId) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/orders/$orderId/rider-offer'),
      headers: _jsonAuth(token),
      body: jsonEncode({'rider_id': riderId}),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorDetail(response, 'Could not send the request'));
    }
  }

  static Future<void> withdrawRiderOffer(String token, int orderId) async {
    final response = await _http.delete(
      Uri.parse('$baseUrl/orders/$orderId/rider-offer'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Could not cancel the request'));
    }
  }

  /// Requests from restaurants waiting for this rider's answer.
  static Future<List<Map<String, dynamic>>> getDeliveryOffers(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/deliveries/offers'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Could not load requests'));
  }

  static Future<Order> acceptDeliveryOffer(String token, int offerId) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/deliveries/offers/$offerId/accept'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return Order.fromJson(_decode(response));
    throw Exception(_errorDetail(response, 'Could not accept the delivery'));
  }

  static Future<void> declineDeliveryOffer(String token, int offerId) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/deliveries/offers/$offerId/decline'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Could not decline'));
    }
  }

  // ── RESTAURANT PAYOUTS ──────────────────────────────────────────────────────

  /// Mobile money networks ('momo') or banks ('bank') for payouts.
  static Future<List<Map<String, dynamic>>> getPayoutProviders(String token, String type) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/payouts/providers?type=$type'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decodeList(response));
    }
    throw Exception(_errorDetail(response, 'Could not load payout options'));
  }

  static Future<Map<String, dynamic>> getMyPayout(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/mine/payout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load your payout account'));
  }

  static Future<Map<String, dynamic>> setMyPayout({
    required String token,
    required String type,
    required String providerCode,
    required String accountNumber,
  }) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/restaurants/mine/payout'),
      headers: _jsonAuth(token),
      body: jsonEncode({
        'type': type,
        'provider_code': providerCode,
        'account_number': accountNumber,
      }),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not save your payout account'));
  }

  // ── COMMISSION (admin) ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCommission(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/commission'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the commission'));
  }

  static Future<Map<String, dynamic>> setCommission(String token, double percent) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/admin/commission'),
      headers: _jsonAuth(token),
      body: jsonEncode({'percent': percent}),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not change the commission'));
  }

  /// A restaurant's special commission rate; null puts it back on the
  /// standard rate. Returns the updated commission overview.
  static Future<Map<String, dynamic>> setRestaurantCommission(
      String token, int restaurantId, double? percent) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/admin/restaurants/$restaurantId/commission'),
      headers: _jsonAuth(token),
      body: jsonEncode({'percent': percent}),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, "Could not change the restaurant's rate"));
  }

  // ── DELIVERY FEES AND RIDER PAY ─────────────────────────────────────────────

  /// What delivery from [restaurantId] to the point costs, in pesewas:
  /// {fee, distance_km, mode}.
  static Future<Map<String, dynamic>> getDeliveryQuote(int restaurantId,
      {double? latitude, double? longitude}) async {
    final query = latitude != null && longitude != null ? '?lat=$latitude&lng=$longitude' : '';
    final response = await _publicGet('$baseUrl/restaurants/$restaurantId/delivery-quote$query');
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not work out the delivery fee'));
  }

  static Future<Map<String, dynamic>> setRestaurantLocation(
      String token, double latitude, double longitude) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/restaurants/mine/location'),
      headers: _jsonAuth(token),
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not save your location'));
  }

  static Future<Map<String, dynamic>> getMyRiderPayout(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/riders/me/payout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load your pay'));
  }

  static Future<Map<String, dynamic>> setMyRiderPayout({
    required String token,
    required String type,
    required String providerCode,
    required String accountNumber,
  }) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/riders/me/payout'),
      headers: _jsonAuth(token),
      body: jsonEncode({
        'type': type,
        'provider_code': providerCode,
        'account_number': accountNumber,
      }),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not save your payout account'));
  }

  static Future<Map<String, dynamic>> getDeliverySettings(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/delivery-settings'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the delivery settings'));
  }

  static Future<Map<String, dynamic>> setDeliverySettings(
      String token, Map<String, dynamic> settings) async {
    final response = await _http.put(
      Uri.parse('$baseUrl/admin/delivery-settings'),
      headers: _jsonAuth(token),
      body: jsonEncode(settings),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not save the delivery settings'));
  }

  static Future<Map<String, dynamic>> getRiderPayouts(String token) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/admin/rider-payouts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load rider payouts'));
  }

  /// Pays the rider everything owed: [method] 'paystack' or 'manual'.
  static Future<Map<String, dynamic>> payRider(String token, int riderId, String method,
      {String? note}) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/admin/rider-payouts/$riderId/pay'),
      headers: _jsonAuth(token),
      body: jsonEncode({'method': method, if (note != null && note.isNotEmpty) 'note': note}),
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not pay the rider'));
  }

  // ── ADMIN TEAM AND ACTIVITY LOG ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminTeam(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/team'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the team'));
  }

  static Future<Map<String, dynamic>> inviteAdmin(
      String token, {required String name, required String email, required String role}) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/team/invite'),
        headers: _jsonAuth(token),
        body: jsonEncode({'name': name, 'email': email, 'admin_role': role}));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not send the invitation'));
  }

  static Future<Map<String, dynamic>> changeAdminRole(String token, int userId, String role) async {
    final response = await _http.patch(Uri.parse('$baseUrl/admin/team/$userId'),
        headers: _jsonAuth(token), body: jsonEncode({'admin_role': role}));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not change the role'));
  }

  static Future<Map<String, dynamic>> removeAdmin(String token, int userId) async {
    final response = await _http.delete(Uri.parse('$baseUrl/admin/team/$userId'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not remove this admin'));
  }

  static Future<List<Map<String, dynamic>>> getAuditLog(String token,
      {int? beforeId, int? adminId}) async {
    final query = {
      'limit': '50',
      if (beforeId != null) 'before_id': '$beforeId',
      if (adminId != null) 'admin_id': '$adminId',
    };
    final response = await _http.get(
        Uri.parse('$baseUrl/admin/audit-log').replace(queryParameters: query),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not load the activity log'));
  }

  // ── ADMIN ORDERS CONTROL ROOM ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> getOrdersBoard(String token,
      {String view = 'attention', String? query}) async {
    final params = {'view': view, if (query != null && query.isNotEmpty) 'q': query};
    final response = await _http.get(
        Uri.parse('$baseUrl/admin/orders/board').replace(queryParameters: params),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load orders'));
  }

  static Future<Map<String, dynamic>> getAdminOrderDetail(String token, int orderId) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/orders/$orderId/detail'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the order'));
  }

  static Future<void> adminCancelOrder(String token, int orderId, String reason, String refund) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/orders/$orderId/cancel'),
        headers: _jsonAuth(token), body: jsonEncode({'reason': reason, 'refund': refund}));
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not cancel the order'));
  }

  static Future<void> adminReleaseRider(String token, int orderId, String reason) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/orders/$orderId/release-rider'),
        headers: _jsonAuth(token), body: jsonEncode({'reason': reason}));
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not take the job back'));
  }

  static Future<List<Map<String, dynamic>>> adminOrderRiders(String token, int orderId) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/orders/$orderId/riders'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(_decode(response)['riders'] as List);
    }
    throw Exception(_errorDetail(response, 'Could not load riders'));
  }

  static Future<void> adminOfferRider(String token, int orderId, int riderId) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/orders/$orderId/offer-rider'),
        headers: _jsonAuth(token), body: jsonEncode({'rider_id': riderId}));
    if (response.statusCode != 201) throw Exception(_errorDetail(response, 'Could not ask the rider'));
  }

  static Future<void> adminRefundOrder(
      String token, int orderId, int amount, String method, String reason) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/orders/$orderId/refund'),
        headers: _jsonAuth(token),
        body: jsonEncode({'amount': amount, 'method': method, 'reason': reason}));
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not refund'));
  }

  // ── RIDER VERIFICATION ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRiderVerification(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/riders/me/verification'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load your verification'));
  }

  static Future<Map<String, dynamic>> submitRiderVerification(
      String token, Map<String, dynamic> details) async {
    final response = await _http.put(Uri.parse('$baseUrl/riders/me/verification'),
        headers: _jsonAuth(token), body: jsonEncode(details));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not send your details'));
  }

  static Future<List<Map<String, dynamic>>> getRiderVerifications(String token, String status) async {
    final response = await _http.get(
        Uri.parse('$baseUrl/admin/riders/verification?status=$status'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not load riders'));
  }

  static Future<void> approveRider(String token, int riderId) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/riders/$riderId/approve'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not approve the rider'));
  }

  static Future<void> rejectRider(String token, int riderId, String reason) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/riders/$riderId/reject'),
        headers: _jsonAuth(token), body: jsonEncode({'reason': reason}));
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not send that'));
  }

  // ── FINANCE ─────────────────────────────────────────────────────────────────

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<Map<String, dynamic>> getFinance(String token, DateTime start, DateTime end) async {
    final response = await _http.get(
        Uri.parse('$baseUrl/admin/finance?start=${_day(start)}&end=${_day(end)}'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the figures'));
  }

  /// The payments in the range as CSV text.
  static Future<String> getFinanceCsv(String token, DateTime start, DateTime end) async {
    final response = await _http.get(
        Uri.parse('$baseUrl/admin/finance/export?start=${_day(start)}&end=${_day(end)}'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return utf8.decode(response.bodyBytes);
    throw Exception(_errorDetail(response, 'Could not download the payments'));
  }

  // ── PROMO CODES ─────────────────────────────────────────────────────────────

  /// {valid, discount, message, code} for this basket.
  static Future<Map<String, dynamic>> checkPromo(String token,
      {required String code, required int restaurantId, required int subtotal,
      required int deliveryFee, required bool delivery}) async {
    final response = await _http.post(Uri.parse('$baseUrl/promo/check'),
        headers: _jsonAuth(token),
        body: jsonEncode({
          'code': code, 'restaurant_id': restaurantId, 'subtotal': subtotal,
          'delivery_fee': deliveryFee, 'fulfillment_method': delivery ? 'delivery' : 'pickup',
        }));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not check the code'));
  }

  static Future<List<Map<String, dynamic>>> getPromos(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/promos'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not load promo codes'));
  }

  static Future<Map<String, dynamic>> createPromo(String token, Map<String, dynamic> body) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/promos'),
        headers: _jsonAuth(token), body: jsonEncode(body));
    if (response.statusCode == 201) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not create the code'));
  }

  static Future<Map<String, dynamic>> updatePromo(String token, int id, Map<String, dynamic> body) async {
    final response = await _http.patch(Uri.parse('$baseUrl/admin/promos/$id'),
        headers: _jsonAuth(token), body: jsonEncode(body));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not update the code'));
  }

  // ── ANNOUNCEMENTS AND PLATFORM SWITCHES ─────────────────────────────────────

  static Future<Map<String, dynamic>> getAnnouncements(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/announcements'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load announcements'));
  }

  static Future<Map<String, dynamic>> sendAnnouncement(String token,
      {required String audience, required String kind, required String title, required String body}) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/announcements'),
        headers: _jsonAuth(token),
        body: jsonEncode({'audience': audience, 'kind': kind, 'title': title, 'body': body}));
    if (response.statusCode == 201) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not send the announcement'));
  }

  static Future<Map<String, dynamic>> getPlatformSettings(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/platform'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the settings'));
  }

  static Future<Map<String, dynamic>> setPlatformSettings(String token, Map<String, dynamic> body) async {
    final response = await _http.put(Uri.parse('$baseUrl/admin/platform'),
        headers: _jsonAuth(token), body: jsonEncode(body));
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not save the settings'));
  }

  /// Whether ordering and delivery are open right now (public).
  static Future<Map<String, dynamic>> getPlatformStatus() async {
    final response = await _publicGet('$baseUrl/platform/status');
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not check if FindFood is open'));
  }

  // ── SUPPORT INBOX AND REVIEWS ───────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMySupportThreads(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/support/threads'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not load your messages'));
  }

  static Future<Map<String, dynamic>> startSupportThread(String token,
      {required String subject, required String body, int? orderId}) async {
    final response = await _http.post(Uri.parse('$baseUrl/support/threads'),
        headers: _jsonAuth(token),
        body: jsonEncode({'subject': subject, 'body': body, if (orderId != null) 'order_id': orderId}));
    if (response.statusCode == 201) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not send your message'));
  }

  static Future<Map<String, dynamic>> getMySupportThread(String token, int id) async {
    final response = await _http.get(Uri.parse('$baseUrl/support/threads/$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the conversation'));
  }

  static Future<void> replyToSupport(String token, int id, String body) async {
    final response = await _http.post(Uri.parse('$baseUrl/support/threads/$id/messages'),
        headers: _jsonAuth(token), body: jsonEncode({'body': body}));
    if (response.statusCode != 201) throw Exception(_errorDetail(response, 'Could not send'));
  }

  static Future<Map<String, dynamic>> getSupportInbox(String token, String status) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/support?status=$status'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the inbox'));
  }

  static Future<Map<String, dynamic>> getAdminSupportThread(String token, int id) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/support/$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the conversation'));
  }

  static Future<void> replyAsSupport(String token, int id, String body) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/support/$id/messages'),
        headers: _jsonAuth(token), body: jsonEncode({'body': body}));
    if (response.statusCode != 201) throw Exception(_errorDetail(response, 'Could not send'));
  }

  static Future<void> setSupportThreadStatus(String token, int id, {required bool close}) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/support/$id/status?close=$close'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not update it'));
  }

  static Future<List<Map<String, dynamic>>> getAdminReviews(String token, String show) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/reviews?show=$show'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not load reviews'));
  }

  static Future<void> hideReview(String token, int id, String reason) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/reviews/$id/hide'),
        headers: _jsonAuth(token), body: jsonEncode({'reason': reason}));
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not hide it'));
  }

  static Future<void> showReview(String token, int id) async {
    final response = await _http.post(Uri.parse('$baseUrl/admin/reviews/$id/show'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) throw Exception(_errorDetail(response, 'Could not show it'));
  }

  /// Announcements this person hasn't seen yet (shown as a banner).
  static Future<List<Map<String, dynamic>>> getUnseenAnnouncements(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/announcements/unseen'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not check for announcements'));
  }

  /// One announcement in full; opening it marks it seen.
  static Future<Map<String, dynamic>> openAnnouncement(String token, int id) async {
    final response = await _http.get(Uri.parse('$baseUrl/announcements/$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not open the announcement'));
  }

  /// An order's map: the shop, the drop-off and where the rider is now.
  static Future<Map<String, dynamic>> getOrderTracking(String token, int orderId) async {
    final response = await _http.get(Uri.parse('$baseUrl/orders/$orderId/tracking'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return _decode(response);
    throw Exception(_errorDetail(response, 'Could not load the map'));
  }

  /// Admin: riders out on deliveries right now, with where they are.
  static Future<List<Map<String, dynamic>>> getLiveRiders(String token) async {
    final response = await _http.get(Uri.parse('$baseUrl/admin/riders/live'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(_decodeList(response));
    throw Exception(_errorDetail(response, 'Could not load the riders'));
  }

  /// The rider's phone reports where it is. Returns whether to keep sharing
  /// (only while the rider has a delivery).
  static Future<bool> updateRiderLocation(String token,
      {required double lat, required double lng, double? heading}) async {
    final response = await _http.put(Uri.parse('$baseUrl/riders/me/location'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'lat': lat, 'lng': lng, if (heading != null) 'heading': heading}));
    if (response.statusCode == 200) return _decode(response)['sharing'] == true;
    throw Exception(_errorDetail(response, 'Could not share your location'));
  }
}
