import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

// Custom exception for email not verified during login
class EmailNotVerifiedException implements Exception {
  final String message;
  EmailNotVerifiedException(this.message);

  @override
  String toString() => message;
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
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final inner = http.Client();
    try {
      final response = await inner.send(request);
      // Buffer the body so the inner client can be closed safely on web too.
      final bytes = await response.stream.toBytes();
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

  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '779814360612-t3r0i8l4pa2r8jqfb1bcd4nh8e429tot.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to retrieve security token from Google.');
      }

      // Send it to your FastAPI backend
      final response = await _http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      final data = _decode(response);
      if (response.statusCode == 200) {
        return data;
      }
      throw Exception(data['detail'] ?? 'Google backend registration failed.');
    } catch (e) {
      debugPrint('Google Auth Client Error Trace: $e');
      rethrow;
    }
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
    final response = await _http.get(Uri.parse('$baseUrl/restaurants'));
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
    final response = await _http.get(Uri.parse('$baseUrl/promotions'));
    if (response.statusCode == 200) {
      return _decodeList(response).map((p) => Promotion.fromJson(p)).toList();
    }
    throw Exception(_decode(response)['detail'] ?? 'Failed to load deals');
  }

  /// Turns a stored image path into a loadable URL (relative paths are
  /// served by the backend).
  static String? imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  static Future<List<Promotion>> getPromotions(int restaurantId) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/restaurants/$restaurantId/promotions'),
    );
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
    final response =
        await _http.get(Uri.parse('$baseUrl/restaurants/$restaurantId/menu'));
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
  }) async {
    final payload = <String, dynamic>{
      'restaurant_id': restaurantId,
      'items': items,
      'fulfillment_method': fulfillmentMethod,
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
      String token, int orderId, String newStatus) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status').replace(
      queryParameters: {
        'new_status': newStatus,
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
  }) async {
    final request = PaymentInitializationRequest(
      orderId: orderId,
      provider: provider,
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
  static Future<List<Map<String, dynamic>>> getChatMessages({
    required String token,
    required int orderId,
  }) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/orders/$orderId/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load messages');
  }

  static Future<Map<String, dynamic>> sendChatMessage({
    required String token,
    required int orderId,
    required String message,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/orders/$orderId/messages'),
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
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_errorDetail(response, 'Failed to submit rating'));
    }
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
  }) async {
    final response = await _http.patch(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name.trim()}),
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

  static Future<Map<String, dynamic>> sendMessage({
    required String token,
    required int orderId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/messages');

    try {
      final response = await _http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "message": content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      throw Exception(_decode(response)['detail'] ?? 'Failed to send message');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network connection error: $e');
    }
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
}
