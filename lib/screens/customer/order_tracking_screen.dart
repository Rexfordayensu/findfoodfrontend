import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/chat_button.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../services/order_payment.dart';
import '../../widgets/handoff_code.dart';
import '../../widgets/rating_sheet.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order _order;
  Timer? _pollTimer;
  bool _busy = false;

  List<Map<String, Object>> get _steps => _order.fulfillmentMethod == 'pickup'
      ? const [
          {
            'status': 'pending',
            'label': 'Order placed',
            'icon': Icons.receipt_long_outlined,
          },
          {
            'status': 'preparing',
            'label': 'Preparing food',
            'icon': Icons.soup_kitchen_outlined,
          },
          {
            'status': 'ready',
            'label': 'Ready for pickup',
            'icon': Icons.check_circle_outline,
          },
          {
            'status': 'picked_up',
            'label': 'Picked up',
            'icon': Icons.storefront_outlined,
          },
        ]
      : const [
          {
            'status': 'pending',
            'label': 'Order placed',
            'icon': Icons.receipt_long_outlined,
          },
          {
            'status': 'preparing',
            'label': 'Preparing food',
            'icon': Icons.soup_kitchen_outlined,
          },
          {
            'status': 'ready',
            'label': 'Ready for pickup',
            'icon': Icons.check_circle_outline,
          },
          {
            'status': 'out_for_delivery',
            'label': 'Rider on the way',
            'icon': Icons.electric_bike_outlined,
          },
          {
            'status': 'delivered',
            'label': 'Delivered',
            'icon': Icons.home_outlined,
          },
        ];

  List<String> get _statusOrder =>
      _steps.map((step) => step['status']! as String).toList();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Poll backend every 4s for live status updates ──────────────────────────
  void _startPolling() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null || !_order.isActive) return;

    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final orders = await ApiService.getMyOrders(auth.token!);
        final updated = orders.where((o) => o.id == _order.id).firstOrNull;
        if (updated != null && mounted && updated.status != _order.status) {
          setState(() => _order = updated);
          if (updated.isCompleted) {
            _pollTimer?.cancel();
            _showOrderComplete();
          } else if (updated.status == 'cancelled') {
            _pollTimer?.cancel();
          }
        }
      } catch (_) {
        // Silent — keep last known state
      }
    });
  }

  void _showOrderComplete() {
    final isPickup = _order.fulfillmentMethod == 'pickup';
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration_rounded,
                    color: AppTheme.success, size: 44),
              ),
            ),
            const SizedBox(height: 20),
            Text(isPickup ? 'Picked up!' : 'Delivered!',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Enjoy your meal! How was your experience?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary(context))),
            const SizedBox(height: 24),
            if (!_order.isRated) ...[
              PrimaryButton(
                key: const Key('complete-rate-order'),
                label: 'Rate order',
                icon: Icons.star_rounded,
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (await showRateOrderSheet(context, _order) && mounted) {
                    setState(() => _order = _order.copyWith(isRated: true));
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
            GhostButton(
              label: 'Back to home',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payNow() async {
    setState(() => _busy = true);
    try {
      final paid = await OrderPayment.start(context, _order);
      if (!mounted) return;
      if (paid) setState(() => _order = _order.copyWith(status: 'pending'));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelOrder() async {
    final paid = _order.status != 'awaiting_payment';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancel order #${_order.id}?'),
        content: Text(paid
            ? 'The restaurant has not started it yet. You will be refunded in full.'
            : 'This order has not been paid yet.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep order')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel order',
                  style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final updated = await ApiService.cancelOrder(
          context.read<AuthProvider>().token!, _order.id);
      if (!mounted) return;
      _pollTimer?.cancel();
      setState(() => _order = updated);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.success,
        content:
            Text(paid ? 'Order cancelled and refunded.' : 'Order cancelled.'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _headline {
    if (_order.status == 'awaiting_payment') return 'Awaiting payment';
    if (_order.status == 'cancelled') return 'Cancelled';
    if (_order.isCompleted) {
      return _order.fulfillmentMethod == 'pickup' ? 'Picked up' : 'Delivered';
    }
    if (_order.fulfillmentMethod == 'pickup') {
      return _order.status == 'ready' ? 'Ready for pickup' : 'Preparing';
    }
    return '25–35 min';
  }

  int get _currentStep {
    final index = _statusOrder.indexOf(_order.status);
    return index < 0 ? 0 : index;
  }

  /// Whether a step is finished. A completed order's last step is finished
  /// too, not "in progress".
  bool _stepDone(int i) =>
      _order.isCompleted ? i <= _currentStep : i < _currentStep;

  /// The step being worked on right now, if any. Nothing is in progress for
  /// unpaid, cancelled or completed orders.
  bool _stepActive(int i) =>
      _order.isActive &&
      _order.status != 'awaiting_payment' &&
      i == _currentStep;

  String? _stepNote(int i) {
    if (_stepActive(i)) return 'In progress...';
    final completedAt = _order.completedAt;
    if (_order.isCompleted && i == _steps.length - 1 && completedAt != null) {
      final h = completedAt.hour.toString().padLeft(2, '0');
      final m = completedAt.minute.toString().padLeft(2, '0');
      return 'Completed at $h:$m';
    }
    return null;
  }

  static String _statusLabel(String status) => switch (status) {
        'awaiting_payment' => 'Awaiting payment',
        'pending' => 'Order placed',
        'preparing' => 'Preparing',
        'ready' => 'Ready',
        'out_for_delivery' => 'On the way',
        'delivered' => 'Delivered',
        'picked_up' => 'Picked up',
        'cancelled' => 'Cancelled',
        _ => status.replaceAll('_', ' '),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/orders'),
        ),
        actions: [
          // Live indicator
          if (_order.isActive)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppTheme.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('Live',
                      style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── ETA Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.delivery_dining_rounded,
                    color: AppTheme.accent, size: 36),
                const SizedBox(height: 10),
                Text(
                    _order.fulfillmentMethod == 'pickup'
                        ? 'Pickup status'
                        : 'Estimated arrival',
                    style: TextStyle(color: AppColors.textSecondary(context))),
                const SizedBox(height: 6),
                Text(_headline,
                    style: TextStyle(
                      color: AppColors.accentText(context),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 8),
                StatusBadge(status: _order.status),
              ],
            ),
          ),
          if (_order.deliveryCode != null &&
              _order.isActive &&
              _order.status != 'awaiting_payment') ...[
            const SizedBox(height: 16),
            HandoffCodeCard(
              key: const Key('tracking-delivery-code'),
              title: _order.fulfillmentMethod == 'pickup'
                  ? 'Collection code'
                  : 'Delivery code',
              code: _order.deliveryCode!,
              icon: Icons.lock_outline_rounded,
              instructions: _order.fulfillmentMethod == 'pickup'
                  ? 'Show this code at the counter when you collect your order.'
                  : 'Give this code to your rider when your food arrives. '
                      'Only share it once you have your order.',
            ),
          ],
          if (_order.status != 'awaiting_payment' && !_order.isCancelled) ...[
            const SizedBox(height: 12),
            ChatButton.wide(
              key: const Key('tracking-open-chat'),
              title: 'Chat with the restaurant',
              withWhom: _order.restaurantName ?? 'The restaurant',
              onPressed: () => openOrderChat(context, _order.id, [
                ChatContact('restaurant', _order.restaurantName ?? 'Restaurant',
                    'About your food'),
              ]),
            ),
            if (_order.riderId != null) ...[
              const SizedBox(height: 10),
              ChatButton.wide(
                key: const Key('tracking-chat-rider'),
                title: 'Chat with your rider',
                withWhom: _order.riderName ?? 'Your rider',
                onPressed: () => openOrderChat(context, _order.id, [
                  ChatContact('rider', _order.riderName ?? 'Your rider',
                      'About your delivery'),
                ]),
              ),
            ],
          ],
          const SizedBox(height: 28),

          // ── Status steps ──────────────────────────────────
          Text('Order status',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ..._steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final done = _stepDone(i);
            final active = _stepActive(i);
            final note = _stepNote(i);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppTheme.success
                            : active
                                ? AppTheme.accent
                                : AppColors.surface(context),
                        border: Border.all(
                          color: done
                              ? AppTheme.success
                              : active
                                  ? AppTheme.accent
                                  : AppColors.border(context),
                        ),
                      ),
                      child: active
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2),
                            )
                          : Icon(
                              done
                                  ? Icons.check_rounded
                                  : step['icon'] as IconData,
                              size: 18,
                              color: done
                                  ? Colors.white
                                  : AppColors.textHint(context),
                            ),
                    ),
                    if (i < _steps.length - 1)
                      Container(
                        width: 2,
                        height: 36,
                        color:
                            done ? AppTheme.success : AppColors.border(context),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['label'] as String,
                          style: TextStyle(
                            color: active
                                ? AppTheme.accent
                                : done
                                    ? AppColors.textPrimary(context)
                                    : AppColors.textHint(context),
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        if (note != null)
                          Text(note,
                              style: TextStyle(
                                  color: AppColors.textHint(context),
                                  fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          if (_order.status == 'awaiting_payment') ...[
            PrimaryButton(
              key: const Key('tracking-pay-now'),
              label: 'Pay now',
              icon: Icons.payments_outlined,
              isLoading: _busy,
              onPressed: _busy ? null : _payNow,
            ),
            const SizedBox(height: 12),
          ],
          if (_order.isCancellableByCustomer) ...[
            GhostButton(
              key: const Key('tracking-cancel-order'),
              label: 'Cancel order',
              onPressed: _busy ? null : _cancelOrder,
            ),
            const SizedBox(height: 24),
          ],
          if (_order.isCompleted && !_order.isRated) ...[
            PrimaryButton(
              key: const Key('tracking-rate-order'),
              label: 'Rate order',
              icon: Icons.star_rounded,
              onPressed: () async {
                if (await showRateOrderSheet(context, _order) && mounted) {
                  setState(() => _order = _order.copyWith(isRated: true));
                }
              },
            ),
            const SizedBox(height: 24),
          ],


          // ── Order summary ─────────────────────────────────
          Divider(color: AppColors.border(context)),
          const SizedBox(height: 16),
          Text('Order summary',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _infoRow('Order ID', '#${_order.id}'),
          _infoRow('Total', _order.displayTotal),
          _infoRow('Status', _statusLabel(_order.status)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: AppColors.textSecondary(context))),
          Text(value,
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
