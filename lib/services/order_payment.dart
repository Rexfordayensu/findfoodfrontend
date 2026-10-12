import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/models.dart';
import '../theme.dart';
import '../widgets/account_settings.dart' show SheetHeader, showSettingsSheet;
import '../widgets/widgets.dart';
import 'api_service.dart';
import 'providers.dart';

/// Pays for an existing order: the customer picks a payment method, completes
/// it with the provider, and the app waits for the backend to confirm.
class OrderPayment {
  static Duration pollInterval = const Duration(seconds: 5);
  static Duration timeout = const Duration(minutes: 3);

  /// Returns true once the payment is confirmed, false if the customer
  /// backed out or confirmation did not arrive in time. Throws on errors.
  static Future<bool> start(BuildContext context, Order order) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) throw Exception('Please sign in to pay for your order.');

    final providers = await ApiService.getPaymentProviders();
    if (providers.isEmpty) {
      throw Exception(
          'Online payment is not available right now. Your order is saved; please try again shortly.');
    }
    if (!context.mounted) return false;
    final choice = providers.length == 1
        ? providers.first
        : await _chooseProvider(context, providers, order);
    if (choice == null || !context.mounted) return false;

    if (choice.requiresPhone) {
      return _payWithMomo(context, token, order);
    }
    return _payWithPaystack(context, token, order, choice.value);
  }

  static Future<bool> _payWithPaystack(
      BuildContext context, String token, Order order, String provider) async {
    // On the web, checkout replaces this page, so Paystack must send the
    // customer back to this same site to confirm the payment.
    final init = await ApiService.initializePayment(
        token: token,
        orderId: order.id,
        provider: provider,
        callbackUrl:
            kIsWeb ? '${Uri.base.origin}/payment/callback' : null);
    final url = init['authorization_url'] as String?;
    final reference = init['reference'] as String?;
    if (url == null || reference == null) {
      throw Exception('Invalid payment initialization response.');
    }
    await launchUrlString(url,
        mode: LaunchMode.platformDefault, webOnlyWindowName: '_self');
    if (!context.mounted) return false;
    _snack(context, 'Complete the payment in the checkout page.');
    return _waitFor(context, () async {
      final verification =
          await ApiService.verifyPayment(token: token, reference: reference);
      final status = verification['status']?.toString().toLowerCase();
      if (status == 'failed') return false;
      return status == 'success' ? true : null;
    });
  }

  static Future<bool> _payWithMomo(
      BuildContext context, String token, Order order) async {
    final phone = await _askPhone(context);
    if (phone == null || !context.mounted) return false;
    final result = await ApiService.initiateMomoPayment(
        token: token, orderId: order.id, phoneNumber: phone);
    final reference = result['reference_id']?.toString();
    if (reference == null) throw Exception('MoMo did not return a reference.');
    if (!context.mounted) return false;
    _snack(context, 'Approve the payment prompt on $phone.');
    return _waitFor(context, () async {
      final status =
          await ApiService.checkMomoStatus(token: token, referenceId: reference);
      if (status == 'failed') return false;
      return status == 'successful' ? true : null;
    });
  }

  /// Polls [check] until it returns true/false (null means "keep waiting").
  static Future<bool> _waitFor(
      BuildContext context, Future<bool?> Function() check) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(pollInterval);
      if (!context.mounted) return false;
      try {
        final result = await check();
        if (result != null) return result;
      } catch (_) {
        // Keep waiting while the provider finishes processing.
      }
    }
    return false;
  }

  static Future<PaymentProviderOption?> _chooseProvider(BuildContext context,
      List<PaymentProviderOption> providers, Order order) {
    return showSettingsSheet<PaymentProviderOption>(
      context,
      Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
                title: 'Choose payment method',
                subtitle: 'Total ${order.displayTotal}'),
            for (final provider in providers)
              ListTile(
                key: Key('pay-with-${provider.value}'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                    provider.requiresPhone
                        ? Icons.phone_android_rounded
                        : Icons.credit_card_rounded,
                    color: AppTheme.accent),
                title: Text(provider.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(sheetContext).pop(provider),
              ),
          ],
        ),
      ),
    );
  }

  static Future<String?> _askPhone(BuildContext context) {
    final controller = TextEditingController();
    return showSettingsSheet<String>(
      context,
      Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHeader(
                title: 'MTN Mobile Money',
                subtitle: 'Enter the number that will approve the payment.'),
            AppTextField(
              key: const Key('momo-phone-field'),
              controller: controller,
              hint: 'e.g. 0241234567',
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Send payment request',
              onPressed: () {
                final phone = controller.text.trim();
                if (phone.length < 9) return;
                Navigator.of(sheetContext).pop(phone);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }
}
