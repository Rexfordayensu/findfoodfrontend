import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/order_payment.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../models/models.dart';
import '../../widgets/account_settings.dart';
import '../../widgets/chat_button.dart';
import '../../widgets/customer_nav_bar.dart';
import '../../widgets/rating_sheet.dart';
import '../../widgets/widgets.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/error_view.dart';

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
        _error = friendlyMessage(error);
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
      if (mounted) _message(friendlyMessage(error), isError: true);
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
      if (mounted) _message(friendlyMessage(error), isError: true);
    } finally {
      if (mounted) setState(() => _busyOrderId = null);
    }
  }

  Future<void> _rate(Order order) async {
    if (await showRateOrderSheet(context, order) && mounted) {
      await _loadOrders();
    }
  }

  /// Puts the dishes from a past order back in the cart.
  Future<void> _reorder(Order order) async {
    final available = order.items
        .where((line) => line.isAvailable && line.price != null && line.name != null)
        .toList();
    if (available.isEmpty) {
      _message('These dishes are no longer available.', isError: true);
      return;
    }
    final cart = context.read<CartProvider>();
    if (!cart.isEmpty && cart.restaurantId != order.restaurantId) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Start a new cart?'),
          content: Text(
              'Your cart has items from ${cart.restaurantName ?? 'another restaurant'}. '
              'Reordering will replace them.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep cart')),
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Replace')),
          ],
        ),
      );
      if (replace != true || !mounted) return;
      cart.clearCart();
    }
    for (final line in available) {
      final item = MenuItem(
        id: line.menuItemId,
        name: line.name!,
        price: line.price!,
        isAvailable: true,
        restaurantId: order.restaurantId,
        imageUrl: line.imageUrl,
      );
      for (var i = 0; i < line.quantity; i++) {
        cart.addItem(item, order.restaurantId,
            order.restaurantName ?? 'Restaurant');
      }
    }
    if (available.length < order.items.length) {
      _message('Some dishes are no longer available and were left out.');
    }
    context.push('/cart');
  }

  void _onNavTap(int slot) {
    switch (slot) {
      case 0:
        context.go('/');
      case 1:
        context.go('/search');
      case 3:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card(context),
      bottomNavigationBar: CustomerNavBar(
        currentIndex: 2,
        onTap: _onNavTap,
        onCartTap: () => context.push('/cart'),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadOrders,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header()),
              ..._content(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: context.canPop()
                ? IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: () => context.pop(),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text('My orders',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                )),
          ),
        ],
      ),
    );
  }

  List<Widget> _content() {
    if (_loading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(error: _error!, onRetry: _loadOrders),
        ),
      ];
    }
    if (_orders.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            subtitle: 'Your orders will appear here.',
          ),
        ),
      ];
    }
    final active = _orders.where((o) => o.isActive).toList();
    final past = _orders.where((o) => !o.isActive).toList();
    return [
      if (active.isNotEmpty) ...[
        _sectionLabel('In progress'),
        _orderList(active),
      ],
      if (past.isNotEmpty) ...[
        if (active.isNotEmpty) _sectionLabel('Previous orders'),
        _orderList(past),
      ],
    ];
  }

  Widget _sectionLabel(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 2),
        child: Text(text,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  Widget _orderList(List<Order> orders) {
    return SliverList.separated(
      itemCount: orders.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(height: 1, color: AppColors.border(context)),
      ),
      itemBuilder: (_, index) => _OrderRow(
        order: orders[index],
        busy: _busyOrderId == orders[index].id,
        onOpen: () => context.push('/order-tracking/${orders[index].id}',
            extra: orders[index]),
        onReorder: () => _reorder(orders[index]),
        onPay: () => _pay(orders[index]),
        onCancel: () => _cancel(orders[index]),
        onRate: () => _rate(orders[index]),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Order order;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onReorder;
  final VoidCallback onPay;
  final VoidCallback onCancel;
  final VoidCallback onRate;

  const _OrderRow({
    required this.order,
    required this.busy,
    required this.onOpen,
    required this.onReorder,
    required this.onPay,
    required this.onCancel,
    required this.onRate,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)} ${_months[d.month - 1]}, ${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  static String _statusLabel(String status) => switch (status) {
        'awaiting_payment' => 'Awaiting payment',
        'pending' => 'Waiting for the restaurant',
        'preparing' => 'Being prepared',
        'ready' => 'Ready',
        'out_for_delivery' => 'On the way',
        'delivered' => 'Delivered',
        'picked_up' => 'Picked up',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final placed = order.createdAt;
    final statusColor = order.isCancelled
        ? AppTheme.danger
        : order.isActive
            ? AppColors.accentText(context)
            : textPri;

    final actions = <Widget>[
      if (order.status == 'awaiting_payment')
        _SmallButton(
          key: Key('pay-order-${order.id}'),
          label: 'Pay now',
          filled: true,
          onPressed: busy ? null : onPay,
        ),
      if (order.isCancellableByCustomer)
        _SmallButton(
          key: Key('cancel-order-${order.id}'),
          label: 'Cancel',
          onPressed: busy ? null : onCancel,
        ),
      if (order.isCompleted && !order.isRated)
        _SmallButton(
          key: Key('rate-order-${order.id}'),
          label: 'Rate order',
          icon: Icons.star_outline_rounded,
          onPressed: busy ? null : onRate,
        ),
    ];

    return InkWell(
      key: Key('order-card-${order.id}'),
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _OrderThumbnail(order: order),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName ?? 'Order #${order.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: textPri,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(formatCedis(order.amountToPay),
                          style: TextStyle(color: textPri, fontSize: 15)),
                    ],
                  ),
                ),
                if (!order.isActive && order.items.isNotEmpty)
                  Tooltip(
                    message: 'Order again',
                    child: Material(
                      color: _softFill(context),
                      shape: const CircleBorder(),
                      child: InkWell(
                        key: Key('reorder-${order.id}'),
                        customBorder: const CircleBorder(),
                        onTap: onReorder,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.replay_rounded, color: textPri, size: 22),
                        ),
                      ),
                    ),
                  )
                else if (order.isActive)
                  Icon(Icons.chevron_right_rounded, color: textSec),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(children: [
                if (placed != null) TextSpan(text: '${_date(placed)} · '),
                TextSpan(
                  text: _statusLabel(order.status),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                ),
                if (order.isRated)
                  const TextSpan(text: ' · You rated this'),
                if (order.issueStatus == 'open')
                  const TextSpan(
                      text: ' · Problem reported',
                      style: TextStyle(
                          color: AppTheme.accentDeep, fontWeight: FontWeight.w600)),
                if (order.issueStatus == 'refunded')
                  const TextSpan(
                      text: ' · Refunded',
                      style: TextStyle(
                          color: AppTheme.success, fontWeight: FontWeight.w600)),
              ]),
              style: TextStyle(color: textSec, fontSize: 13),
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

Color _softFill(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0x14FFFFFF)
        : const Color(0xFFF1F2F5);

class _OrderThumbnail extends StatelessWidget {
  final Order order;
  const _OrderThumbnail({required this.order});

  @override
  Widget build(BuildContext context) {
    final url = order.thumbnailUrl;
    final extra = order.items.length - 1;
    final fallback = Container(
      color: _softFill(context),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded,
          color: AppColors.textHint(context), size: 26),
    );
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: url == null
                  ? fallback
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => fallback,
                      frameBuilder: (_, child, frame, sync) => sync || frame != null
                          ? child
                          : fallback,
                    ),
            ),
          ),
          if (extra > 0)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('+$extra',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onPressed;

  const _SmallButton({
    super.key,
    required this.label,
    this.icon,
    this.filled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      visualDensity: VisualDensity.compact,
      minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
      shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
    );
    final child = icon == null
        ? Text(label)
        : Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ]);
    return filled
        ? ElevatedButton(style: style, onPressed: onPressed, child: child)
        : OutlinedButton(
            style: style.copyWith(
              foregroundColor:
                  WidgetStatePropertyAll(AppColors.textPrimary(context)),
              side: WidgetStatePropertyAll(
                  BorderSide(color: AppColors.border(context))),
            ),
            onPressed: onPressed,
            child: child,
          );
  }
}

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  void _onNavTap(BuildContext context, int slot) {
    switch (slot) {
      case 0:
        context.go('/');
      case 1:
        context.go('/search');
      case 2:
        context.go('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomerNavBar(
        currentIndex: 3,
        onTap: (slot) => _onNavTap(context, slot),
        onCartTap: () => context.push('/cart'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(children: [
              if (context.canPop())
                IconButton(
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => context.pop(),
                ),
              Text('Profile',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  )),
            ]),
            const SizedBox(height: 16),
            const _ProfileCard(),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _QuickAction(
                  key: const Key('settings-my-orders'),
                  icon: Icons.receipt_long_outlined,
                  label: 'My orders',
                  onTap: () => context.go('/orders'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.support_agent_rounded,
                  label: 'Get help',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(role: 'customer'))),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            const _CreditCard(),
            const AccountSettingsSection(role: 'customer'),
            const SizedBox(height: 24),
            const _SignOutTile(),
          ],
        ),
      ),
    );
  }
}

/// Avatar, name and email with an Edit shortcut.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = (auth.name?.trim().isNotEmpty ?? false) ? auth.name!.trim() : 'Your account';
    final email = auth.email ?? '';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: AppTheme.brandGradient,
            shape: BoxShape.circle,
          ),
          child: Text(name[0].toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  key: const Key('account-header-name'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(email,
                    key: const Key('account-header-email'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 13.5)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        ActionPill(
          key: const Key('profile-edit'),
          icon: Icons.edit_outlined,
          label: 'Edit',
          semanticLabel: 'Edit your name',
          onPressed: () => showEditProfileSheet(context),
        ),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(children: [
            Icon(icon, color: AppColors.accentText(context), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Sign out, clearly marked as leaving the account.
class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.danger.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('settings-sign-out'),
        onTap: () async {
          if (!await confirmLogout(context) || !context.mounted) return;
          await context.read<AuthProvider>().logout();
          if (!context.mounted) return;
          showLogoutSuccess(context);
          context.go('/');
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.danger, size: 20),
              SizedBox(width: 8),
              Text('Sign out',
                  style: TextStyle(
                      color: AppTheme.danger,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}


/// FindFood credit, when the customer has some or has had some.
class _CreditCard extends StatefulWidget {
  const _CreditCard();

  @override
  State<_CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<_CreditCard> {
  Map<String, dynamic>? _credit;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      ApiService.getMyCredit(token).then((data) {
        if (mounted) setState(() => _credit = data);
      }).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final credit = _credit;
    final entries = (credit?['entries'] as List? ?? const []);
    if (credit == null || entries.isEmpty) return const SizedBox.shrink();
    final balance = (credit['balance'] as num?)?.toInt() ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        key: const Key('profile-credit'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FindFood credit',
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
              Text(formatCedis(balance),
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text('Used automatically at checkout',
                  style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}
