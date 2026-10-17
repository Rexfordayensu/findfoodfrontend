import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/share_restaurant.dart';
import '../../widgets/rider_map.dart';
import '../../widgets/glass.dart';
import '../../widgets/handoff_code.dart';
import '../../utils/time_format.dart';
import '../../widgets/chat_button.dart';
import '../../widgets/widgets.dart';
import '../../widgets/account_settings.dart';
import '../../widgets/promotion_card.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/doorstep.dart';
import '../../widgets/assign_rider.dart';
import '../../widgets/payouts.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/rider_pay.dart' show ShopLocationTile;

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard(
      {super.key, required this.token, this.initialIndex = 0});

  final String token;
  final int initialIndex;
  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  late int _selectedIndex;

  // ── Approval gate state ────────────────────────────────────────────────
  bool _checking = true;
  bool _isApproved = false;
  String _restaurantName = '';
  String? _restaurantBannerUrl;
  int _restaurantId = 0;
  Restaurant? _restaurant;
  String _checkError = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkApproval();
    _loadReportsWaiting();
  }

  /// Reports waiting for this restaurant's answer: the Reports tab's badge.
  int _reportsWaiting = 0;
  // Opening the Reports tab again reloads it.
  int _reportsVisit = 0;

  Future<void> _loadReportsWaiting() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final open = await ApiService.getRestaurantIssues(token);
      final waiting = open.where((r) => r['restaurant_response'] == null).length;
      if (mounted && waiting != _reportsWaiting) setState(() => _reportsWaiting = waiting);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(RestaurantDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
      if (_selectedIndex == 3) _reportsVisit++;
      _loadReportsWaiting();
    }
  }

  Future<void> _checkApproval() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() {
      _checking = true;
      _checkError = '';
    });
    try {
      final restaurant = await ApiService.getMyRestaurant(auth.token!);
      if (!mounted) return;
      _applyRestaurant(restaurant);
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkError = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _applyRestaurant(Restaurant restaurant) {
    setState(() {
      _restaurant = restaurant;
      _isApproved = restaurant.isApproved;
      _restaurantName = restaurant.name;
      _restaurantBannerUrl = restaurant.bannerUrl;
      _restaurantId = restaurant.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── Still checking approval status — show a loading screen ──────────
    if (_checking) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    // ── Failed to check status (e.g. no network) ─────────────────────────
    if (_checkError.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 48, color: AppColors.textHint(context)),
                const SizedBox(height: 16),
                Text('Couldn\'t verify your account',
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(_checkError,
                    style: TextStyle(color: AppColors.textSecondary(context)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _checkApproval, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    // ── Restaurant exists but hasn't been approved by admin yet ──────────
    if (!_isApproved) {
      return _PendingApprovalScreen(
        restaurantName: _restaurantName,
        onRefresh: _checkApproval,
      );
    }

    // ── Approved! Show the real dashboard ────────────────────────────────
    final pages = [
      const _OrdersPage(),
      const _MenuManagerPage(),
      const _EarningsPage(),
      RestaurantReportsPage(
        key: ValueKey('reports-$_reportsVisit'),
        onWaitingChanged: (n) {
          if (n != _reportsWaiting) setState(() => _reportsWaiting = n);
        },
      ),
      _SettingsPage(
        restaurantId: _restaurantId,
        bannerUrl: _restaurantBannerUrl,
        restaurant: _restaurant,
        onRestaurantChanged: _applyRestaurant,
      )
    ];

    return Scaffold(
      extendBody: true,
      body: GlassBody(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => context.go(
            '/restaurant/${['orders', 'menu', 'earnings', 'reports', 'settings'][i]}'),
        items: [
          const GlassNavItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'Orders'),
          const GlassNavItem(
              icon: Icons.menu_book_outlined,
              activeIcon: Icons.menu_book_rounded,
              label: 'Menu'),
          const GlassNavItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart_rounded,
              label: 'Earnings'),
          GlassNavItem(
              icon: Icons.report_gmailerrorred_outlined,
              activeIcon: Icons.report_gmailerrorred_rounded,
              label: 'Reports',
              badge: _reportsWaiting),
          const GlassNavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: 'Settings'),
        ],
      ),
    );
  }
}

// ─── PENDING APPROVAL SCREEN ──────────────────────────────────────────────────
// Shown to restaurant owners whose account has been created but not yet
// approved by an admin. Blocks all dashboard access until approved.
class _PendingApprovalScreen extends StatelessWidget {
  final String restaurantName;
  final VoidCallback onRefresh;

  const _PendingApprovalScreen({
    required this.restaurantName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: AppTheme.warning, size: 44),
              ),
              const SizedBox(height: 28),
              Text('Application under review',
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                restaurantName.isNotEmpty
                    ? '$restaurantName is waiting for admin approval.'
                    : 'Your restaurant is waiting for admin approval.',
                style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 15,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'You\'ll get full access to your dashboard — orders, menu, '
                'and earnings — as soon as an admin approves your application.',
                style: TextStyle(
                    color: AppColors.textHint(context),
                    fontSize: 13,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.black, size: 18),
                  label: const Text('Check approval status'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  if (!await confirmLogout(context) || !context.mounted) return;
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  if (!context.mounted) return;
                  showLogoutSuccess(context);
                  context.go('/');
                },
                child: Text('Sign out',
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ORDERS PAGE WITH REAL-TIME POLLING ──────────────────────────────────────
class _OrdersPage extends StatefulWidget {
  const _OrdersPage();
  @override
  State<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<_OrdersPage> {
  List<Order> _orders = [];
  int _issuesTick = 0;
  bool _loading = true;
  String _error = '';
  String _filter = 'all';
  Timer? _pollTimer;

  final _filters = [
    'all',
    'pending',
    'preparing',
    'ready',
    'delivered',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _load();
    // Poll every 8 seconds for new orders
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final orders = await ApiService.getMyOrders(auth.token!);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _issuesTick++;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _poll() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    try {
      final orders = await ApiService.getMyOrders(auth.token!);
      final prevCount = _orders.where((o) => o.status == 'pending').length;
      final newCount = orders.where((o) => o.status == 'pending').length;
      if (!mounted) return;
      setState(() => _orders = orders);
      // Notify if new pending orders arrived
      if (newCount > prevCount && mounted) {
        _showNewOrderBanner(newCount - prevCount);
      }
    } catch (_) {}
  }

  void _showNewOrderBanner(int count) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.accent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
      content: Row(children: [
        const Icon(Icons.notifications_active_rounded,
            color: Colors.black, size: 20),
        const SizedBox(width: 10),
        Text(
          '$count new order${count > 1 ? 's' : ''} received!',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ]),
    ));
  }

  Future<void> _updateStatus(Order order, String newStatus) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool? sealed;
    if (newStatus == 'ready') {
      // Photo of the packed food and the seal: proof of what left the kitchen.
      sealed = await showPackSheet(context, order);
      if (sealed == null || !mounted) return;
    }
    try {
      final updated = await ApiService.updateOrderStatus(
        auth.token!,
        order.id,
        newStatus,
        sealed: sealed,
      );
      if (!mounted) return;
      setState(() {
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx != -1) _orders[idx] = updated;
      });
      final message = newStatus == 'cancelled'
          ? 'Order #${order.id} rejected. The customer has been refunded.'
          : 'Order #${order.id} → ${newStatus.replaceAll('_', ' ')} ✓';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e),
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  /// Hands the food over after checking the receiver's code: the rider's
  /// pickup code, or the customer's code for pickup orders.
  Future<void> _handOver(Order order) async {
    final token = context.read<AuthProvider>().token!;
    final toRider = order.fulfillmentMethod != 'pickup';
    final done = await showHandoffCodeEntry(
      context,
      title: toRider
          ? "Enter ${order.riderName ?? 'the rider'}'s code"
          : "Enter the customer's code",
      instructions: toRider
          ? 'Check the bag against this list, then enter the pickup code from '
              "the rider's app. Only hand over the bag once the code is accepted."
          : 'Check the bag against this list, then enter the code from the '
              "customer's app. Only hand over the bag once the code is accepted.",
      details: PackingList(order: order),
      actionLabel: toRider ? 'Hand over to rider' : 'Hand over to customer',
      submit: (code) async {
        final updated = await ApiService.handOverOrder(token, order.id, code);
        if (!mounted) return;
        setState(() {
          final idx = _orders.indexWhere((o) => o.id == order.id);
          if (idx != -1) _orders[idx] = updated;
        });
      },
    );
    if (done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.success,
        content: Text(
            toRider
                ? 'Order #${order.id} is on its way with the rider.'
                : 'Order #${order.id} collected by the customer.',
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  int get _ordersToday {
    final now = DateTime.now();
    return _orders.where((o) {
      final placed = o.createdAt;
      return placed != null &&
          placed.year == now.year &&
          placed.month == now.month &&
          placed.day == now.day;
    }).length;
  }

  List<Order> get _filtered => _filter == 'all'
      ? _orders
      : _orders
          .where((o) =>
              o.status == _filter ||
              // Collected pickup orders are completed just like deliveries.
              (_filter == 'delivered' && o.status == 'picked_up'))
          .toList();

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(context);
    final textPri = AppColors.textPrimary(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Builder(builder: (context) {
              final waiting = _orders.where((o) => o.status == 'pending').length;
              return GreetingHeader(
                name: context.watch<AuthProvider>().name ?? '',
                role: 'restaurant',
                status: waiting == 0
                    ? null
                    : '$waiting new order${waiting == 1 ? ' is' : 's are'} waiting for you.',
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              );
            }),
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live orders',
                            style: TextStyle(
                                color: textPri,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4)),
                        Text('Auto-refreshes every 8 seconds',
                            style: TextStyle(
                                color: AppColors.textHint(context),
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  // Live indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      _PulseDot(),
                      const SizedBox(width: 6),
                      const Text('Live',
                          style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  // Share the restaurant (e.g. on WhatsApp Status)
                  Tooltip(
                    message: 'Share your restaurant',
                    child: GestureDetector(
                      key: const Key('orders-share'),
                      onTap: () => showRestaurantShareSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.brandGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.ios_share_rounded, color: Colors.black, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Refresh button
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child:
                          Icon(Icons.refresh_rounded, color: textPri, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const NotificationBell(size: 36),
                ],
              ),
            ),

            // ── Stats strip ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                Expanded(
                    child: _StatChip(
                        'Pending',
                        '${_orders.where((o) => o.status == 'pending').length}',
                        AppTheme.accent)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatChip(
                        'Preparing',
                        '${_orders.where((o) => o.status == 'preparing').length}',
                        AppTheme.warning)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatChip(
                        'Ready',
                        '${_orders.where((o) => o.status == 'ready').length}',
                        AppTheme.success)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatChip('Today', '$_ordersToday',
                        AppColors.textSecondary(context))),
              ]),
            ),

            // ── Filter chips ────────────────────────────────
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final active = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.accent
                            : AppColors.surface(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active
                                ? AppTheme.accent
                                : AppColors.border(context)),
                      ),
                      child: Text(
                        f[0].toUpperCase() + f.substring(1),
                        style: TextStyle(
                          color: active
                              ? Colors.black
                              : AppColors.textSecondary(context),
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            RestaurantIssuesBanner(refreshTick: _issuesTick),
            const PayoutReminderBanner(),

            // ── Orders list ─────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent))
                  : _error.isNotEmpty
                      ? EmptyState(
                          icon: Icons.wifi_off_rounded,
                          title: 'Failed to load',
                          subtitle: _error,
                          actionLabel: 'Retry',
                          onAction: _load,
                        )
                      : _filtered.isEmpty
                          ? EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: _filter == 'all'
                                  ? 'No orders yet'
                                  : 'No $_filter orders',
                              subtitle: _filter == 'all'
                                  ? 'New orders appear here automatically'
                                  : 'Switch filters to see other orders',
                            )
                          : RefreshIndicator(
                              color: AppTheme.accent,
                              onRefresh: _load,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 100),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) => _OrderCard(
                                  order: _filtered[i],
                                  onUpdateStatus: _updateStatus,
                                  onHandOver: _handOver,
                                  onRiderChanged: _load,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ORDER CARD ───────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  final Future<void> Function(Order, String) onUpdateStatus;
  final Future<void> Function(Order) onHandOver;
  final Future<void> Function() onRiderChanged;

  const _OrderCard({
    required this.order,
    required this.onUpdateStatus,
    required this.onHandOver,
    required this.onRiderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == 'pending';
    final isPreparing = order.status == 'preparing';
    final isReady = order.status == 'ready';
    final isPickup = order.fulfillmentMethod == 'pickup';
    final isDone = order.status == 'delivered' || order.status == 'picked_up';
    final isCancelled = order.status == 'cancelled';
    final onTheWay = order.status == 'out_for_delivery';
    final hasRider = order.riderId != null;

    String? actionLabel;
    IconData? actionIcon;
    String? nextStatus;
    Color? actionColor;
    var handOver = false;

    if (isPending) {
      actionLabel = 'Start preparing';
      actionIcon = Icons.soup_kitchen_rounded;
      nextStatus = 'preparing';
      actionColor = AppTheme.warning;
    } else if (isPreparing) {
      actionLabel = 'Mark ready for pickup';
      actionIcon = Icons.check_circle_rounded;
      nextStatus = 'ready';
      actionColor = AppTheme.success;
    } else if (isReady && (isPickup || hasRider)) {
      actionLabel = isPickup ? 'Hand over to customer' : 'Hand over to rider';
      actionIcon = Icons.pin_outlined;
      handOver = true;
      actionColor = AppTheme.success;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppTheme.accent.withValues(alpha: 0.5)
              : AppColors.border(context),
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: isPending
            ? [
                BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Column(
        children: [
          // ── Card header ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        if (isPending)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                                color: AppTheme.accent, shape: BoxShape.circle),
                          ),
                        Flexible(
                          child: Text('Order #${order.id}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Row(children: [
                      if (!isCancelled) ...[
                        ChatButton(
                          key: Key('restaurant-chat-${order.id}'),
                          withWhom: hasRider
                              ? 'the customer or ${order.riderName ?? 'the rider'}'
                              : 'the customer',
                          onPressed: () => openOrderChat(context, order.id, [
                            const ChatContact('customer', 'Customer',
                                'Questions about the order'),
                            if (hasRider)
                              ChatContact('rider', order.riderName ?? 'Rider',
                                  'Your rider for this order'),
                          ]),
                        ),
                        const SizedBox(width: 8),
                      ],
                      StatusBadge(status: order.status),
                    ]),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.displayTotal,
                        style: TextStyle(color: AppColors.accentText(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Row(children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.textHint(context)),
                      const SizedBox(width: 4),
                      Text(
                          order.createdAt == null
                              ? ''
                              : relativeTime(order.createdAt!, DateTime.now()),
                          style: TextStyle(
                              color: AppColors.textHint(context),
                              fontSize: 12)),
                    ]),
                  ],
                ),
                if (!isDone && !isCancelled && order.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  PackingList(order: order),
                ],
                if (hasRider && !isDone && !isCancelled) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.electric_bike_outlined,
                        size: 15, color: AppColors.textSecondary(context)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                          'Rider: ${order.riderName ?? 'assigned'}'
                          '${order.riderAssignedVia == 'restaurant' ? ' · chosen by you' : ''}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    if (order.riderPhone != null) ...[
                      const SizedBox(width: 8),
                      CallButton(phone: order.riderPhone!, who: order.riderName ?? 'the rider'),
                    ],
                    if (!isPickup) ...[
                      const SizedBox(width: 8),
                      ActionPill(
                        key: Key('track-rider-${order.id}'),
                        icon: Icons.map_outlined,
                        label: 'Track',
                        semanticLabel: 'See ${order.riderName ?? 'the rider'} on the map',
                        onPressed: () => openRiderMap(context, order.id, MapViewer.restaurant),
                      ),
                    ],
                  ]),
                ],
                // A delivery still without a rider: choose one, or see who
                // was asked.
                if (!isPickup && !hasRider && (isPending || isPreparing || isReady)) ...[
                  const SizedBox(height: 10),
                  RiderAssignmentRow(order: order, onChanged: onRiderChanged),
                ],
              ],
            ),
          ),

          // ── Action row ────────────────────────────────────
          if (actionLabel != null) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                // Reject / cancel (only for pending)
                if (isPending) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _confirmReject(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.danger.withValues(alpha: 0.3)),
                        ),
                        child: const Center(
                          child: Text('Reject',
                              style: TextStyle(
                                  color: AppTheme.danger,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                // Main action
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    key: Key('order-action-${order.id}'),
                    onTap: () => handOver
                        ? onHandOver(order)
                        : onUpdateStatus(order, nextStatus!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: actionColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: actionColor!.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (actionIcon != null) ...[
                            Icon(actionIcon, color: Colors.black, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(actionLabel,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ] else if (isReady) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delivery_dining_rounded,
                        color: AppTheme.success, size: 16),
                    const SizedBox(width: 8),
                    Text(order.offeredRiderName != null
                        ? 'Waiting for ${order.offeredRiderName} to accept'
                        : 'Waiting for a rider to accept',
                        style: const TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ] else if (onTheWay) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Icon(Icons.delivery_dining_rounded,
                    color: AppColors.textSecondary(context), size: 16),
                const SizedBox(width: 8),
                Text('On the way with ${order.riderName ?? 'the rider'}',
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 12)),
              ]),
            ),
          ] else if (isCancelled) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                const Icon(Icons.cancel_outlined,
                    color: AppTheme.danger, size: 16),
                const SizedBox(width: 8),
                Text('Cancelled · customer refunded',
                    style: TextStyle(
                        color: AppColors.textHint(context), fontSize: 12)),
              ]),
            ),
          ] else if (isDone) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 16),
                const SizedBox(width: 8),
                Text(
                    order.status == 'picked_up'
                        ? 'Collected by customer'
                        : 'Delivered successfully',
                    style: TextStyle(
                        color: AppColors.textHint(context), fontSize: 12)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject order #${order.id}?',
            style: TextStyle(
                color: AppColors.textPrimary(dialogContext),
                fontWeight: FontWeight.w700)),
        content: Text(
          'This cancels the order and refunds the customer.',
          style: TextStyle(color: AppColors.textSecondary(dialogContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Keep it',
                style: TextStyle(color: AppColors.textHint(dialogContext))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onUpdateStatus(order, 'cancelled');
            },
            child: const Text('Reject',
                style: TextStyle(
                    color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── PULSE DOT (live indicator) ───────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── STAT CHIP ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textHint(context), fontSize: 10)),
      ]),
    );
  }
}

// ─── MENU MANAGER PAGE ────────────────────────────────────────────────────────
class _MenuManagerPage extends StatefulWidget {
  const _MenuManagerPage();
  @override
  State<_MenuManagerPage> createState() => _MenuManagerPageState();
}

class _MenuManagerPageState extends State<_MenuManagerPage> {
  List<MenuItem> _items = [];
  bool _loading = true;
  String _error = '';
  int? _restaurantId; // Fetched dynamically — no more hardcoding!
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      // Step 1: resolve the logged-in owner's actual restaurant
      final restaurant = await ApiService.getMyRestaurant(auth.token!);
      _restaurantId = restaurant.id;

      // Load unavailable items too so the owner can turn them back on.
      final items = await ApiService.getManagedMenu(
        token: auth.token!,
        restaurantId: _restaurantId!,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── ADD ───────────────────────────────────────────────────────────────────
  void _showAddSheet() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    bool saving = false;
    Uint8List? pickedBytes;
    String? pickedFilename;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(ctx),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add menu item',
                  style: TextStyle(
                      color: AppColors.textPrimary(ctx),
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // ── Photo picker ──────────────────────────────
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                    maxWidth: 1600,
                    maxHeight: 1200,
                  );
                  if (picked == null) return;
                  final bytes = await picked.readAsBytes();
                  if (!ctx.mounted) return;
                  if (bytes.length > 5 * 1024 * 1024) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Menu images must be 5 MB or smaller.'),
                    ));
                    return;
                  }
                  set(() {
                    pickedBytes = bytes;
                    pickedFilename = picked.name;
                  });
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface(ctx),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.border(ctx), style: BorderStyle.solid),
                  ),
                  child: pickedBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(pickedBytes!,
                              fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: AppColors.textHint(ctx), size: 32),
                            const SizedBox(height: 8),
                            Text('Tap to add a food photo',
                                style: TextStyle(
                                    color: AppColors.textHint(ctx),
                                    fontSize: 13)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                  controller: nameCtrl,
                  hint: 'Item name',
                  prefixIcon: Icons.fastfood_outlined),
              const SizedBox(height: 12),
              AppTextField(
                  controller: descCtrl,
                  hint: 'Description (optional)',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 2),
              const SizedBox(height: 12),
              AppTextField(
                  controller: priceCtrl,
                  hint: 'Price in pesewas (e.g. 4500 = GH₵ 45)',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Add to menu',
                isLoading: saving,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty ||
                      priceCtrl.text.trim().isEmpty) {
                    return;
                  }
                  set(() => saving = true);
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  final navigator = Navigator.of(context);
                  try {
                    // 1. Create the menu item first
                    var item = await ApiService.addMenuItem(
                      token: auth.token!,
                      restaurantId: _restaurantId!,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      price: int.parse(priceCtrl.text.trim()),
                    );

                    // 2. If a photo was picked, upload it now that we have the item ID
                    if (pickedBytes != null) {
                      item = await ApiService.uploadMenuItemImage(
                        token: auth.token!,
                        restaurantId: _restaurantId!,
                        itemId: item.id,
                        imageBytes: pickedBytes!,
                        filename: pickedFilename ?? 'photo.jpg',
                      );
                    }

                    if (!mounted) return;
                    if (navigator.canPop()) {
                      navigator.pop();
                    }
                    setState(() => _items.insert(0, item));
                    messenger?.showSnackBar(const SnackBar(
                      backgroundColor: AppTheme.success,
                      content: Text('Item added!',
                          style: TextStyle(color: Colors.white)),
                    ));
                  } catch (e) {
                    if (!mounted) return;
                    messenger?.showSnackBar(SnackBar(
                      backgroundColor: AppTheme.danger,
                      content: Text(friendlyMessage(e),
                          style: const TextStyle(color: Colors.white)),
                    ));
                  } finally {
                    if (mounted) set(() => saving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── EDIT ──────────────────────────────────────────────────────────────────
  void _showEditSheet(MenuItem item) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description ?? '');
    final priceCtrl = TextEditingController(text: item.price.toString());
    bool saving = false;
    bool removingImage = false;
    Uint8List? pickedBytes;
    String? pickedFilename;
    String? currentImageUrl = item.imageUrl; // tracks local state after remove

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(ctx),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Edit menu item',
                      style: TextStyle(
                          color: AppColors.textPrimary(ctx),
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      _confirmDelete(item);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.danger, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Photo picker with existing/removed/new preview ──
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                        maxWidth: 1600,
                        maxHeight: 1200,
                      );
                      if (picked == null) return;
                      final bytes = await picked.readAsBytes();
                      if (!ctx.mounted) return;
                      if (bytes.length > 5 * 1024 * 1024) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content: Text('Menu images must be 5 MB or smaller.'),
                        ));
                        return;
                      }
                      set(() {
                        pickedBytes = bytes;
                        pickedFilename = picked.name;
                        removingImage = false;
                      });
                    },
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface(ctx),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border(ctx)),
                      ),
                      child: pickedBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(pickedBytes!,
                                  fit: BoxFit.cover, width: double.infinity),
                            )
                          : (currentImageUrl != null && !removingImage)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    item.fullImageUrl(ApiService.baseUrl) ??
                                        currentImageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(Icons.broken_image_outlined,
                                          color: AppColors.textHint(ctx)),
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined,
                                        color: AppColors.textHint(ctx),
                                        size: 32),
                                    const SizedBox(height: 8),
                                    Text('Tap to add a food photo',
                                        style: TextStyle(
                                            color: AppColors.textHint(ctx),
                                            fontSize: 13)),
                                  ],
                                ),
                    ),
                  ),
                  // Remove button — only shown when there's an image to clear
                  if (pickedBytes != null ||
                      (currentImageUrl != null && !removingImage))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          set(() {
                            pickedBytes = null;
                            pickedFilename = null;
                            removingImage = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                  controller: nameCtrl,
                  hint: 'Item name',
                  prefixIcon: Icons.fastfood_outlined),
              const SizedBox(height: 12),
              AppTextField(
                  controller: descCtrl,
                  hint: 'Description (optional)',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 2),
              const SizedBox(height: 12),
              AppTextField(
                  controller: priceCtrl,
                  hint: 'Price in pesewas',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Save changes',
                isLoading: saving,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty ||
                      priceCtrl.text.trim().isEmpty) {
                    return;
                  }
                  set(() => saving = true);
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  final navigator = Navigator.of(context);
                  try {
                    var updated = await ApiService.updateMenuItem(
                      token: auth.token!,
                      restaurantId: _restaurantId!,
                      itemId: item.id,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      price: int.tryParse(priceCtrl.text.trim()) ?? 0,
                    );

                    // New photo picked → upload it
                    if (pickedBytes != null) {
                      updated = await ApiService.uploadMenuItemImage(
                        token: auth.token!,
                        restaurantId: _restaurantId!,
                        itemId: item.id,
                        imageBytes: pickedBytes!,
                        filename: pickedFilename ?? 'photo.jpg',
                      );
                    }
                    // User explicitly removed the photo, no new one picked
                    else if (removingImage && item.imageUrl != null) {
                      await ApiService.removeMenuItemImage(
                        token: auth.token!,
                        restaurantId: _restaurantId!,
                        itemId: item.id,
                      );
                    }

                    if (!mounted) return;
                    if (navigator.canPop()) {
                      navigator.pop();
                    }
                    setState(() {
                      final idx = _items.indexWhere((m) => m.id == item.id);
                      if (idx != -1) _items[idx] = updated;
                    });
                    messenger?.showSnackBar(const SnackBar(
                      backgroundColor: AppTheme.success,
                      content: Text('Item updated!',
                          style: TextStyle(color: Colors.white)),
                    ));
                  } catch (e) {
                    if (!mounted) return;
                    messenger?.showSnackBar(SnackBar(
                      backgroundColor: AppTheme.danger,
                      content: Text(friendlyMessage(e),
                          style: const TextStyle(color: Colors.white)),
                    ));
                  } finally {
                    if (mounted) set(() => saving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _confirmDelete(MenuItem item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete ${item.name}?',
            style: TextStyle(color: AppColors.textPrimary(ctx))),
        content: Text('This will permanently remove it from your menu.',
            style: TextStyle(color: AppColors.textSecondary(ctx))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processingIds.add(item.id));
    try {
      await ApiService.deleteMenuItem(
        auth.token!,
        item.id,
      );
      if (!mounted) return;
      setState(() => _items.removeWhere((m) => m.id == item.id));
      if (!mounted) return;
      messenger?.showSnackBar(const SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text('Item deleted', style: TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _processingIds.remove(item.id));
    }
  }

  // ── TOGGLE AVAILABILITY ──────────────────────────────────────────────────
  Future<void> _toggleAvailability(MenuItem item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _processingIds.add(item.id));
    try {
      final isAvailable = await ApiService.toggleMenuItem(auth.token!, item.id);
      if (!mounted) return;
      setState(() {
        final idx = _items.indexWhere((m) => m.id == item.id);
        if (idx != -1) {
          _items[idx] = _items[idx].copyWith(isAvailable: isAvailable);
        }
      });
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _processingIds.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menu',
                      style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: _showAddSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(children: [
                        Icon(Icons.add_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text('Add item',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent))
                  : _error.isNotEmpty
                      ? EmptyState(
                          icon: Icons.wifi_off_rounded,
                          title: 'Failed to load',
                          subtitle: _error,
                          actionLabel: 'Retry',
                          onAction: _load)
                      : _items.isEmpty
                          ? EmptyState(
                              icon: Icons.menu_book_outlined,
                              title: 'No items yet',
                              subtitle: 'Add your first dish.',
                              actionLabel: 'Add item',
                              onAction: _showAddSheet)
                          : RefreshIndicator(
                              color: AppTheme.accent,
                              onRefresh: _load,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: _items.length,
                                itemBuilder: (_, i) {
                                  final m = _items[i];
                                  final processing =
                                      _processingIds.contains(m.id);
                                  return _ManagedMenuItemCard(
                                    item: m,
                                    processing: processing,
                                    onEdit: () => _showEditSheet(m),
                                    onToggle: () => _toggleAvailability(m),
                                    onDelete: () => _confirmDelete(m),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MANAGED MENU ITEM CARD (with edit/delete/toggle) ──────────────────────
class _ManagedMenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool processing;
  final VoidCallback onEdit, onToggle, onDelete;

  const _ManagedMenuItemCard({
    required this.item,
    required this.processing,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isAvailable
              ? AppColors.border(context)
              : AppTheme.danger.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // Image — shows uploaded photo, falls back to icon placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.surface(context),
              child: item.imageUrl != null
                  ? Image.network(
                      item.fullImageUrl(ApiService.baseUrl)!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.fastfood_rounded,
                          color: AppColors.textHint(context), size: 24),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: AppTheme.accent, strokeWidth: 2),
                          ),
                        );
                      },
                    )
                  : Icon(Icons.fastfood_rounded,
                      color: AppColors.textHint(context), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(item.description!,
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                const SizedBox(height: 4),
                Text(item.displayPrice,
                    style: TextStyle(color: AppColors.accentText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // Actions column
          Column(
            children: [
              // Availability toggle
              GestureDetector(
                onTap: processing ? null : onToggle,
                child: processing
                    ? const SizedBox(
                        width: 36,
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: AppTheme.accent, strokeWidth: 2),
                          ),
                        ),
                      )
                    : Container(
                        width: 36,
                        height: 20,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? AppTheme.success
                              : AppColors.border(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: item.isAvailable
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit_outlined,
                          color: AppColors.textSecondary(context), size: 15),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: processing ? null : onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.danger, size: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── EARNINGS / ANALYTICS PAGE (live data) ────────────────────────────────────
class _EarningsPage extends StatefulWidget {
  const _EarningsPage();
  @override
  State<_EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<_EarningsPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final data = await ApiService.getRestaurantAnalytics(auth.token!);
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Earnings & Analytics',
                        style: TextStyle(
                            color: textPri,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppTheme.accent),
                      onPressed: _load,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.accent)),
                  )
                else if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 44, color: AppColors.textHint(context)),
                        const SizedBox(height: 10),
                        Text(_error,
                            style: TextStyle(color: textSec),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        ElevatedButton(
                            onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                else ...[
                  // ── Earnings: the restaurant's share, paid and owed ──
                  EarningsSplitCard(
                    data: _data!,
                    onSetUpPayouts: () async {
                      if (await showPayoutSheet(context) != null) await _load();
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Stat row ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _miniStat(
                            context,
                            'Total orders',
                            '${_data?['total_orders'] ?? 0}',
                            Icons.shopping_bag_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniStat(
                            context,
                            'Avg order value',
                            'GH₵ ${((_data?['avg_order_value'] ?? 0) / 100).toStringAsFixed(2)}',
                            Icons.trending_up_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── 7-day revenue bar chart ──────────────────────
                  Text('Last 7 days',
                      style: TextStyle(
                          color: textPri,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _RevenueBarChart(
                    data: (_data?['daily_revenue'] as List<dynamic>?)
                            ?.cast<Map<String, dynamic>>() ??
                        [],
                  ),
                  const SizedBox(height: 24),

                  // ── Top items ─────────────────────────────────
                  Text('Best sellers',
                      style: TextStyle(
                          color: textPri,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  if ((_data?['top_items'] as List?)?.isEmpty ?? true)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('No sales data yet',
                          style: TextStyle(color: textSec)),
                    )
                  else
                    ...List.generate(
                      (_data!['top_items'] as List).length,
                      (i) {
                        final item = _data!['top_items'][i];
                        final maxCount =
                            (_data!['top_items'][0]['count'] as int);
                        final ratio = maxCount > 0
                            ? (item['count'] as int) / maxCount
                            : 0.0;
                        return _bestSellerRow(
                            context, i + 1, item['name'], item['count'], ratio);
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(
      BuildContext ctx, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accent, size: 18),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: AppColors.textPrimary(ctx),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: AppColors.textHint(ctx), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _bestSellerRow(
      BuildContext ctx, int rank, String name, int count, double ratio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppTheme.accent.withValues(alpha: 0.15)
                  : AppColors.surface(ctx),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$rank',
                  style: TextStyle(
                      color:
                          rank == 1 ? AppTheme.accent : AppColors.textHint(ctx),
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: AppColors.textPrimary(ctx),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: AppColors.surface(ctx),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('$count sold',
              style:
                  TextStyle(color: AppColors.textSecondary(ctx), fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── SIMPLE REVENUE BAR CHART (no external deps) ──────────────────────────────
class _RevenueBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _RevenueBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Text('No revenue data yet',
            style: TextStyle(color: AppColors.textSecondary(context))),
      );
    }

    final maxRevenue = data
        .map((d) => (d['revenue'] as num).toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final revenue = (d['revenue'] as num).toDouble();
          final ratio = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Container(
                      height: 90 * v,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(d['day'] ?? '',
                      style: TextStyle(
                          color: AppColors.textHint(context), fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PromotionManager extends StatefulWidget {
  final int restaurantId;
  final String token;

  const _PromotionManager({required this.restaurantId, required this.token});

  @override
  State<_PromotionManager> createState() => _PromotionManagerState();
}

class _PromotionManagerState extends State<_PromotionManager> {
  List<Promotion> _promotions = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final promotions = await ApiService.getMyPromotions(
        token: widget.token,
        restaurantId: widget.restaurantId,
      );
      if (mounted) setState(() => _promotions = promotions);
    } catch (error) {
      if (mounted) {
        setState(() => _error = friendlyMessage(error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPromotion() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 900,
    );
    if (picked == null) return;
    if (!mounted) return;

    final filename = picked.name;
    final lowerFilename = filename.toLowerCase();
    if (!lowerFilename.endsWith('.jpg') &&
        !lowerFilename.endsWith('.jpeg') &&
        !lowerFilename.endsWith('.png') &&
        !lowerFilename.endsWith('.webp')) {
      _showMessage('Choose a JPEG, PNG, or WebP image.', isError: true);
      return;
    }
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 5 * 1024 * 1024) {
      _showMessage('Promotion images must be 5 MB or smaller.', isError: true);
      return;
    }

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final discountController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New promotion'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(bytes,
                  height: 130, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.sentences,
            ),
            TextField(
              controller: discountController,
              decoration: const InputDecoration(
                  labelText: 'Discount percentage (optional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final discountText = discountController.text.trim();
    titleController.dispose();
    descriptionController.dispose();
    discountController.dispose();
    if (confirmed != true) return;
    if (title.isEmpty) {
      _showMessage('Enter a promotion title.', isError: true);
      return;
    }
    final discount = discountText.isEmpty ? null : int.tryParse(discountText);
    if (discountText.isNotEmpty &&
        (discount == null || discount < 0 || discount > 100)) {
      _showMessage('Discount must be a number from 0 to 100.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final promotion = await ApiService.createPromotion(
        token: widget.token,
        restaurantId: widget.restaurantId,
        title: title,
        description: description.isEmpty ? null : description,
        discountPercent: discount,
        imageBytes: bytes,
        filename: filename,
      );
      if (mounted) {
        setState(() => _promotions.insert(0, promotion));
        _showMessage('Promotion uploaded.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(friendlyMessage(error),
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePromotion(Promotion promotion) async {
    try {
      await ApiService.deletePromotion(
        token: widget.token,
        restaurantId: widget.restaurantId,
        promotionId: promotion.id,
      );
      if (mounted) {
        setState(
            () => _promotions.removeWhere((item) => item.id == promotion.id));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(friendlyMessage(error),
            isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Text('Promotions',
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              IconButton(
                tooltip: 'Upload promotion',
                onPressed: _saving ? null : _createPromotion,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_photo_alternate_outlined),
              ),
            ],
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Row(
              children: [
                Expanded(child: Text(_error!)),
                IconButton(
                    tooltip: 'Retry',
                    onPressed: _loadPromotions,
                    icon: const Icon(Icons.refresh)),
              ],
            )
          else if (_promotions.isEmpty)
            Text('No promotions yet.',
                style: TextStyle(color: AppColors.textSecondary(context)))
          else ...[
            Text('Customers see these on your menu and in the Deals feed.',
                style: TextStyle(
                    color: AppColors.textSecondary(context), fontSize: 12)),
            const SizedBox(height: 12),
            for (final promotion in _promotions) ...[
              PromotionCard(
                key: Key('manage-promotion-${promotion.id}'),
                promotion: promotion,
                showRestaurant: false,
                height: 140,
                trailing: IconButton(
                  tooltip: 'Delete promotion',
                  onPressed: () => _deletePromotion(promotion),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0x99000000)),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                ),
              ),
              if (promotion.imageUrl == null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      'This image was lost. Delete it and upload it again.',
                      style: TextStyle(
                          color: AppTheme.warning.withValues(alpha: 0.9),
                          fontSize: 12)),
                ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

// ─── SETTINGS PAGE ────────────────────────────────────────────────────────────
class _SettingsPage extends StatefulWidget {
  final int restaurantId;
  final String? bannerUrl;
  final Restaurant? restaurant;
  final ValueChanged<Restaurant> onRestaurantChanged;
  const _SettingsPage({
    required this.restaurantId,
    this.bannerUrl,
    this.restaurant,
    required this.onRestaurantChanged,
  });
  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _isOpen = true;
  bool _savingOpen = false;
  Uint8List? _pendingBannerBytes;
  String? _pendingBannerFilename;
  String? _bannerUrl;
  bool _isUploadingBanner = false;

  @override
  void initState() {
    super.initState();
    _bannerUrl = widget.bannerUrl;
    _isOpen = widget.restaurant?.isOpen ?? true;
  }

  @override
  void didUpdateWidget(covariant _SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurant != oldWidget.restaurant && !_savingOpen) {
      _isOpen = widget.restaurant?.isOpen ?? _isOpen;
    }
  }

  Future<void> _setKitchenOpen(bool open) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    setState(() {
      _isOpen = open;
      _savingOpen = true;
    });
    try {
      final restaurant =
          await ApiService.updateMyRestaurant(token: token, isOpen: open);
      if (!mounted) return;
      widget.onRestaurantChanged(restaurant);
      showSettingsMessage(
          context,
          open
              ? 'Kitchen is open for orders.'
              : 'Kitchen closed. New orders are paused.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isOpen = !open);
      showSettingsMessage(
          context, friendlyMessage(error),
          isError: true);
    } finally {
      if (mounted) setState(() => _savingOpen = false);
    }
  }

  void _editRestaurantProfile() {
    final restaurant = widget.restaurant;
    if (restaurant == null) return;
    showSettingsSheet(
      context,
      _RestaurantProfileForm(
        restaurant: restaurant,
        onSaved: widget.onRestaurantChanged,
      ),
    );
  }

  Future<void> _chooseBanner() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked == null) return;

    final filename = picked.name.toLowerCase();
    final isSupported = filename.endsWith('.jpg') ||
        filename.endsWith('.jpeg') ||
        filename.endsWith('.png') ||
        filename.endsWith('.webp');
    if (!isSupported) {
      _showBannerMessage('Choose a JPEG, PNG, or WebP image.', isError: true);
      return;
    }

    final bytes = await picked.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      _showBannerMessage('Banner images must be 5 MB or smaller.',
          isError: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _pendingBannerBytes = bytes;
      _pendingBannerFilename = picked.name;
    });
  }

  Future<void> _uploadBanner() async {
    final bytes = _pendingBannerBytes;
    final filename = _pendingBannerFilename;
    final token = context.read<AuthProvider>().token;
    if (bytes == null || filename == null || token == null) return;

    setState(() => _isUploadingBanner = true);
    try {
      final bannerUrl = await ApiService.uploadRestaurantBanner(
        token: token,
        restaurantId: widget.restaurantId,
        imageBytes: bytes,
        filename: filename,
      );
      if (!mounted) return;
      setState(() {
        _bannerUrl = bannerUrl;
        _pendingBannerBytes = null;
        _pendingBannerFilename = null;
      });
      _showBannerMessage('Banner updated successfully.');
    } catch (error) {
      if (!mounted) return;
      _showBannerMessage(
        friendlyMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isUploadingBanner = false);
    }
  }

  void _showBannerMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
    ));
  }

  String? _fullBannerUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? url : '${ApiService.baseUrl}$url';
  }

  Widget _buildBannerSection(BuildContext context, AuthProvider auth) {
    final previewBytes = _pendingBannerBytes;
    final existingUrl = _fullBannerUrl(_bannerUrl);
    final hasSelection = previewBytes != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Restaurant banner',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            hasSelection
                ? 'Preview your image before uploading.'
                : 'JPEG, PNG, or WebP up to 5 MB.',
            style: TextStyle(
                color: AppColors.textSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: previewBytes != null
                  ? Image.memory(previewBytes, fit: BoxFit.cover)
                  : existingUrl != null
                      ? Image.network(existingUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _emptyBannerPreview())
                      : _emptyBannerPreview(),
            ),
          ),
          const SizedBox(height: 12),
          if (hasSelection)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingBanner
                        ? null
                        : () => setState(() {
                              _pendingBannerBytes = null;
                              _pendingBannerFilename = null;
                            }),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingBanner ? null : _chooseBanner,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Choose another'),
                  ),
                ),
              ],
            ),
          if (hasSelection) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploadingBanner
                  ? null
                  : hasSelection
                      ? _uploadBanner
                      : (widget.restaurantId > 0 && auth.token != null
                          ? _chooseBanner
                          : null),
              icon: _isUploadingBanner
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(hasSelection
                      ? Icons.cloud_upload_outlined
                      : Icons.add_a_photo_rounded),
              label: Text(_isUploadingBanner
                  ? 'Uploading...'
                  : hasSelection
                      ? 'Upload banner'
                      : 'Choose banner image'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBannerPreview() {
    return Container(
      color: AppColors.surface(context),
      child: Icon(Icons.image_outlined,
          size: 42, color: AppColors.textHint(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    const AccountHeader(subtitle: 'Restaurant owner'),
                    const SizedBox(height: 20),
                    const ShareRestaurantCard(),
                    const SizedBox(height: 16),
                    _buildBannerSection(context, auth),
                    const SizedBox(height: 16),
                    if (auth.token != null) ...[
                      _PromotionManager(
                        restaurantId: widget.restaurantId,
                        token: auth.token!,
                      ),
                      const SizedBox(height: 16),
                    ],
                    AccountSettingsSection(
                      role: 'restaurant',
                      businessRows: [
                        SettingsTile(
                          key: const Key('settings-kitchen'),
                          icon: Icons.soup_kitchen_outlined,
                          title: 'Kitchen status',
                          subtitle: _isOpen
                              ? 'Open · accepting orders'
                              : 'Closed · new orders paused',
                          trailing: Switch(
                            key: const Key('kitchen-switch'),
                            value: _isOpen,
                            onChanged: _savingOpen ? null : _setKitchenOpen,
                          ),
                          onTap: _savingOpen
                              ? null
                              : () => _setKitchenOpen(!_isOpen),
                        ),
                        SettingsTile(
                          key: const Key('settings-payouts'),
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Payouts',
                          subtitle: 'Where your share of each order is paid',
                          onTap: () => showPayoutSheet(context),
                        ),
                        ShopLocationTile(
                            isSet: widget.restaurant?.latitude != null),
                        SettingsTile(
                          key: const Key('settings-restaurant-profile'),
                          icon: Icons.storefront_outlined,
                          title: 'Restaurant profile',
                          subtitle: widget.restaurant == null
                              ? 'Edit your restaurant details'
                              : '${widget.restaurant!.name} · ${widget.restaurant!.cuisineType}',
                          onTap: _editRestaurantProfile,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SignOutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantProfileForm extends StatefulWidget {
  final Restaurant restaurant;
  final ValueChanged<Restaurant> onSaved;
  const _RestaurantProfileForm(
      {required this.restaurant, required this.onSaved});

  @override
  State<_RestaurantProfileForm> createState() => _RestaurantProfileFormState();
}

class _RestaurantProfileFormState extends State<_RestaurantProfileForm> {
  late final _nameCtrl = TextEditingController(text: widget.restaurant.name);
  late final _cuisineCtrl =
      TextEditingController(text: widget.restaurant.cuisineType);
  late final _addressCtrl =
      TextEditingController(text: widget.restaurant.address);
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cuisineCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if ([_nameCtrl, _cuisineCtrl, _addressCtrl]
        .any((c) => c.text.trim().isEmpty)) {
      showSettingsMessage(context, 'Please fill in every field.',
          isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await ApiService.updateMyRestaurant(
        token: context.read<AuthProvider>().token!,
        name: _nameCtrl.text,
        cuisineType: _cuisineCtrl.text,
        address: _addressCtrl.text,
      );
      if (!mounted) return;
      widget.onSaved(updated);
      Navigator.of(context).pop();
      showSettingsMessage(context, 'Restaurant profile updated.');
    } catch (error) {
      if (mounted) {
        showSettingsMessage(
            context, friendlyMessage(error),
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader(
          title: 'Restaurant profile',
          subtitle: 'This is what customers see in the app.',
        ),
        AppTextField(
          key: const Key('restaurant-name-field'),
          controller: _nameCtrl,
          hint: 'Restaurant name',
          prefixIcon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('restaurant-cuisine-field'),
          controller: _cuisineCtrl,
          hint: 'Cuisine type',
          prefixIcon: Icons.restaurant_menu_rounded,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('restaurant-address-field'),
          controller: _addressCtrl,
          hint: 'Address',
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          key: const Key('restaurant-profile-save'),
          label: 'Save changes',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
