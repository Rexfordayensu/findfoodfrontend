import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/order_payment.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../models/models.dart';
import '../../widgets/account_settings.dart';
import '../../widgets/rating_sheet.dart';
import '../../widgets/widgets.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  bool _loading = true;
  String? _error;
  List<Order> _orders = [];
  int? _busyOrderId;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;
    try {
      final orders = await ApiService.getMyOrders(auth.token!);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _message(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
    ));
  }

  Future<void> _pay(Order order) async {
    setState(() => _busyOrderId = order.id);
    try {
      final paid = await OrderPayment.start(context, order);
      if (!mounted) return;
      if (paid) {
        _message('Payment confirmed. Your order is with the restaurant.');
      }
      await _loadOrders();
    } catch (error) {
      if (mounted) _message(error.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _busyOrderId = null);
    }
  }

  Future<void> _cancel(Order order) async {
    final paid = order.status != 'awaiting_payment';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancel order #${order.id}?'),
        content: Text(paid
            ? 'The restaurant has not started it yet. You will be refunded in full.'
            : 'This order has not been paid yet.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep order')),
          TextButton(
              key: const Key('confirm-cancel-order'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel order',
                  style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busyOrderId = order.id);
    try {
      await ApiService.cancelOrder(context.read<AuthProvider>().token!, order.id);
      if (!mounted) return;
      _message(paid ? 'Order cancelled and refunded.' : 'Order cancelled.');
      await _loadOrders();
    } catch (error) {
      if (mounted) _message(error.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _busyOrderId = null);
    }
  }

  Future<void> _rate(Order order) async {
    if (await showRateOrderSheet(context, order) && mounted) {
      await _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!),
                    TextButton(onPressed: _loadOrders, child: const Text('Retry')),
                  ]),
                )
              : _orders.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      subtitle: 'Your orders will appear here.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _orderCard(_orders[index]),
                      ),
                    ),
    );
  }

  Widget _orderCard(Order order) {
    final busy = _busyOrderId == order.id;
    final placed = order.createdAt;
    final actions = <Widget>[
      if (order.status == 'awaiting_payment')
        ElevatedButton(
          key: Key('pay-order-${order.id}'),
          onPressed: busy ? null : () => _pay(order),
          child: const Text('Pay now'),
        ),
      if (order.isCancellableByCustomer)
        OutlinedButton(
          key: Key('cancel-order-${order.id}'),
          onPressed: busy ? null : () => _cancel(order),
          child: const Text('Cancel'),
        ),
      if (order.isCompleted && !order.isRated)
        ElevatedButton(
          key: Key('rate-order-${order.id}'),
          onPressed: busy ? null : () => _rate(order),
          child: const Text('Rate order'),
        ),
    ];
    return InkWell(
      key: Key('order-card-${order.id}'),
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/order-tracking/${order.id}', extra: order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.restaurantName ?? 'Order #${order.id}',
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                'Order #${order.id}',
                order.displayTotal,
                order.fulfillmentMethod == 'pickup' ? 'Pickup' : 'Delivery',
                if (placed != null)
                  '${placed.day}/${placed.month}/${placed.year}',
              ].join(' · '),
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
            ),
            if (order.isRated)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('★ Rated — thank you!',
                    style: TextStyle(color: AppColors.accentText(context), fontSize: 12)),
              ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (busy)
                const LinearProgressIndicator(color: AppTheme.accent)
              else
                Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AccountHeader(subtitle: 'Customer'),
          const SizedBox(height: 24),
          SettingsGroup(title: 'ORDERS', children: [
            SettingsTile(
              key: const Key('settings-my-orders'),
              icon: Icons.receipt_long_outlined,
              title: 'My orders',
              subtitle: 'Track, pay, cancel or rate',
              onTap: () => context.push('/orders'),
            ),
          ]),
          const SizedBox(height: 20),
          const AccountSettingsSection(role: 'customer'),
          const SizedBox(height: 24),
          const SignOutButton(),
        ],
      ),
    );
  }
}
