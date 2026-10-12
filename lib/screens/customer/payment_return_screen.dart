import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';

/// Landing page after the Paystack checkout redirects back to the app.
/// Confirms the payment with the backend, then opens live order tracking.
class PaymentReturnScreen extends StatefulWidget {
  final String? reference;
  const PaymentReturnScreen({super.key, this.reference});

  static Duration retryEvery = const Duration(seconds: 3);
  static int maxAttempts = 20;

  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

enum _Stage { checking, confirmed, failed, stillWaiting }

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  _Stage _stage = _Stage.checking;
  String? _detail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirm());
  }

  Future<void> _confirm() async {
    final reference = widget.reference?.trim();
    final token = context.read<AuthProvider>().token;
    if (reference == null || reference.isEmpty || token == null) {
      setState(() {
        _stage = _Stage.failed;
        _detail = 'We could not find this payment. Check your orders for its status.';
      });
      return;
    }
    if (_stage != _Stage.checking) setState(() => _stage = _Stage.checking);

    for (var attempt = 0; attempt < PaymentReturnScreen.maxAttempts; attempt++) {
      try {
        final result =
            await ApiService.verifyPayment(token: token, reference: reference);
        final status = result['status']?.toString().toLowerCase();
        if (status == 'success') {
          await _openTracking(token, result['order_id']);
          return;
        }
        if (status == 'failed' || status == 'abandoned' || status == 'reversed') {
          if (!mounted) return;
          setState(() {
            _stage = _Stage.failed;
            _detail = status == 'abandoned'
                ? 'The checkout was closed before paying. Your order is saved, so you can pay for it from Orders.'
                : 'The payment did not go through and you have not been charged. You can try again from Orders.';
          });
          return;
        }
      } catch (_) {
        // Paystack can take a moment to settle; keep checking.
      }
      await Future.delayed(PaymentReturnScreen.retryEvery);
      if (!mounted) return;
    }
    if (mounted) setState(() => _stage = _Stage.stillWaiting);
  }

  Future<void> _openTracking(String token, Object? orderId) async {
    Order? order;
    try {
      final orders = await ApiService.getMyOrders(token);
      order = orders.where((o) => o.id.toString() == orderId.toString()).firstOrNull;
    } catch (_) {
      // Tracking loads the order itself if we could not fetch it here.
    }
    if (!mounted) return;
    context.read<CartProvider>().clearCart();
    setState(() => _stage = _Stage.confirmed);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final id = order?.id ?? int.tryParse('$orderId');
    if (id == null) {
      context.go('/orders');
    } else {
      context.go('/order-tracking/$id', extra: order);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (_stage) {
      _Stage.checking => (
          'Confirming your payment',
          'This usually takes a few seconds. Please keep this page open.'
        ),
      _Stage.confirmed => ('Payment confirmed', 'Opening your order…'),
      _Stage.failed => ('Payment not completed', _detail ?? ''),
      _Stage.stillWaiting => (
          'Still confirming',
          'Paystack has not confirmed the payment yet. Your order will update '
              'automatically, so you can follow it from Orders.'
        ),
    };
    final done = _stage == _Stage.failed || _stage == _Stage.stillWaiting;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusMark(stage: _stage),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Column(
                      key: ValueKey(_stage),
                      children: [
                        Text(title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4)),
                        const SizedBox(height: 10),
                        Text(body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 14.5,
                                height: 1.45)),
                      ],
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('payment-return-orders'),
                        onPressed: () => context.go('/orders'),
                        child: const Text('Go to my orders'),
                      ),
                    ),
                    if (_stage == _Stage.stillWaiting) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _confirm,
                        child: const Text('Check again'),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back to restaurants'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMark extends StatelessWidget {
  final _Stage stage;
  const _StatusMark({required this.stage});

  @override
  Widget build(BuildContext context) {
    final Widget inner = switch (stage) {
      _Stage.checking => const SizedBox(
          key: ValueKey('spin'),
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
              strokeWidth: 5, color: AppTheme.accent, strokeCap: StrokeCap.round),
        ),
      _Stage.confirmed => const _Badge(
          key: ValueKey('ok'), icon: Icons.check_rounded, color: AppTheme.success),
      _Stage.failed => const _Badge(
          key: ValueKey('fail'), icon: Icons.close_rounded, color: AppTheme.danger),
      _Stage.stillWaiting => const _Badge(
          key: ValueKey('wait'),
          icon: Icons.schedule_rounded,
          color: AppTheme.accentDeep),
    };
    return SizedBox(
      width: 88,
      height: 88,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: inner,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Badge({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
      ),
      child: Icon(icon, color: color, size: 42),
    );
  }
}
