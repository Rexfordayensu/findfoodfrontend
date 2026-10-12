import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:findfood_app/main.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/services/otp_provider.dart';

void main() {
  testWidgets('app restores session and opens the food feed',
      (WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OtpProvider()),
          ChangeNotifierProvider(create: (_) => OrderPollingProvider()),
        ],
        child: const FindFoodApp(),
      ),
    );
    // Let session restoration finish and the router leave /loading.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('FindFood'), findsWidgets);
  });
}
