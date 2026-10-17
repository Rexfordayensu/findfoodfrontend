import 'screens/support_screen.dart';
import 'widgets/announcement_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
// Dashboards load on first use, so customers don't download them.
import 'screens/admin/admin_dashboard.dart' deferred as admin_page;
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/google_oauth_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/group_order_screen.dart';
import 'screens/customer/customer_pages.dart';
import 'screens/customer/food_feed_screen.dart';
import 'screens/customer/order_tracking_screen.dart';
import 'screens/customer/payment_return_screen.dart';
import 'screens/customer/menu_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/rider/rider_dashboard.dart' deferred as rider_page;
import 'screens/restaurant/restaurant_pending_approval_screen.dart' deferred as pending_page;
import 'screens/restaurants/restaurant_dashboard.dart' deferred as restaurant_page;
import 'services/api_service.dart';
import 'services/providers.dart';
import 'utils/web_url_helper.dart' show reloadPage;
import 'services/crash_reporter.dart';

GoRouter createAppRouter(
  AuthProvider auth, {
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  String? pendingLocation;

  return GoRouter(
    navigatorKey: navigatorKey,
    // On web the browser URL is the starting route (deep links, payment and
    // OAuth callbacks). Elsewhere Uri.base is the process working directory,
    // which is not an app route.
    initialLocation: kIsWeb
        ? Uri(
            path: Uri.base.path.isEmpty ? '/' : Uri.base.path,
            queryParameters: Uri.base.queryParameters.isEmpty
                ? null
                : Uri.base.queryParameters,
          ).toString()
        : '/',
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const FoodFeedScreen(initialNavIndex: 0),
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const FoodFeedScreen(initialNavIndex: 1),
      ),
      GoRoute(path: '/home', redirect: (_, __) => '/'),
      GoRoute(path: '/admin-dashboard', redirect: (_, __) => '/admin'),
      GoRoute(
          path: '/restaurant-dashboard',
          redirect: (_, __) => '/restaurant/orders'),
      GoRoute(path: '/rider-dashboard', redirect: (_, __) => '/rider'),
      GoRoute(path: '/loading', builder: (_, __) => const _LoadingScreen()),
      GoRoute(
          path: '/auth/callback', builder: (_, __) => const _LoadingScreen()),
      GoRoute(
        path: '/email-verification',
        builder: (_, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final role = state.uri.queryParameters['role'] ?? '';
          final mode = state.uri.queryParameters['mode'] == 'login'
              ? VerificationMode.login
              : VerificationMode.registration;
          final extra = state.extra;
          final password = extra is Map<String, dynamic>
              ? extra['password']?.toString()
              : null;
          return EmailVerificationScreen(
            email: email,
            role: role,
            password: password,
            mode: mode,
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          returnRoute: state.uri.queryParameters['returnTo'] ?? '/home',
        ),
      ),
      GoRoute(
        path: '/google-oauth',
        builder: (_, state) => GoogleOAuthScreen(
          returnRoute: state.uri.queryParameters['returnTo'] ?? '/home',
        ),
      ),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportInboxScreen()),
      GoRoute(
        path: '/group/:code',
        builder: (_, state) => GroupOrderScreen(code: state.pathParameters['code'] ?? ''),
      ),
      GoRoute(
        path: '/announcements/:id',
        builder: (_, state) =>
            AnnouncementScreen(announcementId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: '/support/:threadId',
        builder: (_, state) =>
            SupportThreadScreen(threadId: int.tryParse(state.pathParameters['threadId'] ?? '') ?? 0),
      ),
      GoRoute(path: '/terms', builder: (_, __) => const LegalScreen()),
      GoRoute(
          path: '/privacy', builder: (_, __) => const LegalScreen(privacy: true)),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'],
          // From an admin invitation: setting a first password.
          invite: state.uri.queryParameters['invite'] == '1',
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, state) => CartScreen(
          paymentReference: state.uri.queryParameters['reference'] ??
              state.uri.queryParameters['trxref'],
        ),
      ),
      GoRoute(
        path: '/payment/callback',
        builder: (_, state) => PaymentReturnScreen(
          reference: state.uri.queryParameters['reference'] ??
              state.uri.queryParameters['trxref'],
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const CustomerOrdersScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/order-tracking/:orderId',
        builder: (_, state) {
          final order = state.extra;
          if (order is Order) return OrderTrackingScreen(order: order);
          // Opened by link or after a page reload: look the order up.
          return _OrderTrackingLoader(
              orderId: int.tryParse(state.pathParameters['orderId'] ?? ''));
        },
      ),
      GoRoute(
        path: '/restaurants/:restaurantId',
        builder: (_, state) {
          final restaurant = state.extra;
          if (restaurant is Restaurant) {
            return MenuDetailScreen(restaurant: restaurant);
          }
          return const _MissingRouteDataScreen();
        },
      ),
      GoRoute(
        // /chat/41?with=rider&name=Kofi - a private chat on order 41.
        path: '/chat/:orderId',
        builder: (_, state) {
          final orderId = int.tryParse(state.pathParameters['orderId'] ?? '');
          final query = state.uri.queryParameters;
          final withRole = query['with'];
          if (orderId == null ||
              !const {'customer', 'restaurant', 'rider'}.contains(withRole)) {
            return const _MissingRouteDataScreen();
          }
          return ChatScreen(
            orderId: orderId,
            withRole: withRole!,
            otherPartyName: query['name'] ?? _roleTitle(withRole),
          );
        },
      ),
      GoRoute(
        path: '/restaurant/orders',
        builder: (context, __) => _Deferred(
          'restaurant',
          restaurant_page.loadLibrary,
          () => restaurant_page.RestaurantDashboard(
            token: context.read<AuthProvider>().token ?? '',
            initialIndex: 0,
          ),
        ),
      ),
      GoRoute(
        path: '/restaurant/menu',
        builder: (context, __) => _Deferred(
          'restaurant',
          restaurant_page.loadLibrary,
          () => restaurant_page.RestaurantDashboard(
            token: context.read<AuthProvider>().token ?? '',
            initialIndex: 1,
          ),
        ),
      ),
      GoRoute(
        path: '/restaurant/earnings',
        builder: (context, __) => _Deferred(
          'restaurant',
          restaurant_page.loadLibrary,
          () => restaurant_page.RestaurantDashboard(
            token: context.read<AuthProvider>().token ?? '',
            initialIndex: 2,
          ),
        ),
      ),
      GoRoute(
        path: '/restaurant/reports',
        builder: (context, __) => _Deferred(
          'restaurant',
          restaurant_page.loadLibrary,
          () => restaurant_page.RestaurantDashboard(
            token: context.read<AuthProvider>().token ?? '',
            initialIndex: 3,
          ),
        ),
      ),
      GoRoute(
        path: '/restaurant/settings',
        builder: (context, __) => _Deferred(
          'restaurant',
          restaurant_page.loadLibrary,
          () => restaurant_page.RestaurantDashboard(
            token: context.read<AuthProvider>().token ?? '',
            initialIndex: 4,
          ),
        ),
      ),
      GoRoute(
        path: '/rider',
        builder: (_, __) => _Deferred('rider', rider_page.loadLibrary, () => rider_page.RiderDashboard()),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => _Deferred('admin', admin_page.loadLibrary, () => admin_page.AdminDashboard()),
      ),
      GoRoute(
        path: '/restaurant/pending',
        builder: (_, __) => _Deferred(
            'pending', pending_page.loadLibrary, () => pending_page.RestaurantPendingApprovalScreen()),
      ),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      if (!auth.isInitialized) {
        if (location != '/loading' && location != '/auth/callback') {
          pendingLocation ??= state.uri.toString();
        }
        return location == '/loading' || location == '/auth/callback'
            ? null
            : '/loading';
      }

      if (location == '/loading') {
        final requestedLocation = pendingLocation;
        pendingLocation = null;
        if (requestedLocation == null ||
            requestedLocation == '/' ||
            requestedLocation == '/home') {
          return _homeForRole(auth);
        }
        return requestedLocation;
      }
      if (location == '/auth/callback') return null;

      final paymentReference = state.uri.queryParameters['reference'] ??
          state.uri.queryParameters['trxref'];
      if (paymentReference != null &&
          paymentReference.isNotEmpty &&
          location != '/cart' &&
          location != '/payment/callback') {
        return Uri(
          path: '/payment/callback',
          queryParameters: {'reference': paymentReference},
        ).toString();
      }

      if (location == '/' && auth.isLoggedIn && auth.isRestaurant) {
        return _homeForRole(auth);
      }

      final isPublic = location == '/' ||
          location == '/home' ||
          location == '/login' ||
          location == '/email-verification' ||
          location == '/forgot-password' ||
          location == '/reset-password' ||
          location == '/google-oauth' ||
          location == '/terms' ||
          location == '/privacy';
      if (location == '/login' && auth.isLoggedIn) {
        final returnTo = state.uri.queryParameters['returnTo'];
        if (auth.isCustomer && returnTo != null && _isCustomerRoute(returnTo)) {
          return returnTo;
        }
        return _homeForRole(auth);
      }
      if (isPublic) return null;
      if (!auth.isLoggedIn) {
        final loginUri = Uri(
          path: '/login',
          queryParameters: {
            'returnTo': Uri(
              path: state.uri.path,
              queryParameters: state.uri.queryParameters,
            ).toString(),
          },
        );
        return loginUri.toString();
      }

      final restaurantRoute = location.startsWith('/restaurant/');
      final roleRoute = location == '/rider' || location == '/admin';
      // Pages every signed-in role uses.
      final conversationRoute = location.startsWith('/chat/') ||
          location.startsWith('/order-chat/') ||
          location == '/notifications' ||
          location == '/support' ||
          location.startsWith('/support/') ||
          location.startsWith('/announcements/');
      if (restaurantRoute && !auth.isRestaurant) return _homeForRole(auth);
      if (location == '/rider' && !auth.isRider) return _homeForRole(auth);
      if (location == '/admin' && !auth.isAdmin) return _homeForRole(auth);
      if (!restaurantRoute &&
          !roleRoute &&
          !conversationRoute &&
          !auth.isCustomer) {
        return _homeForRole(auth);
      }
      return null;
    },
  );
}

String _homeForRole(AuthProvider auth) {
  switch (auth.role) {
    case 'restaurant':
      return auth.isRestaurantApproved
          ? '/restaurant/orders'
          : '/restaurant/pending';
    case 'rider':
      return '/rider';
    case 'admin':
      return '/admin';
    default:
      return '/';
  }
}

bool _isCustomerRoute(String route) {
  return route == '/' ||
      route == '/home' ||
      route == '/orders' ||
      route == '/profile' ||
      route == '/cart' ||
      route == '/checkout' ||
      route.startsWith('/payment/callback') ||
      route.startsWith('/restaurants/') ||
      route.startsWith('/group/');
}

/// Starts downloading a role's dashboard as soon as we know who signed in,
/// so it's usually ready before they get there.
void preloadDashboardFor(String? role) {
  switch (role) {
    case 'admin':
      _load('admin', admin_page.loadLibrary);
    case 'rider':
      _load('rider', rider_page.loadLibrary);
    case 'restaurant':
      _load('restaurant', restaurant_page.loadLibrary);
      _load('pending', pending_page.loadLibrary);
  }
}

final _loads = <String, Future<void>>{};
var _reloading = false;

Future<void> _load(String name, Future<void> Function() loader) =>
    _loads.putIfAbsent(name, () => _withRetries(loader));

/// Mobile data drops out: try a page's download a few times before giving up.
Future<void> _withRetries(Future<void> Function() loader) async {
  for (var attempt = 1;; attempt++) {
    try {
      return await loader();
    } catch (_) {
      if (attempt >= 3) rethrow;
      await Future<void>.delayed(Duration(milliseconds: 700 * attempt));
    }
  }
}

final _reported = <String>{};

/// A page from a deferred library: a spinner until its code has arrived.
///
/// If FindFood was updated while the app was open, the page's code on the
/// server belongs to the new version and the open (old) app can't load it.
/// Reloading picks up the new version, so that happens once by itself.
class _Deferred extends StatelessWidget {
  final String name;
  final Future<void> Function() loader;
  final Widget Function() page;
  const _Deferred(this.name, this.loader, this.page);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load(name, loader),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) return page();
        if (snapshot.hasError) {
          if (_reloading || reloadPage(onlyOnce: true)) {
            _reloading = true;
            return const _LoadingScreen();
          }
          final error = snapshot.error!;
          // Tell us what went wrong, once per page (Admin → Reports → Errors).
          if (_reported.add(name)) {
            CrashReporter.report(error, snapshot.stackTrace, context: 'loading the $name page');
          }
          final detail = '$error';
          return Scaffold(
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text("Couldn't load this page. Check your connection."),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                  child: Text(detail.length > 160 ? '${detail.substring(0, 160)}…' : detail,
                      key: const Key('deferred-error-detail'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                ),
                TextButton(
                  onPressed: () {
                    if (reloadPage()) return;
                    _loads.remove(name);
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Try again'),
                ),
              ]),
            ),
          );
        }
        return const _LoadingScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _MissingRouteDataScreen extends StatelessWidget {
  const _MissingRouteDataScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order unavailable')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/orders'),
          child: const Text('Back to orders'),
        ),
      ),
    );
  }
}

class _OrderTrackingLoader extends StatefulWidget {
  final int? orderId;
  const _OrderTrackingLoader({required this.orderId});

  @override
  State<_OrderTrackingLoader> createState() => _OrderTrackingLoaderState();
}

class _OrderTrackingLoaderState extends State<_OrderTrackingLoader> {
  late final Future<Order?> _order = _load();

  Future<Order?> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || widget.orderId == null) return null;
    final orders = await ApiService.getMyOrders(token);
    return orders.where((o) => o.id == widget.orderId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order?>(
      future: _order,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }
        final order = snapshot.data;
        if (order == null) return const _MissingRouteDataScreen();
        return OrderTrackingScreen(order: order);
      },
    );
  }
}

String _roleTitle(String role) => switch (role) {
      'restaurant' => 'Restaurant',
      'rider' => 'Rider',
      _ => 'Customer',
    };
