import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import 'api_service.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

Future<bool> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

void showLogoutSuccess(BuildContext context) {
  final messenger = appScaffoldMessengerKey.currentState ??
      ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(const SnackBar(
    content: Text('Signed out successfully.'),
  ));
}

// ─── THEME PROVIDER ───────────────────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  // Start in the device's own light/dark setting.
  ThemeMode _mode =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// ─── AUTH PROVIDER ────────────────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _roleKey = 'auth_role';
  static const String _nameKey = 'auth_name';
  static const String _emailKey = 'auth_email';
  static const String _approvedKey = 'auth_restaurant_approved';

  /// How often a signed-in session is renewed (tokens expire after 30 min on
  /// the server). Tests set this to null to avoid background timers.
  static Duration? refreshInterval = const Duration(minutes: 10);

  AuthProvider() {
    ApiService.onSessionInvalid = _handleSessionInvalid;
  }

  Timer? _refreshTimer;
  bool _handlingInvalidSession = false;

  String? _token;
  int? _userId;
  String? _role;
  String? _name;
  String? _email;
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  bool _isEmailVerified = false;
  bool _isRestaurantApproved = false;

  String? get token => _token;
  int? get userId => _userId;
  String? get role => _role;
  String? get name => _name;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  bool get isEmailVerified => _isEmailVerified;
  bool get isRestaurantApproved => _isRestaurantApproved;

  bool get isCustomer => _role == 'customer';
  bool get isRestaurant => _role == 'restaurant';
  bool get isRider => _role == 'rider';
  bool get isAdmin => _role == 'admin';

  Future<void> login(
      {required String token,
      required int userId,
      required String role,
      String? name,
      String? email,
      bool? isEmailVerified,
      bool? isRestaurantApproved}) async {
    _token = token;
    _userId = userId;
    _role = role;
    _name = name;
    _email = email;
    _isLoggedIn = true;
    _isEmailVerified = isEmailVerified ?? false;
    _isRestaurantApproved = isRestaurantApproved ?? false;
    _startTokenRefresh();
    notifyListeners();
    await _persistSession();
  }

  void _startTokenRefresh() {
    _refreshTimer?.cancel();
    final interval = refreshInterval;
    if (interval == null) return;
    _refreshTimer = Timer.periodic(interval, (_) => refreshSession());
  }

  /// Swaps the current token for a fresh one so active users stay signed in.
  Future<void> refreshSession() async {
    final current = _token;
    if (current == null) return;
    try {
      final data = await ApiService.refreshToken(current);
      final fresh = data['access_token']?.toString();
      if (fresh == null || fresh.isEmpty || _token != current) return;
      _token = fresh;
      if (data['is_approved'] != null) {
        _isRestaurantApproved = data['is_approved'] == true;
      }
      await _persistSession();
      notifyListeners();
    } catch (error) {
      // A 401 is handled by _handleSessionInvalid; network errors just wait
      // for the next attempt.
      debugPrint('Session refresh failed: $error');
    }
  }

  Future<void> _handleSessionInvalid(String message) async {
    if (!_isLoggedIn || _handlingInvalidSession) return;
    _handlingInvalidSession = true;
    try {
      await logout();
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      _handlingInvalidSession = false;
    }
  }

  Future<void> updateEmail(String email) async {
    _email = email.trim();
    await _persistSession();
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    if (ApiService.onSessionInvalid == _handleSessionInvalid) {
      ApiService.onSessionInvalid = null;
    }
    super.dispose();
  }

  void setEmailVerified(bool verified) {
    _isEmailVerified = verified;
    notifyListeners();
  }

  void setRestaurantApproved(bool approved) {
    _isRestaurantApproved = approved;
    notifyListeners();
    unawaited(_persistSession());
  }

  void setEmail(String? emailAddr) {
    _email = emailAddr;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _name = name.trim();
    await _persistSession();
    notifyListeners();
  }

  Future<void> initializeFromSecureStorage() async {
    String? token;
    try {
      token = await _secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) return;

      final user = await ApiService.getCurrentUser(token);
      final userId = user['user_id'] ?? user['id'];
      final role = user['role']?.toString().toLowerCase();

      _token = token;
      _userId = userId is int
          ? userId
          : int.tryParse(userId?.toString() ?? '0');
      _role = role;
      _name = user['name']?.toString();
      _email = user['email']?.toString();
      _isEmailVerified = user['is_verified'] == true ||
          user['email_verified'] == true ||
          user['is_email_verified'] == true;
      _isRestaurantApproved = user['is_approved'] == true;
      _isLoggedIn = true;
      _startTokenRefresh();
      await _persistSession();
      unawaited(refreshSession());
    } on SessionExpiredException catch (error) {
      debugPrint('Stored auth session was rejected: $error');
      await clearPersistedSession();
    } catch (error) {
      // The backend could not be reached; keep the stored session so the user
      // is not signed out by a temporary network or server problem.
      debugPrint('Unable to verify auth session: $error');
      if (token != null && token.isNotEmpty) await _restoreCachedSession(token);
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _restoreCachedSession(String token) async {
    try {
      final role = await _secureStorage.read(key: _roleKey);
      if (role == null || role.isEmpty) return;
      _token = token;
      _role = role;
      _userId = int.tryParse(await _secureStorage.read(key: _userIdKey) ?? '');
      _name = await _secureStorage.read(key: _nameKey);
      _email = await _secureStorage.read(key: _emailKey);
      _isRestaurantApproved =
          await _secureStorage.read(key: _approvedKey) == 'true';
      _isLoggedIn = true;
      _startTokenRefresh();
    } catch (error) {
      debugPrint('Unable to read cached auth session: $error');
    }
  }

  Future<void> _persistSession() async {
    if (_token == null || _token!.isEmpty) return;
    await _secureStorage.write(key: _tokenKey, value: _token);
    await _secureStorage.write(
        key: _userIdKey, value: _userId?.toString() ?? '0');
    await _secureStorage.write(key: _roleKey, value: _role ?? 'customer');
    await _secureStorage.write(key: _nameKey, value: _name ?? '');
    await _secureStorage.write(key: _emailKey, value: _email ?? '');
    await _secureStorage.write(
        key: _approvedKey, value: _isRestaurantApproved.toString());
  }

  Future<void> clearPersistedSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _nameKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _approvedKey);
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _token = null;
    _userId = null;
    _role = null;
    _name = null;
    _email = null;
    _isLoggedIn = false;
    _isEmailVerified = false;
    _isRestaurantApproved = false;
    await clearPersistedSession();
    notifyListeners();
  }
}

// ─── CART PROVIDER ────────────────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  int? _restaurantId;
  String? _restaurantName;
  String? _restaurantAddress;

  List<CartItem> get items => _items;
  int? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  String? get restaurantAddress => _restaurantAddress;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  int get totalAmount => _items.fold(0, (s, i) => s + i.subtotal);
  String get displayTotal => 'GH₵ ${(totalAmount / 100).toStringAsFixed(2)}';

  List<Map<String, int>> get orderPayload => _items
      .map((i) => {'menu_item_id': i.menuItem.id, 'quantity': i.quantity})
      .toList();

  void addItem(
    MenuItem menuItem,
    int restaurantId,
    String restaurantName, {
    String? restaurantAddress,
  }) {
    if (_restaurantId != null && _restaurantId != restaurantId) {
      _items.clear();
      _restaurantAddress = null;
    }
    _restaurantId = restaurantId;
    _restaurantName = restaurantName;
    _restaurantAddress = restaurantAddress ?? _restaurantAddress;
    final existing = _items.where((i) => i.menuItem.id == menuItem.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
  }

  void decreaseItem(int menuItemId) {
    // collection's firstOrNull requires Dart 3.0+ or collection package
    final item = _items.where((i) => i.menuItem.id == menuItemId).firstOrNull;
    if (item == null) return;
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
      _restaurantAddress = null;
    }
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    _items.removeWhere((i) => i.menuItem.id == menuItemId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
      _restaurantAddress = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _restaurantAddress = null;
    notifyListeners();
  }

  // backward compat
  void setLoggedIn(bool value, {String? token, int? userId, String? role}) {}
}

// ─── ORDER POLLING PROVIDER ───────────────────────────────────────────────────
// Polls the backend every few seconds so restaurant/rider dashboards and the
// customer tracking screen update automatically without manual refresh.
class OrderPollingProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Timer? _timer;
  bool _polling = false;

  List<Order> get orders => _orders;
  bool get isPolling => _polling;

  /// Start polling /orders (for restaurant) every [interval]
  void startPollingMyOrders(String token,
      {Duration interval = const Duration(seconds: 5)}) {
    _polling = true;
    _poll(token);
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _poll(token));
  }

  /// Start polling /deliveries/available (for rider)
  void startPollingAvailable(String token,
      {Duration interval = const Duration(seconds: 5)}) {
    _polling = true;
    _pollAvailable(token);
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _pollAvailable(token));
  }

  Future<void> _poll(String token) async {
    try {
      final list = await ApiService.getMyOrders(token);
      _orders = list;
      notifyListeners();
    } catch (_) {
      // Silent fail — keep last known good state, retry next tick
    }
  }

  Future<void> _pollAvailable(String token) async {
    try {
      final list = await ApiService.getAvailableDeliveries(token);
      _orders = list;
      notifyListeners();
    } catch (_) {}
  }

  void stopPolling() {
    _timer?.cancel();
    _polling = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
