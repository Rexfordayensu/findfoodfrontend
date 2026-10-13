// Renders the main screens with real fonts and sample data and saves PNGs,
// for reviewing the visual design.
//
//   flutter test test/visual/screenshots_test.dart \
//     --dart-define=SCREENSHOTS_DIR=C:/path/to/output
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:findfood_app/main.dart';
import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/services/otp_provider.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/live_refresh.dart';
import 'package:findfood_app/widgets/promotion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

const outDir = String.fromEnvironment('SCREENSHOTS_DIR');

Future<void> loadFonts() async {
  final jakarta = FontLoader('PlusJakartaSans');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync();
    jakarta.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await jakarta.load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? 'C:/flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(File(
            '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
        .readAsBytesSync()
        .buffer)));
  await icons.load();
}

http.Response json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json; charset=utf-8'});

final now = DateTime.now().toUtc();
String ago(int minutes) =>
    now.subtract(Duration(minutes: minutes)).toIso8601String();

Map<String, dynamic> restaurant(int id, String name, String cuisine,
        {bool open = true, double? rating, int count = 0}) =>
    {
      'id': id, 'name': name, 'cuisine_type': cuisine, 'address': 'Osu, Accra',
      'email': 'r$id@example.com', 'is_active': true, 'is_approved': true,
      'owner_id': 3, 'is_open': open, 'average_rating': rating,
      'rating_count': count,
    };

Map<String, dynamic> order(int id, String status,
        {String method = 'delivery', int total = 4500, int minutes = 30,
        bool rated = false}) =>
    {
      'id': id, 'total_amount': total, 'status': status, 'restaurant_id': 1,
      'user_id': 1, 'restaurant_name': "Mama's Kitchen",
      'fulfillment_method': method, 'delivery_address': 'Labone, Accra',
      'created_at': ago(minutes), 'is_rated': rated,
      'items': [
        {'id': id, 'menu_item_id': 1, 'quantity': 1, 'name': 'Jollof',
         'price': 4000, 'image_url': null, 'is_available': true},
        if (id.isOdd)
          {'id': id + 100, 'menu_item_id': 2, 'quantity': 2, 'name': 'Waakye',
           'price': 3500, 'image_url': null, 'is_available': true},
      ],
    };

final routes = <String, Object>{
  '/restaurants': [
    restaurant(1, "Mama's Kitchen", 'Ghanaian', rating: 4.7, count: 128),
    restaurant(2, 'Burger Lab', 'Fast food', rating: 4.4, count: 56),
    restaurant(3, 'Napoli Slice', 'Pizza', open: false),
  ],
  '/promotions': [
    {'id': 1, 'restaurant_id': 1, 'restaurant_name': "Mama's Kitchen",
     'title': 'Jollof Fridays', 'discount_percent': 20, 'image_url': null,
     'is_active': true, 'created_at': ago(60)},
    {'id': 2, 'restaurant_id': 2, 'restaurant_name': 'Burger Lab',
     'title': 'Two smash burgers', 'discount_percent': 15, 'image_url': null,
     'is_active': true, 'created_at': ago(90)},
  ],
  '/orders': [
    order(41, 'preparing', minutes: 12),
    order(39, 'delivered', minutes: 60 * 26, total: 4099),
    order(37, 'delivered', minutes: 60 * 24 * 3, total: 3879, rated: true),
    order(36, 'cancelled', minutes: 60 * 24 * 9, total: 7970),
    order(35, 'picked_up', minutes: 60 * 24 * 30, total: 4449),
  ],
  '/deliveries/available': [
    order(41, 'ready', minutes: 5),
    order(42, 'preparing', total: 7800, minutes: 9),
  ],
  '/riders/me/analytics': {
    'total_deliveries': 58, 'completed_deliveries': 54, 'total_earnings': 38400,
    'avg_earning_per_delivery': 711, 'today_earnings': 2840,
    'today_deliveries': 6, 'week_earnings': 14250, 'month_earnings': 38400,
    'average_rating': 4.8,
    'recent_deliveries': [
      {'order_id': 37, 'restaurant_name': "Mama's Kitchen", 'earning': 450,
       'completed_at': ago(40)},
      {'order_id': 35, 'restaurant_name': 'Burger Lab', 'earning': 620,
       'completed_at': ago(160)},
    ],
  },
  '/restaurants/mine': restaurant(1, "Mama's Kitchen", 'Ghanaian',
      rating: 4.7, count: 128),
  '/restaurants/mine/analytics': {
    'total_orders': 214, 'delivered_orders': 198, 'total_revenue': 942300,
    'avg_order_value': 4759,
    'top_items': [{'name': 'Jollof Rice', 'count': 92}, {'name': 'Waakye', 'count': 61}],
    'daily_revenue': [
      for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
        {'day': d, 'revenue': 90000 + d.length * 12000}
    ],
  },
  '/restaurants/1/promotions': [],
  '/restaurants/1/menu/manage': [
    {'id': 1, 'name': 'Jollof Rice', 'description': 'Smoky party jollof',
     'price': 4000, 'is_available': true, 'restaurant_id': 1},
    {'id': 2, 'name': 'Waakye Special', 'description': 'With gari & shito',
     'price': 3500, 'is_available': true, 'restaurant_id': 1},
  ],
  '/admin/stats': {'total_orders': 1284, 'revenue_today': 2183400,
    'active_riders': 37, 'total_restaurants': 52, 'pending_approvals': 3},
  '/admin/restaurants/pending': [
    {'id': 9, 'name': 'Kenkey Corner', 'cuisine_type': 'Local',
     'address': 'Tema', 'email': 'k@example.com'},
  ],
  '/admin/notifications': [
    {'kind': 'approval', 'title': 'Restaurant awaiting approval',
     'detail': 'Kenkey Corner (Local) is waiting for review.'},
  ],
  '/admin/activity': [
    {'kind': 'order', 'title': 'Order #1284 placed',
     'detail': "Mama's Kitchen · GH₵ 45.00 · delivery", 'at': ago(1)},
    {'kind': 'payment', 'title': 'Payment received for order #1284',
     'detail': 'GH₵ 45.00 · paystack', 'at': ago(1)},
    {'kind': 'rating', 'title': '5★ rating for Burger Lab',
     'detail': 'Order #1270 · “Hot and fast!”', 'at': ago(14)},
    {'kind': 'restaurant', 'title': 'Kenkey Corner applied to join',
     'detail': 'Local · awaiting approval', 'at': ago(55)},
  ],
};

var currentRole = 'customer';
var currentName = 'Rexford';

final client = MockClient((request) async {
  if (request.url.path == '/auth/me') {
    return json({'id': 1, 'name': currentName, 'email': 'rexford@example.com',
        'role': currentRole, 'provider': 'local', 'is_approved': true});
  }
  final body = routes[request.url.path];
  return body == null ? json([]) : json(body);
});

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<GlobalKey> launch(WidgetTester tester,
    {required String role, required String name, required bool dark,
    Size size = const Size(400, 860), CartProvider? cart}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  FlutterSecureStorage.setMockInitialValues({});
  currentRole = role;
  currentName = name;
  final auth = AuthProvider();
  if (role != 'guest') {
    await auth.login(token: 't', userId: 1, role: role, name: name,
        email: 'rexford@example.com', isRestaurantApproved: true);
  }
  final theme = ThemeProvider();
  if (theme.isDark != dark) theme.toggle();
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => cart ?? CartProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => OrderPollingProvider()),
      ],
      child: const FindFoodApp(),
    ),
  ));
  return key;
}

void main() {
  if (outDir.isEmpty) {
    test('screenshots', () {}, skip: 'Pass --dart-define=SCREENSHOTS_DIR=...');
    return;
  }
  setUpAll(() async {
    AuthProvider.refreshInterval = null;
    LiveRefresh.interval = null;
    PromotionCarousel.autoAdvanceEvery = null;
    Directory(outDir).createSync(recursive: true);
    await loadFonts();
  });

  Future<void> shoot(WidgetTester tester, String file,
      {required String role, required String name, required bool dark,
      String? tab, Size size = const Size(400, 860), CartProvider? cart,
      String? then}) async {
    debugDisableShadows = false; // render real soft shadows
    await http.runWithClient(() async {
      final key = await launch(tester,
          role: role, name: name, dark: dark, size: size, cart: cart);
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      if (tab != null) {
        final byTooltip = find.byTooltip(tab);
        await tester.tap(byTooltip.evaluate().isNotEmpty
            ? byTooltip.first
            : find.text(tab).last);
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      if (then != null) {
        await tester.tap(find.text(then).last);
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      await capture(tester, key, file);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }, () => client);
    tester.view.reset();
    debugDisableShadows = true; // flutter_test requires the default back
  }

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('customer feed $mode', (t) =>
        shoot(t, 'customer_feed_$mode', role: 'customer', name: 'Rexford', dark: dark));
    testWidgets('rider jobs $mode', (t) =>
        shoot(t, 'rider_jobs_$mode', role: 'rider', name: 'Kofi', dark: dark));
    testWidgets('rider earnings $mode', (t) => shoot(t, 'rider_earnings_$mode',
        role: 'rider', name: 'Kofi', dark: dark, tab: 'Earnings'));
    testWidgets('restaurant orders $mode', (t) =>
        shoot(t, 'restaurant_orders_$mode', role: 'restaurant', name: 'Esi', dark: dark));
    testWidgets('admin overview $mode', (t) =>
        shoot(t, 'admin_overview_$mode', role: 'admin', name: 'Ade', dark: dark));
  }
  for (final dark in [false, true]) {
    testWidgets('login ${dark ? 'dark' : 'light'}', (t) => shoot(t,
        'login_${dark ? 'dark' : 'light'}',
        role: 'guest', name: '', dark: dark, tab: 'Sign in'));
  }
  testWidgets('restaurant settings light', (t) => shoot(t,
      'restaurant_settings_light', role: 'restaurant', name: 'Esi', dark: false, tab: 'Settings'));
  testWidgets('rider profile light', (t) => shoot(t, 'rider_profile_light',
      role: 'rider', name: 'Kofi', dark: false, tab: 'Profile'));
  CartProvider sampleCart() {
    MenuItem item(int id, String name, int price) => MenuItem(
        id: id, name: name, price: price, isAvailable: true, restaurantId: 1);
    return CartProvider()
      ..addItem(item(1, 'Waakye and salad', 5000), 1, "Mina's Launch",
          restaurantAddress: 'Lapaz, Accra')
      ..addItem(item(2, 'Grilled tilapia with banku', 8500), 1, "Mina's Launch",
          restaurantAddress: 'Lapaz, Accra')
      ..addItem(item(2, 'Grilled tilapia with banku', 8500), 1, "Mina's Launch",
          restaurantAddress: 'Lapaz, Accra');
  }
  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('checkout $mode', (t) => shoot(t, 'checkout_$mode',
        role: 'customer', name: 'Rexford', dark: dark, tab: 'Cart',
        cart: sampleCart()));
  }
  testWidgets('checkout pickup light', (t) => shoot(t, 'checkout_pickup_light',
      role: 'customer', name: 'Rexford', dark: false, tab: 'Cart',
      cart: sampleCart(), then: 'Pickup'));
  for (final dark in [false, true]) {
    testWidgets('orders ${dark ? 'dark' : 'light'}', (t) => shoot(t,
        'orders_${dark ? 'dark' : 'light'}',
        role: 'customer', name: 'Rexford', dark: dark, tab: 'Orders'));
  }
  testWidgets('admin desktop light', (t) => shoot(t, 'admin_desktop_light',
      role: 'admin', name: 'Ade', dark: false, size: const Size(1280, 860)));
}
