import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../theme.dart';
import '../../widgets/glass.dart';
import '../../widgets/handoff_code.dart';
import '../../widgets/live_refresh.dart';
import '../../widgets/chat_button.dart';
import '../../widgets/widgets.dart';
import '../../widgets/account_settings.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../utils/friendly_error.dart';

class RiderDashboard extends StatefulWidget {
  const RiderDashboard({super.key});

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AvailableDeliveriesPage(),
      const _MyDeliveriesPage(),
      const _RiderEarningsPage(),
      const _RiderSettingsPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: GlassBody(child: pages[_selectedIndex]),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          GlassNavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore_rounded,
              label: 'Available'),
          GlassNavItem(
              icon: Icons.electric_bike_outlined,
              activeIcon: Icons.electric_bike_rounded,
              label: 'My Deliveries'),
          GlassNavItem(
              icon: Icons.payments_outlined,
              activeIcon: Icons.payments_rounded,
              label: 'Earnings'),
          GlassNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── AVAILABLE DELIVERIES PAGE ────────────────────────────────────────────────
class _AvailableDeliveriesPage extends StatefulWidget {
  const _AvailableDeliveriesPage();

  @override
  State<_AvailableDeliveriesPage> createState() =>
      _AvailableDeliveriesPageState();
}

class _AvailableDeliveriesPageState extends State<_AvailableDeliveriesPage> {
  List<Order> _orders = [];
  bool _loading = true;
  bool _isOnline = true;
  RiderAnalytics? _today;

  Future<void> _loadTodayStats(String token) async {
    try {
      final json = await ApiService.getRiderAnalytics(token);
      if (mounted) setState(() => _today = RiderAnalytics.fromJson(json));
    } catch (_) {
      // Stats are secondary; the job list still works without them.
    }
  }

  Future<void> _openDeliveryMap(Order order) async {
    final destination =
        order.deliveryLatitude != null && order.deliveryLongitude != null
            ? '${order.deliveryLatitude},${order.deliveryLongitude}'
            : order.deliveryAddress;
    if (destination == null || destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('This order does not have a delivery destination.'),
      ));
      return;
    }

    final url = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
    }).toString();
    if (!await launchUrlString(url, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open maps.'),
      ));
    }
  }

  String _error = '';
  Timer? _pollTimer;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
    // Poll every 6 seconds for new available jobs
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) => _poll());
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
    unawaited(_loadTodayStats(auth.token!));
    try {
      final response = await ApiService.getAvailableDeliveries(auth.token!);
      if (!mounted) return;
      setState(() {
        _orders = response;
        _previousCount = response.length;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Silent background refresh — no loading spinner, just updates the list
  Future<void> _poll() async {
    if (!_isOnline) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    try {
      final response = await ApiService.getAvailableDeliveries(auth.token!);
      if (!mounted) return;
      if (response.length > _previousCount) {
        // New job appeared — notify rider
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text('New delivery available!',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700)),
            ],
          ),
        ));
      }
      setState(() {
        _orders = response;
        _previousCount = response.length;
      });
    } catch (_) {
      // Silent fail on background poll
    }
  }

  Future<void> _acceptDelivery(Order order) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final accepted = await ApiService.acceptDelivery(auth.token!, order.id);
      if (!mounted) return;
      setState(() => _orders.removeWhere((o) => o.id == order.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.success,
        content: Text(
            'Delivery #${order.id} accepted. Your pickup code is '
            '${accepted.pickupCode ?? 'in My deliveries'} — give it to the '
            'restaurant when you collect.',
            style: const TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available jobs',
                            style: AppText.display,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 2),
                        Text('Tap a job to accept it', style: AppText.body),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Online / Offline toggle
                  GestureDetector(
                    onTap: () => setState(() => _isOnline = !_isOnline),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? AppTheme.success.withValues(alpha: 0.12)
                            : AppColors.surface(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isOnline
                              ? AppTheme.success.withValues(alpha: 0.5)
                              : AppColors.border(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isOnline
                                  ? AppTheme.success
                                  : AppColors.textHint(context),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: _isOnline
                                  ? AppTheme.success
                                  : AppColors.textHint(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats strip ─────────────────────────────────────
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _statPill(Icons.electric_bike_rounded, '${_orders.length}',
                      'Available'),
                  _statPill(Icons.check_circle_outline_rounded,
                      '${_today?.todayDeliveries ?? 0}', 'Completed today'),
                  _statPill(Icons.payments_outlined,
                      formatCedis(_today?.todayEarnings ?? 0), 'Earned today'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Orders ─────────────────────────────────────────
            Expanded(
              child: !_isOnline
                  ? const EmptyState(
                      icon: Icons.electric_bike_outlined,
                      title: 'You\'re offline',
                      subtitle:
                          'Go online to start seeing available deliveries.',
                    )
                  : _loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: AppTheme.accent))
                      : _error.isNotEmpty
                          ? EmptyState(
                              icon: Icons.wifi_off_rounded,
                              title: 'Connection failed',
                              subtitle: _error,
                              actionLabel: 'Retry',
                              onAction: _load,
                            )
                          : _orders.isEmpty
                              ? const EmptyState(
                                  icon: Icons.inbox_outlined,
                                  title: 'No deliveries right now',
                                  subtitle:
                                      'Stay online — new jobs appear as orders come in.',
                                )
                              : RefreshIndicator(
                                  color: AppTheme.accent,
                                  onRefresh: _load,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 4, 20, 100),
                                    itemCount: _orders.length,
                                    itemBuilder: (_, i) =>
                                        _deliveryCard(_orders[i]),
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label, style: AppText.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deliveryCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // ── Route info ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chat opens once the rider has accepted the job.
                    Text('Order #${order.id}', style: AppText.title),
                    Text(order.displayTotal,
                        style: AppText.title.copyWith(color: AppTheme.accent)),
                  ],
                ),
                const SizedBox(height: 14),

                // Pickup
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: AppTheme.accent, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup',
                              style: TextStyle(
                                  color: AppColors.textHint(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                          Text(order.restaurantName ?? 'Restaurant',
                              style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),

                // Line connector
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Container(
                    width: 2,
                    height: 20,
                    color: AppColors.border(context),
                  ),
                ),

                // Dropoff
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home_rounded,
                          color: AppTheme.success, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dropoff',
                              style: TextStyle(
                                  color: AppColors.textHint(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                          Text(order.deliveryPlace,
                              style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (order.hasDestination) ...[
                      const SizedBox(width: 8),
                      ActionPill(
                        key: Key('available-directions-${order.id}'),
                        icon: Icons.near_me_outlined,
                        label: 'Directions',
                        semanticLabel: 'Directions to the drop-off',
                        onPressed: () => _openDeliveryMap(order),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (order.items.isNotEmpty) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: PackingList(order: order, dense: true),
            ),
          ],
          Divider(height: 1, color: AppColors.border(context)),

          // ── Accept button ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _acceptDelivery(order),
                icon: const Icon(Icons.electric_bike_rounded,
                    color: Colors.black, size: 18),
                label: const Text('Accept delivery'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MY DELIVERIES PAGE ───────────────────────────────────────────────────────
class _MyDeliveriesPage extends StatefulWidget {
  const _MyDeliveriesPage();

  @override
  State<_MyDeliveriesPage> createState() => _MyDeliveriesPageState();
}

class _MyDeliveriesPageState extends State<_MyDeliveriesPage> with LiveRefresh {
  List<Order> _orders = [];
  bool _loading = true;
  String _error = '';

  Future<void> _openDeliveryMap(Order order) async {
    final destination =
        order.deliveryLatitude != null && order.deliveryLongitude != null
            ? '${order.deliveryLatitude},${order.deliveryLongitude}'
            : order.deliveryAddress;
    if (destination == null || destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('This order does not have a delivery destination.'),
      ));
      return;
    }

    final url = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
    }).toString();
    if (!await launchUrlString(url, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open maps.'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    // Picks up the restaurant's handover without a manual refresh.
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }
    try {
      final orders = await ApiService.getMyOrders(auth.token!);
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted || silent) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted && !silent) {
        setState(() => _loading = false);
      }
    }
  }

  /// Gives a job back before collecting it; the server enforces the rules.
  Future<void> _releaseJob(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Release order #${order.id}?'),
        content: const Text(
            'It goes back to the available jobs for another rider. You can '
            'release up to 2 jobs a day, and never after collecting the food.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep job')),
          TextButton(
              key: const Key('confirm-release'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Release',
                  style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.releaseDelivery(
          context.read<AuthProvider>().token!, order.id);
      if (!mounted) return;
      setState(() => _orders.removeWhere((o) => o.id == order.id));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Order #${order.id} released to other riders.'),
        ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: AppTheme.danger,
          content: Text(friendlyMessage(e),
              style: const TextStyle(color: Colors.white)),
        ));
    }
  }

  /// The rider asks the customer for their code to finish the delivery.
  Future<void> _completeDelivery(Order order) async {
    final token = context.read<AuthProvider>().token!;
    final done = await showHandoffCodeEntry(
      context,
      title: "Enter the customer's code",
      instructions:
          'Ask the customer for the 4-digit delivery code shown in their '
          'FindFood app. Hand over the food once the code is accepted.',
      actionLabel: 'Complete delivery',
      submit: (code) async {
        final updated =
            await ApiService.completeDelivery(token, order.id, code);
        if (!mounted) return;
        setState(() {
          final idx = _orders.indexWhere((o) => o.id == order.id);
          if (idx != -1) _orders[idx] = updated;
        });
      },
    );
    if (done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppTheme.success,
        content: Text('Delivery complete. Nice work!',
            style: TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('My deliveries', style: AppText.display),
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
                          onAction: _load,
                        )
                      : _orders.isEmpty
                          ? const EmptyState(
                              icon: Icons.electric_bike_outlined,
                              title: 'No deliveries yet',
                              subtitle:
                                  'Accept a job from Available tab to get started.',
                            )
                          : RefreshIndicator(
                              color: AppTheme.accent,
                              onRefresh: _load,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: _orders.length,
                                itemBuilder: (_, i) =>
                                    _myDeliveryCard(_orders[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myDeliveryCard(Order order) {
    final isActive = order.status == 'out_for_delivery';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppTheme.accent.withValues(alpha: 0.4)
              : AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Order #${order.id}', style: AppText.title)),
              if (!order.isCancelled) ...[
                ChatButton(
                  key: Key('rider-chat-${order.id}'),
                  withWhom:
                      'the customer or ${order.restaurantName ?? 'the restaurant'}',
                  onPressed: () => openOrderChat(context, order.id, [
                    const ChatContact('customer', 'Customer',
                        'Directions and delivery updates'),
                    ChatContact('restaurant', order.restaurantName ?? 'Restaurant',
                        'Collecting the order'),
                  ]),
                ),
                const SizedBox(width: 8),
              ],
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.displayTotal,
              style: AppText.label.copyWith(color: AppTheme.accent)),
          if (order.deliveryAddress != null ||
              order.deliveryLatitude != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppTheme.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliveryPlace,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label,
                      ),
                      if (order.isPinnedLocation)
                        Text("Shared from the customer's phone",
                            style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12)),
                    ],
                  ),
                ),
                if (order.hasDestination) ...[
                  const SizedBox(width: 8),
                  ActionPill(
                    key: Key('rider-directions-${order.id}'),
                    icon: Icons.near_me_outlined,
                    label: 'Directions',
                    semanticLabel: 'Directions to the drop-off',
                    onPressed: () => _openDeliveryMap(order),
                  ),
                ],
              ],
            ),
          ],
          if (order.awaitingRiderPickup && order.pickupCode != null) ...[
            const SizedBox(height: 14),
            HandoffCodeCard(
              key: Key('rider-pickup-code-${order.id}'),
              title: 'Pickup code',
              code: order.pickupCode!,
              icon: Icons.storefront_outlined,
              instructions:
                  'Check the bag is labelled #${order.id} and has everything '
                  'below, then give this code to '
                  '${order.restaurantName ?? 'the restaurant'}. '
                  '${order.status == 'ready' ? 'The food is ready.' : 'The kitchen is still preparing it.'}',
            ),
            const SizedBox(height: 12),
            Text('In the bag',
                style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            PackingList(order: order),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                key: Key('rider-release-${order.id}'),
                onPressed: () => _releaseJob(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary(context),
                  side: BorderSide(color: AppColors.border(context)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: const Text('Release this job'),
              ),
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                key: Key('rider-complete-${order.id}'),
                onPressed: () => _completeDelivery(order),
                icon: const Icon(Icons.pin_outlined,
                    color: Colors.black, size: 18),
                label: const Text("Complete with customer's code"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── RIDER EARNINGS PAGE ──────────────────────────────────────────────────────
class _RiderEarningsPage extends StatefulWidget {
  const _RiderEarningsPage();

  @override
  State<_RiderEarningsPage> createState() => _RiderEarningsPageState();
}

class _RiderEarningsPageState extends State<_RiderEarningsPage> {
  RiderAnalytics? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final json = await ApiService.getRiderAnalytics(token);
      if (!mounted) return;
      setState(() => _data = RiderAnalytics.fromJson(json));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Earnings', style: AppText.display),
              const SizedBox(height: 20),
              if (_loading && data == null)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                      child: CircularProgressIndicator(color: AppTheme.accent)),
                )
              else if (_error != null && data == null)
                Column(children: [
                  Text(_error!,
                      style:
                          TextStyle(color: AppColors.textSecondary(context))),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ])
              else if (data != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Earned today', style: AppText.label),
                      const SizedBox(height: 6),
                      Text(formatCedis(data.todayEarnings),
                          key: const Key('rider-today-earnings'),
                          style: TextStyle(
                            color: AppColors.accentText(context),
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          )),
                      const SizedBox(height: 10),
                      Row(children: [
                        Icon(Icons.local_shipping_outlined,
                            color: AppColors.textSecondary(context), size: 14),
                        const SizedBox(width: 6),
                        Text(
                            '${data.todayDeliveries} '
                            'deliver${data.todayDeliveries == 1 ? 'y' : 'ies'} completed today',
                            style: AppText.caption.copyWith(
                                color: AppColors.textSecondary(context))),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  _miniStat('This week', formatCedis(data.weekEarnings)),
                  const SizedBox(width: 14),
                  _miniStat('This month', formatCedis(data.monthEarnings)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _miniStat('All time', formatCedis(data.totalEarnings)),
                  const SizedBox(width: 14),
                  _miniStat(
                      'Rating',
                      data.averageRating == null
                          ? 'No ratings yet'
                          : '★ ${data.averageRating!.toStringAsFixed(1)}'),
                ]),
                const SizedBox(height: 24),
                const Text('Recent deliveries', style: AppText.heading),
                const SizedBox(height: 14),
                if (data.recentDeliveries.isEmpty)
                  Text('Completed deliveries will appear here.',
                      style: TextStyle(color: AppColors.textHint(context)))
                else
                  ...data.recentDeliveries.map(_recentRow),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
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
            Text(label, style: AppText.caption),
            const SizedBox(height: 4),
            Text(value, style: AppText.title),
          ],
        ),
      ),
    );
  }

  Widget _recentRow(RiderDelivery delivery) {
    final when = delivery.completedAt;
    final details = [
      if (delivery.restaurantName != null) delivery.restaurantName!,
      if (when != null)
        '${when.day}/${when.month} '
            '${when.hour.toString().padLeft(2, '0')}:'
            '${when.minute.toString().padLeft(2, '0')}',
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${delivery.orderId}', style: AppText.label),
                Text(details,
                    style: AppText.caption
                        .copyWith(color: AppColors.textHint(context))),
              ],
            ),
          ),
          Text(formatCedis(delivery.earning),
              style: AppText.label.copyWith(
                  color: AppTheme.accent, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── RIDER SETTINGS / PROFILE PAGE ───────────────────────────────────────────
class _RiderSettingsPage extends StatelessWidget {
  const _RiderSettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            Text('Profile', style: AppText.display),
            SizedBox(height: 24),
            AccountHeader(subtitle: 'Rider'),
            SizedBox(height: 28),
            AccountSettingsSection(role: 'rider'),
            SizedBox(height: 24),
            SignOutButton(),
          ],
        ),
      ),
    );
  }
}
