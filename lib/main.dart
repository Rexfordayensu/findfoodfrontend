import 'widgets/announcement_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'web_url_strategy_stub.dart'
    if (dart.library.html) 'package:flutter_web_plugins/flutter_web_plugins.dart'
    as web_plugins;
import 'theme.dart';
import 'services/providers.dart';
import 'services/otp_provider.dart';
import 'services/notifications_provider.dart';
import 'services/crash_reporter.dart';
import 'screens/auth/google_oauth_flow.dart';
import 'router.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    web_plugins.setUrlStrategy(web_plugins.PathUrlStrategy());
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final authProvider = AuthProvider();
  final cartProvider = CartProvider();
  final notificationsProvider = NotificationsProvider();
  authProvider.addListener(() {
    if (!authProvider.isLoggedIn && !cartProvider.isEmpty) {
      cartProvider.clearCart();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: notificationsProvider),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => OrderPollingProvider()), // NEW
      ],
      child: const FindFoodApp(),
    ),
  );
}

class FindFoodApp extends StatefulWidget {
  const FindFoodApp({super.key});

  @override
  State<FindFoodApp> createState() => _FindFoodAppState();
}

class _FindFoodAppState extends State<FindFoodApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _router = createAppRouter(auth, navigatorKey: _navigatorKey);
    CrashReporter.install(
      token: () => auth.token,
      route: () => _router.routeInformationProvider.value.uri.path,
    );
    if (!kDebugMode) ErrorWidget.builder = (_) => const BrokenSection();
    // The bell follows sign-in and sign-out.
    final notifications = context.read<NotificationsProvider?>();
    if (notifications != null) {
      void follow() => notifications.updateAuth(auth);
      auth.addListener(follow);
      follow();
    }
    // A notification tapped while the app is open goes to its page.
    notifications?.onOpen = (location) {
      if (location.startsWith('/order-tracking/') || location.startsWith('/chat/') ||
          location.startsWith('/announcements/') || location.startsWith('/support/')) {
        _router.push(location);
      } else {
        _router.go(location);
      }
    };
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await auth.initializeFromSecureStorage();
      try {
        await GoogleOAuthFlowService.initializeDeepLinkHandling(
          authProvider: auth,
          navigatorKey: _navigatorKey,
        );
      } catch (error) {
        // Deep links are optional; a platform without the plugin must still start.
        debugPrint('Deep link handling unavailable: $error');
      }
      // Sign-in links are handled only on /auth/callback (above). A generic
      // "?token=" check used to run on every page and signed people in with
      // their password-reset token, throwing them off the reset page.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'FindFood',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          scaffoldMessengerKey: appScaffoldMessengerKey,
          routerConfig: _router,
          // Unseen announcements pop up over any page.
          builder: (context, child) =>
              AnnouncementGate(navigatorKey: _navigatorKey, child: child ?? const SizedBox()),
        );
      },
    );
  }
}
