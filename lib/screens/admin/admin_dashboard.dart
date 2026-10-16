import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/account_settings.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/live_refresh.dart';
import '../../widgets/glass.dart';
import '../../utils/time_format.dart';
import '../../services/providers.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/order_issues.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/app_health.dart';
import '../../widgets/commission.dart';
import '../../widgets/rider_pay.dart' show RiderPayPage;
import 'finance_page.dart';
import 'orders_page.dart';
import '../../widgets/rider_verification.dart' show RiderApprovalsPage;
import 'team_page.dart';

int getPendingApprovalsCount(List<Map<String, dynamic>> restaurants) =>
    restaurants.length;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

/// A page of the admin dashboard; [permission] hides it from admins whose
/// role doesn't allow it (the server enforces the same rules).
class AdminDestination {
  final String key, label;
  final IconData icon, activeIcon;
  final String? permission;
  const AdminDestination(this.key, this.label, this.icon, this.activeIcon, [this.permission]);
}

const adminDestinations = [
  AdminDestination('overview', 'Overview', Icons.grid_view_outlined, Icons.grid_view_rounded, 'view'),
  AdminDestination('orders', 'Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'orders'),
  AdminDestination('approvals', 'Approvals', Icons.storefront_outlined, Icons.storefront_rounded, 'approvals'),
  AdminDestination('riders', 'Riders', Icons.electric_bike_outlined, Icons.electric_bike_rounded, 'view'),
  AdminDestination('users', 'Users', Icons.people_outline_rounded, Icons.people_rounded, 'view'),
  AdminDestination('reports', 'Reports', Icons.report_gmailerrorred_outlined, Icons.report_gmailerrorred_rounded, 'reports'),
  AdminDestination('finance', 'Finance', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'finance'),
  AdminDestination('commission', 'Commission', Icons.percent_rounded, Icons.percent_rounded, 'commission'),
  AdminDestination('riderpay', 'Rider pay', Icons.delivery_dining_outlined, Icons.delivery_dining_rounded, 'payouts'),
  AdminDestination('team', 'Team', Icons.group_add_outlined, Icons.group_add_rounded, 'team'),
  AdminDestination('activity', 'Activity log', Icons.history_rounded, Icons.history_rounded, 'audit'),
  AdminDestination('settings', 'Settings', Icons.settings_outlined, Icons.settings_rounded),
];

/// The bottom bar on phones (the rest are in the ☰ menu), in this order.
const _bottomBarKeys = ['overview', 'orders', 'approvals', 'reports', 'settings'];

class _AdminDashboardState extends State<AdminDashboard>
    with LiveRefresh<AdminDashboard> {
  String _selected = 'overview';
  int _pendingApprovalsCount = 0;
  String _navQuery = '';
  bool _sidebarCollapsed = false;

  List<AdminDestination> _visible(AuthProvider auth) => adminDestinations
      .where((d) => d.permission == null || auth.can(d.permission!))
      .toList();

  void _go(String key) => setState(() => _selected = key);

  @override
  void initState() {
    super.initState();
    _refreshBadges();
    startLiveRefresh(_refreshBadges);
  }

  Future<void> _refreshBadges() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      if (auth.can('approvals')) _loadPendingApprovalsCount(),
      if (auth.can('reports')) _loadReportsCount(),
      if (auth.can('orders')) _loadStuckOrdersCount(),
    ]);
  }

  /// Orders stuck too long: the Orders badge.
  int _stuckOrdersCount = 0;

  Future<void> _loadStuckOrdersCount() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final board = await ApiService.getOrdersBoard(token);
      final count = ((board['counts'] as Map?)?['attention'] as num?)?.toInt() ?? 0;
      if (mounted && count != _stuckOrdersCount) setState(() => _stuckOrdersCount = count);
    } catch (_) {}
  }

  /// Open customer reports plus open app errors: the Reports badge.
  int _reportsCount = 0;

  Future<void> _loadReportsCount() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final results = await Future.wait([
        ApiService.getAdminIssues(token),
        ApiService.getErrorReports(token),
      ]);
      final count = results[0].length + results[1].length;
      if (mounted && count != _reportsCount) setState(() => _reportsCount = count);
    } catch (_) {
      // Keep the last known count.
    }
  }

  /// "2 restaurants waiting for approval · 1 open report", or null.
  String? _attentionLine() {
    final approvals = _badgeFor('approvals'), reports = _badgeFor('reports');
    final stuck = _badgeFor('orders');
    final parts = [
      if (stuck > 0) '$stuck order${stuck == 1 ? ' needs' : 's need'} attention',
      if (approvals > 0) '$approvals waiting for approval',
      if (reports > 0) '$reports open report${reports == 1 ? '' : 's'}',
    ];
    return parts.isEmpty ? null : '${parts.join(' · ')}.';
  }

  int _badgeFor(String key) => switch (key) {
        'approvals' => _pendingApprovalsCount,
        'reports' => _reportsCount,
        'orders' => _stuckOrdersCount,
        _ => 0,
      };

  int _pendingRidersCount = 0;

  Future<void> _loadPendingApprovalsCount() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;

    try {
      final list = await ApiService.getPendingRestaurants(auth.token!);
      final riders = await ApiService.getRiderVerifications(auth.token!, 'pending')
          .catchError((_) => <Map<String, dynamic>>[]);
      if (!mounted) return;
      // Restaurants and riders waiting for approval.
      final count = getPendingApprovalsCount(list) + riders.length;
      if (count != _pendingApprovalsCount || riders.length != _pendingRidersCount) {
        setState(() {
          _pendingApprovalsCount = count;
          _pendingRidersCount = riders.length;
        });
      }
    } catch (_) {
      // Keep the last known count if a background refresh fails.
    }
  }

  Widget _buildPage(AuthProvider auth) {
    final visible = _visible(auth);
    final key = visible.any((d) => d.key == _selected)
        ? _selected
        : visible.first.key;
    switch (key) {
      case 'orders': return const AdminOrdersPage();
      case 'approvals':
        return _ApprovalsTabs(
          restaurants: _ApprovalsPage(onPendingCountChanged: _loadPendingApprovalsCount),
          riders: RiderApprovalsPage(onCountChanged: _loadPendingApprovalsCount),
          pendingRiders: _pendingRidersCount,
        );
      case 'riders': return const _RiderDeskPage();
      case 'users': return const _UsersPage();
      case 'reports': return const _ReportsPage();
      case 'finance': return const FinancePage();
      case 'commission': return const CommissionPage();
      case 'riderpay': return const RiderPayPage();
      case 'team': return const TeamPage();
      case 'activity': return const ActivityLogPage();
      case 'settings': return const _AdminSettingsPage();
      default: return _OverviewPage(onNavigate: _go);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide     = MediaQuery.of(context).size.width > 700;
    final theme      = Provider.of<ThemeProvider>(context);
    final bg         = AppColors.bg(context);
    final surf       = AppColors.surface(context);
    final border     = AppColors.border(context);
    final textPri    = AppColors.textPrimary(context);
    final textHint   = AppColors.textHint(context);
    final auth       = Provider.of<AuthProvider>(context);
    // Icons-only sidebar: every part must fit 76px wide.
    final compact    = isWide && _sidebarCollapsed;
    final adminName  = auth.name?.trim().isNotEmpty == true
        ? auth.name!.trim()
        : 'Administrator';

    Future<void> signOut() async {
      if (!await confirmLogout(context) || !context.mounted) return;
      await auth.logout();
      if (!context.mounted) return;
      showLogoutSuccess(context);
      context.go('/');
    }

    Widget sidebar = Container(
      width: isWide ? (_sidebarCollapsed ? 76 : 220) : double.infinity,
      decoration: BoxDecoration(
        color: surf,
        border: Border(right: BorderSide(color: border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand header ─────────────────────────────────
          if (compact)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 12),
              child: Center(
                child: Column(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fastfood_rounded,
                        color: Colors.black, size: 20),
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    tooltip: 'Expand sidebar',
                    icon: Icon(Icons.keyboard_double_arrow_right_rounded,
                        color: textHint, size: 18),
                    onPressed: () =>
                        setState(() => _sidebarCollapsed = false),
                  ),
                ]),
              ),
            )
          else
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 12, 20),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fastfood_rounded,
                      color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FindFood',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textPri,
                              fontWeight: FontWeight.w800, fontSize: 14,
                              letterSpacing: 0.3)),
                      Text('Admin HQ',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.accentText(context), fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (isWide)
                  IconButton(
                    tooltip: 'Collapse sidebar',
                    icon: Icon(Icons.keyboard_double_arrow_left_rounded,
                        color: textHint, size: 18),
                    onPressed: () =>
                        setState(() => _sidebarCollapsed = true),
                  ),
              ],
            ),
          ),

          Divider(color: border, height: 1),
          const SizedBox(height: 10),

          // Local navigation search. It only filters dashboard destinations.
          if (!_sidebarCollapsed || !isWide) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: (value) => setState(() => _navQuery = value),
              style: TextStyle(color: textPri, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search workspace',
                hintStyle: TextStyle(color: textHint, fontSize: 12),
                prefixIcon: Icon(Icons.search_rounded,
                    color: textHint, size: 17),
                suffixIcon: _navQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: Icon(Icons.close_rounded,
                            color: textHint, size: 16),
                        onPressed: () => setState(() => _navQuery = ''),
                      ),
                filled: true,
                fillColor: AppColors.card(context).withValues(alpha: 0.7),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.accent, width: 1.2)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Nav items ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                children: _visible(auth).where((item) {
                  return item.label.toLowerCase().contains(_navQuery.toLowerCase());
                }).map((item) {
                  final i = item.key;
                  final active = _selected == i;
                  return Focus(
                    autofocus: i == 'overview',
                    onKeyEvent: (_, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        _go(i);
                        if (!isWide) Navigator.pop(context);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: GestureDetector(
                    key: Key('admin-nav-$i'),
                    onTap: () {
                      _go(i);
                      if (!isWide) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: EdgeInsets.symmetric(
                          horizontal: compact ? 0 : 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.accent.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: active
                            ? Border.all(
                                color: AppTheme.accent.withValues(alpha: 0.25))
                            : null,
                      ),
                      child: compact
                          ? Center(
                              child: Tooltip(
                                message: item.label,
                                child: Badge(
                                  isLabelVisible: _badgeFor(i) > 0,
                                  label: Text('${_badgeFor(i)}'),
                                  backgroundColor: AppTheme.danger,
                                  child: Icon(active ? item.activeIcon : item.icon,
                                      size: 20,
                                      color: active
                                          ? AppTheme.accent
                                          : textHint),
                                ),
                              ),
                            )
                          : Row(
                        children: [
                          Icon(active ? item.activeIcon : item.icon,
                              size: 18,
                              color: active
                                  ? AppTheme.accent
                                  : textHint),
                          if (!compact) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(item.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active
                                    ? AppColors.accentText(context)
                                    : textHint,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 14,
                              ))),
                          ],
                          if (_badgeFor(i) > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(_badgeFor(i).toString(),
                                  style: const TextStyle(
                                      color: AppTheme.danger,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(color: border, height: 1),

          // ── Bottom section ───────────────────────────────
          if (compact)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Column(children: [
                  Tooltip(
                    message: '$adminName · ${auth.adminRoleLabel}',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
                      child: Text(adminName[0].toUpperCase(),
                          style: TextStyle(color: AppColors.accentText(context),
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    key: const Key('admin-theme-toggle'),
                    tooltip: theme.isDark ? 'Light mode' : 'Dark mode',
                    onPressed: theme.toggle,
                    icon: Icon(
                      theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 20, color: AppTheme.accent,
                    ),
                  ),
                  IconButton(
                    key: const Key('admin-sign-out'),
                    tooltip: 'Sign out',
                    onPressed: signOut,
                    icon: const Icon(Icons.logout_rounded,
                        size: 20, color: AppTheme.danger),
                  ),
                ]),
              ),
            )
          else
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card(context).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
                        child: Text(adminName[0].toUpperCase(),
                          style: TextStyle(color: AppColors.accentText(context),
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(adminName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textPri,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(auth.adminRoleLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: textHint, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Theme toggle
                _SidebarButton(
                  key: const Key('admin-theme-toggle'),
                  icon: theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  label: theme.isDark ? 'Light mode' : 'Dark mode',
                  color: AppTheme.accent,
                  textColor: textPri,
                  background: AppColors.card(context),
                  borderColor: border,
                  onTap: theme.toggle,
                ),
                const SizedBox(height: 8),
                _SidebarButton(
                  key: const Key('admin-sign-out'),
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  color: AppTheme.danger,
                  textColor: AppTheme.danger,
                  background: AppTheme.danger.withValues(alpha: 0.08),
                  borderColor: AppTheme.danger.withValues(alpha: 0.2),
                  onTap: signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Scaffold(
        backgroundColor: bg,
        body: Row(
          children: [
            sidebar,
            Expanded(
              child: GlassBody(
                child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GreetingHeader(
                            name: auth.name?.trim().isNotEmpty == true
                                ? auth.name!
                                : 'Admin',
                            role: 'admin',
                            status: _attentionLine(),
                            padding: const EdgeInsets.fromLTRB(24, 18, 12, 12),
                          ),
                        ),
                        const NotificationBell(size: 38),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Toggle theme',
                          icon: Icon(theme.isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                              color: AppTheme.accent),
                          onPressed: theme.toggle,
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    Expanded(child: _buildPage(auth)),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: bg,
        centerTitle: false,
        title: const Text('FindFood Admin'),
        actions: [
          const NotificationBell(size: 38),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(theme.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
                color: AppTheme.accent),
            onPressed: theme.toggle,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: surf,
        child: sidebar,
      ),
      body: GlassBody(
        child: SafeArea(
          child: Column(
            children: [
              GreetingHeader(
                name: auth.name?.trim().isNotEmpty == true ? auth.name! : 'Admin',
                role: 'admin',
                status: _attentionLine(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              ),
              Expanded(child: _buildPage(auth)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Builder(builder: (context) {
        final visible = {for (final d in _visible(auth)) d.key: d};
        final bar = [for (final k in _bottomBarKeys) if (visible[k] != null) visible[k]!];
        return GlassNavBar(
          currentIndex: bar.indexWhere((d) => d.key == _selected),
          onTap: (i) => _go(bar[i].key),
          items: [
            for (final d in bar)
              GlassNavItem(
                  icon: d.icon,
                  activeIcon: d.activeIcon,
                  label: d.label,
                  badge: _badgeFor(d.key)),
          ],
        );
      }),
    );
  }
}

// ─── APPROVALS: RESTAURANTS AND RIDERS ────────────────────────────────────────
class _ApprovalsTabs extends StatefulWidget {
  final Widget restaurants, riders;
  final int pendingRiders;
  const _ApprovalsTabs({required this.restaurants, required this.riders, required this.pendingRiders});

  @override
  State<_ApprovalsTabs> createState() => _ApprovalsTabsState();
}

class _ApprovalsTabsState extends State<_ApprovalsTabs> {
  bool _riders = false;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool value) {
      final active = _riders == value;
      return Expanded(
        child: GestureDetector(
          key: Key('approvals-tab-${value ? 'riders' : 'restaurants'}'),
          onTap: () => setState(() => _riders = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.black : AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700)),
          ),
        ),
      );
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(children: [
            tab('Restaurants', false),
            tab(widget.pendingRiders > 0 ? 'Riders (${widget.pendingRiders})' : 'Riders', true),
          ]),
        ),
      ),
      Expanded(child: _riders ? widget.riders : widget.restaurants),
    ]);
  }
}

// ─── REPORTS ──────────────────────────────────────────────────────────────────
/// Customer problem reports and app errors, always reachable from the nav.
class _ReportsPage extends StatefulWidget {
  const _ReportsPage();

  @override
  State<_ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<_ReportsPage> {
  bool _errors = false;

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    Widget tab(String label, bool value, Key key) {
      final active = _errors == value;
      return Expanded(
        child: GestureDetector(
          key: key,
          onTap: () => setState(() => _errors = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.black : AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        Text('Reports',
            style: TextStyle(color: textPri, fontSize: 28, fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Customer complaints about orders, and errors in the app.',
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(children: [
            tab('Customer reports', false, const Key('reports-tab-customers')),
            tab('App errors', true, const Key('reports-tab-errors')),
          ]),
        ),
        const SizedBox(height: 18),
        if (_errors) const AppErrorsList() else const AdminReportsList(),
      ],
    );
  }
}

// ─── OVERVIEW ─────────────────────────────────────────────────────────────────
class _OverviewPage extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  const _OverviewPage({required this.onNavigate});

  @override
  State<_OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<_OverviewPage>
    with LiveRefresh<_OverviewPage> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _activity = [];
  bool _activityLoaded = false;
  bool _loading = true;
  String _error = '';
  final Set<String> _expandedStats = {};

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final results = await Future.wait([
        ApiService.getPlatformStats(auth.token!),
        ApiService.getAdminActivity(auth.token!)
            .then<Object?>((value) => value)
            .catchError((Object _) => null), // activity is optional
      ]);
      final stats = results[0] as Map<String, dynamic>;
      final activity = results[1] as List<Map<String, dynamic>>?;
      if (activity != null) {
        _activity = activity;
        _activityLoaded = true;
      }
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      // Keep showing the last good data if a background refresh fails.
      if (silent) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview',
                        style: TextStyle(
                            color: textPri,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Text('Live platform data',
                        style: TextStyle(color: textSec, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Export visible stats',
                      icon: Icon(Icons.download_rounded,
                          color: textSec, size: 19),
                      onPressed: () => _showExportDialog(_stats ?? {}),
                    ),
                    GestureDetector(
                      onTap: _load,
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('Live · tap to refresh',
                            style: TextStyle(
                                color: AppTheme.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppColors.textHint(context)),
                    const SizedBox(height: 12),
                    Text(_error,
                        style: TextStyle(color: textSec),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else
              LayoutBuilder(builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 600;
                final cardW  = isWide
                    ? (constraints.maxWidth - 42) / 4
                    : (constraints.maxWidth - 14) / 2;
                final s = _stats ?? {};
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _statCard(context, 'Total Orders',
                        formatCount(s['total_orders'] ?? 0),
                        'All time · tap to view', Icons.receipt_long_rounded,
                        AppTheme.accent, cardW,
                        expanded: _expandedStats.contains('Total Orders'),
                        onToggle: () => setState(() => _toggleStat('Total Orders')),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const _AdminOrdersScreen()))),
                    _statCard(context, 'Active Riders',
                        formatCount(s['active_riders'] ?? 0),
                        'Tap to view all', Icons.electric_bike_rounded,
                        AppTheme.success, cardW,
                        expanded: _expandedStats.contains('Active Riders'),
                        onToggle: () => setState(() => _toggleStat('Active Riders')),
                        onTap: () => widget.onNavigate('riders')),
                    _statCard(context, 'Restaurants',
                        formatCount(s['total_restaurants'] ?? 0),
                        '${s['pending_approvals'] ?? 0} pending · tap to review',
                        Icons.storefront_rounded,
                        AppTheme.warning, cardW,
                        expanded: _expandedStats.contains('Restaurants'),
                        onToggle: () => setState(() => _toggleStat('Restaurants')),
                        onTap: () => widget.onNavigate('approvals')),
                    _statCard(context, 'Revenue',
                        formatCedis(((s['revenue_today'] ?? 0) as num).round()),
                        'Delivered orders · tap to view', Icons.payments_rounded,
                        const Color(0xFF8B5CF6), cardW,
                        expanded: _expandedStats.contains('Revenue'),
                        onToggle: () => setState(() => _toggleStat('Revenue')),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const _AdminRevenueScreen()))),
                  ],
                );
              }),
            const SizedBox(height: 30),
            const AdminIssuesPanel(),
            const AppHealthPanel(),
            Text('Quick actions',
                style: TextStyle(
                    color: textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 620;
                final width = isWide
                    ? (constraints.maxWidth - 30) / 4
                    : (constraints.maxWidth - 14) / 2;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _quickAction(ctx, 'Review approvals', Icons.fact_check_outlined,
                        AppTheme.warning, width, () => widget.onNavigate('approvals')),
                    _quickAction(ctx, 'Manage riders', Icons.electric_bike_outlined,
                        AppTheme.success, width, () => widget.onNavigate('riders')),
                    _quickAction(ctx, 'View users', Icons.people_outline_rounded,
                        const Color(0xFF60A5FA), width, () => widget.onNavigate('users')),
                    _quickAction(ctx, 'Open settings', Icons.tune_rounded,
                        AppTheme.accent, width, () => widget.onNavigate('settings')),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent activity', style: TextStyle(
                    color: textPri, fontSize: 18, fontWeight: FontWeight.w700)),
                const _LiveIndicator(),
              ],
            ),
            const SizedBox(height: 12),
            _activityPanel(context),
            const SizedBox(height: 18),
            _themePreview(context),
          ],
        ),
      ),
    );
  }

  void _toggleStat(String label) {
    if (!_expandedStats.add(label)) _expandedStats.remove(label);
  }

  void _showExportDialog(Map<String, dynamic> stats) {
    final csv = [
      'Metric,Value',
      'Total Orders,${stats['total_orders'] ?? 0}',
      'Active Riders,${stats['active_riders'] ?? 0}',
      'Restaurants,${stats['total_restaurants'] ?? 0}',
      'Revenue Today,GH₵ ${((stats['revenue_today'] ?? 0) / 100).toStringAsFixed(2)}',
    ].join('\n');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export statistics'),
        content: SelectableText(csv),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('CSV copied to clipboard')));
            },
            child: const Text('Copy CSV'),
          ),
        ],
      ),
    );
  }

  static const _activityIcons = {
    'order': (Icons.receipt_long_outlined, AppTheme.accent),
    'completed': (Icons.check_circle_outline_rounded, AppTheme.success),
    'payment': (Icons.payments_outlined, AppTheme.success),
    'refund': (Icons.currency_exchange_rounded, Color(0xFF60A5FA)),
    'refund_failed': (Icons.report_problem_outlined, AppTheme.danger),
    'rating': (Icons.star_rounded, AppTheme.accent),
    'signup': (Icons.person_add_alt_1_outlined, Color(0xFF60A5FA)),
    'restaurant': (Icons.storefront_outlined, AppTheme.warning),
    'promotion': (Icons.local_offer_outlined, AppTheme.accent),
    'collected': (Icons.delivery_dining_outlined, Color(0xFF60A5FA)),
    'release': (Icons.undo_rounded, AppTheme.warning),
    'issue': (Icons.report_gmailerrorred_rounded, AppTheme.danger),
    'issue_resolved': (Icons.task_alt_rounded, AppTheme.success),
  };

  Widget _activityPanel(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.card(context).withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(context)),
    );
    if (!_activityLoaded || _activity.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: decoration,
        child: Text(
          _activityLoaded
              ? 'No activity yet. New orders, payments, ratings and sign-ups will appear here as they happen.'
              : 'Loading activity...',
          style: TextStyle(color: AppColors.textHint(context), fontSize: 12),
        ),
      );
    }
    final now = DateTime.now();
    return Container(
      key: const Key('admin-activity'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      // Material layer so tappable rows show their ripple on the card.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
        children: _activity.map((item) {
          final (icon, color) = _activityIcons[item['kind']] ??
              (Icons.bolt_rounded, AppTheme.accent);
          final at = DateTime.tryParse('${item['at']}')?.toLocal();
          final detail = '${item['detail'] ?? ''}';
          return ListTile(
            dense: true,
            leading: Icon(icon, color: color, size: 19),
            title: Text('${item['title'] ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            subtitle: detail.isEmpty
                ? null
                : Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 11)),
            trailing: Text(at == null ? '' : relativeTime(at, now),
                style: TextStyle(
                    color: AppColors.textHint(context), fontSize: 11)),
            onTap: item['kind'] == 'restaurant' ? () => widget.onNavigate('approvals') : null,
          );
        }).toList(),
        ),
      ),
    );
  }

  Widget _themePreview(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.palette_outlined,
              color: AppColors.textSecondary(context), size: 19),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 12, fontWeight: FontWeight.w700)),
              Text(theme.isDark ? 'Dark workspace' : 'Light workspace',
                  style: TextStyle(color: AppColors.textHint(context), fontSize: 11)),
            ],
          )),
          GestureDetector(
            onTap: theme.toggle,
            child: Container(
              width: 54,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.isDark ? AppTheme.accent : AppColors.border(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Align(
                alignment: theme.isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: theme.isDark ? Colors.black : AppColors.surface(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(theme.isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      size: 14,
                      color: theme.isDark ? AppTheme.accent : AppTheme.warning),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext ctx, String label, String value,
      String sub, IconData icon, Color color, double width,
      {VoidCallback? onTap, VoidCallback? onToggle, bool expanded = false}) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(ctx).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: onTap != null
              ? color.withValues(alpha: 0.3)
              : AppColors.border(ctx),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(
                onTap != null
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.trending_up_rounded,
                color: onTap != null ? color : AppTheme.success,
                size: onTap != null ? 14 : 16,
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: TextStyle(
                    color: AppColors.textPrimary(ctx),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6)),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary(ctx),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(sub,
              style: const TextStyle(
                  color: AppTheme.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          if (expanded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('View detailed breakdown',
                      style: TextStyle(color: color, fontSize: 11,
                          fontWeight: FontWeight.w600))),
                  IconButton(
                    tooltip: 'Open details',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.arrow_forward_rounded, color: color, size: 16),
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _quickAction(BuildContext ctx, String label, IconData icon,
      Color color, double width, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface(ctx).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(ctx)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textPrimary(ctx),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textHint(ctx), size: 12),
          ],
        ),
      ),
    );
  }
}

// ─── APPROVALS ────────────────────────────────────────────────────────────────
class _ApprovalsPage extends StatefulWidget {
  const _ApprovalsPage({required this.onPendingCountChanged});

  final Future<void> Function() onPendingCountChanged;

  @override
  State<_ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<_ApprovalsPage>
    with LiveRefresh<_ApprovalsPage> {
  List<Map<String, dynamic>> _pending = [];
  bool   _loading = true;
  String _error   = '';
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final list = await ApiService.getPendingRestaurants(auth.token!);
      if (!mounted) return;
      setState(() {
        _pending = list;
        _error = '';
      });
      await widget.onPendingCountChanged();
    } catch (e) {
      if (!mounted) return;
      // Keep showing the last good data if a background refresh fails.
      if (silent) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(int id, String name) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _processingIds.add(id));
    try {
      await ApiService.approveRestaurant(auth.token!, id);
      if (!mounted) return;
      setState(() => _pending.removeWhere((r) => r['id'] == id));
      await widget.onPendingCountChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        content: Text('$name approved! They can now go live.',
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _processingIds.remove(id));
    }
  }

  Future<void> _reject(int id, String name) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject $name?',
            style: TextStyle(color: AppColors.textPrimary(ctx))),
        content: Text(
          'This will permanently remove their application. They will need to reapply.',
          style: TextStyle(color: AppColors.textSecondary(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject',
                style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processingIds.add(id));
    try {
      await ApiService.rejectRestaurant(auth.token!, id);
      if (!mounted) return;
      setState(() => _pending.removeWhere((r) => r['id'] == id));
      await widget.onPendingCountChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text('$name application rejected.',
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _processingIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restaurant Approvals',
                        style: TextStyle(
                            color: textPri, fontSize: 26,
                            fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Review and approve new restaurant registrations',
                        style: TextStyle(color: textSec, fontSize: 13)),
                  ],
                ),
                if (_pending.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                    ),
                    child: Text('${_pending.length} pending',
                        style: const TextStyle(
                            color: AppTheme.warning,
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint(context)),
                    const SizedBox(height: 12),
                    Text(_error, style: TextStyle(color: textSec), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_pending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 56, color: AppTheme.success.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('All caught up!',
                        style: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('No pending restaurant applications.',
                        style: TextStyle(color: textSec)),
                  ],
                ),
              )
            else
              ..._pending.map((r) => _approvalCard(
                    context,
                    id: r['id'],
                    name: r['name'] ?? '',
                    cuisine: r['cuisine_type'] ?? '',
                    addr: r['address'] ?? '',
                    email: r['email'] ?? '',
                    processing: _processingIds.contains(r['id']),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon,
      {required VoidCallback onTap, bool loading = false}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      color: color, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
      ),
    );
  }

  Widget _approvalCard(
    BuildContext ctx, {
    required int id,
    required String name,
    required String cuisine,
    required String addr,
    required String email,
    required bool processing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: AppTheme.warning, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: AppColors.textPrimary(ctx),
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('$cuisine · $addr',
                        style: TextStyle(
                            color: AppColors.textSecondary(ctx), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: const Text('Pending',
                    style: TextStyle(
                        color: AppTheme.warning,
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 13, color: AppColors.textHint(ctx)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(email,
                      style: TextStyle(color: AppColors.textHint(ctx), fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionBtn('Approve', AppTheme.success, Icons.check_rounded,
                    onTap: () => _approve(id, name), loading: processing),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn('Reject', AppTheme.danger, Icons.close_rounded,
                    onTap: () => _reject(id, name), loading: processing),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── RIDERS ───────────────────────────────────────────────────────────────────
class _RiderDeskPage extends StatefulWidget {
  const _RiderDeskPage();

  @override
  State<_RiderDeskPage> createState() => _RiderDeskPageState();
}

class _RiderDeskPageState extends State<_RiderDeskPage>
    with LiveRefresh<_RiderDeskPage> {
  List<Map<String, dynamic>> _riders = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final users = await ApiService.getAllUsers(auth.token!);
      if (!mounted) return;
      setState(() {
        _riders = users.where((u) => u['role'] == 'rider').toList();
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      // Keep showing the last good data if a background refresh fails.
      if (silent) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rider Fleet',
                style: TextStyle(
                    color: textPri, fontSize: 26,
                    fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('${_riders.length} registered riders',
                style: TextStyle(color: textSec, fontSize: 13)),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint(context)),
                    const SizedBox(height: 12),
                    Text(_error, style: TextStyle(color: textSec), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_riders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.electric_bike_outlined,
                        size: 56, color: AppColors.textHint(context)),
                    const SizedBox(height: 16),
                    Text('No riders yet',
                        style: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Riders will appear here once they register.',
                        style: TextStyle(color: textSec)),
                  ],
                ),
              )
            else
              ..._riders.map((r) => _riderCard(context, r['name'] ?? '', r['email'] ?? '')),
          ],
        ),
      ),
    );
  }

  Widget _riderCard(BuildContext ctx, String name, String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: AppColors.accentText(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: AppColors.textPrimary(ctx),
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(email,
                    style: TextStyle(color: AppColors.textSecondary(ctx), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Registered',
                style: TextStyle(
                    color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── USERS ────────────────────────────────────────────────────────────────────
class _UsersPage extends StatefulWidget {
  const _UsersPage();

  @override
  State<_UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<_UsersPage>
    with LiveRefresh<_UsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _error = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final users = await ApiService.getAllUsers(auth.token!);
      if (!mounted) return;
      setState(() {
        _users = users;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      // Keep showing the last good data if a background refresh fails.
      if (silent) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setActive(Map<String, dynamic> user, bool isActive) async {
    final auth = context.read<AuthProvider>();
    final name = user['name'] ?? 'this user';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isActive ? 'Reactivate $name?' : 'Suspend $name?'),
        content: Text(isActive
            ? 'They will be able to sign in again.'
            : 'They will be signed out and cannot sign in until reactivated.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(isActive ? 'Reactivate' : 'Suspend',
                  style: TextStyle(
                      color: isActive ? AppTheme.success : AppTheme.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.setUserActive(
          token: auth.token!, userId: user['id'] as int, isActive: isActive);
      if (!mounted) return;
      setState(() => user['is_active'] = isActive);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.success,
        content: Text('$name ${isActive ? 'reactivated' : 'suspended'}.'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e)),
      ));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _users;
    if (_filter == 'suspended') {
      return _users.where((u) => u['is_active'] == false).toList();
    }
    return _users.where((u) => u['role'] == _filter).toList();
  }

  static const Map<String, Color> _roleColors = {
    'customer':   AppTheme.success,
    'restaurant': AppTheme.warning,
    'rider':      AppTheme.accent,
    'admin':      AppTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Users',
                style: TextStyle(
                    color: textPri, fontSize: 26,
                    fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('${_users.length} registered accounts',
                style: TextStyle(color: textSec, fontSize: 13)),
            const SizedBox(height: 20),

            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All', 'all'),
                  _filterChip('Customers', 'customer'),
                  _filterChip('Restaurants', 'restaurant'),
                  _filterChip('Riders', 'rider'),
                  _filterChip('Admins', 'admin'),
                  _filterChip('Suspended', 'suspended'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint(context)),
                    const SizedBox(height: 12),
                    Text(_error, style: TextStyle(color: textSec), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 56, color: AppColors.textHint(context)),
                    const SizedBox(height: 16),
                    Text('No users found',
                        style: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            else
              ..._filtered.map((u) => _userRow(context, u)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppTheme.accent : AppColors.surface(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? AppTheme.accent : AppColors.border(context)),
          ),
          child: Text(label,
              style: TextStyle(
                color: active ? Colors.black : AppColors.textSecondary(context),
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              )),
        ),
      ),
    );
  }

  Widget _userRow(BuildContext ctx, Map<String, dynamic> u) {
    final role = u['role'] ?? '';
    final color = _roleColors[role] ?? AppColors.textHint(ctx);
    final name = u['name'] ?? '';
    final email = u['email'] ?? '';
    final isActive = u['is_active'] != false;
    final isMe = u['id'] == context.read<AuthProvider>().userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            radius: 20,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: AppColors.textPrimary(ctx),
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(email,
                    style: TextStyle(color: AppColors.textSecondary(ctx), fontSize: 12)),
                if (!isActive)
                  const Text('Suspended',
                      style: TextStyle(
                          color: AppTheme.danger, fontSize: 11,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          if (!isMe)
            PopupMenuButton<bool>(
              key: Key('user-actions-${u['id']}'),
              icon: Icon(Icons.more_vert_rounded, color: AppColors.textHint(ctx)),
              onSelected: (active) => _setActive(u, active),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: !isActive,
                  child: Text(isActive ? 'Suspend account' : 'Reactivate account'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AdminSettingsPage extends StatelessWidget {
  const _AdminSettingsPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: TextStyle(
                  color: AppColors.textPrimary(context), fontSize: 26,
                  fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          const AccountHeader(subtitle: 'Administrator'),
          const SizedBox(height: 24),
          const AccountSettingsSection(role: 'admin'),
          const SizedBox(height: 24),
          const SignOutButton(),
        ],
      ),
    );
  }
}

// ─── ADMIN ORDERS SCREEN ──────────────────────────────────────────────────────
class _AdminOrdersScreen extends StatefulWidget {
  const _AdminOrdersScreen();

  @override
  State<_AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<_AdminOrdersScreen>
    with LiveRefresh<_AdminOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _error = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final orders = await ApiService.getAllOrdersAdmin(auth.token!);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      // Keep showing the last good data if a background refresh fails.
      if (silent) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _orders;
    return _orders.where((o) => o['status'] == _filter).toList();
  }

  static const Map<String, Color> _statusColors = {
    'awaiting_payment': Color(0xFF9E9E9E),
    'pending':          AppTheme.warning,
    'scheduled':        AppTheme.warning,
    'preparing':        AppTheme.accent,
    'ready':            AppTheme.success,
    'out_for_delivery': AppTheme.accent,
    'delivered':        AppTheme.success,
    'picked_up':        AppTheme.success,
    'cancelled':        AppTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('All Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_orders.length} total orders',
                      style: TextStyle(color: textSec, fontSize: 13)),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _chip('All', 'all'),
                  _chip('Awaiting payment', 'awaiting_payment'),
                  _chip('Pending', 'pending'),
                  _chip('Preparing', 'preparing'),
                  _chip('Ready', 'ready'),
                  _chip('On the way', 'out_for_delivery'),
                  _chip('Delivered', 'delivered'),
                  _chip('Picked up', 'picked_up'),
                  _chip('Cancelled', 'cancelled'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent))
                  : _error.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off_rounded,
                                    size: 48, color: AppColors.textHint(context)),
                                const SizedBox(height: 12),
                                Text(_error,
                                    style: TextStyle(color: textSec),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                    onPressed: _load, child: const Text('Retry')),
                              ],
                            ),
                          ),
                        )
                      : _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 56, color: AppColors.textHint(context)),
                                  const SizedBox(height: 16),
                                  Text('No orders found',
                                      style: TextStyle(
                                          color: textPri, fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _orderRow(context, _filtered[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final active = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.accent : AppColors.surface(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? AppTheme.accent : AppColors.border(context)),
          ),
          child: Text(label,
              style: TextStyle(
                color: active ? Colors.black : AppColors.textSecondary(context),
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              )),
        ),
      ),
    );
  }

  Widget _orderRow(BuildContext ctx, Map<String, dynamic> o) {
    final status = o['status'] ?? '';
    final color = _statusColors[status] ?? AppColors.textHint(ctx);
    final amount = ((o['total_amount'] ?? 0) as int) / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${o['id']}',
                  style: TextStyle(
                      color: AppColors.textPrimary(ctx),
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status.replaceAll('_', ' '),
                    style: TextStyle(
                        color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.storefront_outlined,
                  size: 14, color: AppColors.textHint(ctx)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(o['restaurant_name'] ?? 'Unknown',
                    style: TextStyle(
                        color: AppColors.textSecondary(ctx), fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.textHint(ctx)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(o['customer_name'] ?? 'Unknown',
                    style: TextStyle(
                        color: AppColors.textSecondary(ctx), fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              Text('GH₵ ${amount.toStringAsFixed(2)}',
                  style: TextStyle(color: AppColors.accentText(context), fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── ADMIN REVENUE SCREEN ─────────────────────────────────────────────────────
class _AdminRevenueScreen extends StatefulWidget {
  const _AdminRevenueScreen();

  @override
  State<_AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<_AdminRevenueScreen>
    with LiveRefresh<_AdminRevenueScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(() => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final data = await ApiService.getRevenueDetails(auth.token!);
      if (!mounted) return;
      setState(() {
        _data = data as Map<String, dynamic>?;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      // Keep showing the last good data if a background refresh fails.
      if (silent) return;
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
      appBar: AppBar(
        title: const Text('Revenue'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 48, color: AppColors.textHint(context)),
                        const SizedBox(height: 12),
                        Text(_error,
                            style: TextStyle(color: textSec),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Hero revenue card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total revenue (delivered orders)',
                                style: TextStyle(color: textSec, fontSize: 13)),
                            const SizedBox(height: 8),
                            Text(
                              'GH₵ ${((_data?['total_revenue'] ?? 0) / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontSize: 32, fontWeight: FontWeight.w800,
                                  letterSpacing: -1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _miniStat(context, 'Delivered',
                                '${_data?['delivered_orders'] ?? 0}',
                                Icons.check_circle_outline_rounded,
                                AppTheme.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _miniStat(context, 'In progress',
                                '${_data?['pending_orders'] ?? 0}',
                                Icons.hourglass_top_rounded,
                                AppTheme.warning),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _miniStat(context, 'Average order value',
                          'GH₵ ${((_data?['average_order_value'] ?? 0) / 100).toStringAsFixed(2)}',
                          Icons.receipt_rounded, AppTheme.accent, fullWidth: true),

                      const SizedBox(height: 28),
                      Text('Top earning restaurants',
                          style: TextStyle(
                              color: textPri, fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ...((_data?['top_restaurants'] ?? []) as List).isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text('No revenue data yet',
                                    style: TextStyle(color: textSec)),
                              ),
                            ]
                          : ((_data!['top_restaurants'] as List)
                              .asMap()
                              .entries
                              .map((e) => _topRestaurantRow(
                                  context, e.key + 1, e.value))
                              .toList()),

                      const SizedBox(height: 28),
                      Text('Last 7 days',
                          style: TextStyle(
                              color: textPri, fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ...((_data?['daily_revenue'] ?? []) as List)
                          .map((d) => _dayRow(context, d)),
                    ],
                  ),
                ),
    );
  }

  Widget _miniStat(BuildContext ctx, String label, String value,
      IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: AppColors.textPrimary(ctx),
                        fontSize: 16, fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(color: AppColors.textHint(ctx), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topRestaurantRow(BuildContext ctx, int rank, dynamic r) {
    final revenue = ((r['revenue'] ?? 0) as int) / 100;
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
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$rank',
                  style: TextStyle(color: AppColors.accentText(context), fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(r['name'] ?? 'Unknown',
                style: TextStyle(
                    color: AppColors.textPrimary(ctx),
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          Text('GH₵ ${revenue.toStringAsFixed(2)}',
              style: TextStyle(color: AppColors.accentText(context), fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _dayRow(BuildContext ctx, dynamic d) {
    final revenue = ((d['revenue'] ?? 0) as int) / 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card(ctx),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(ctx)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(d['day'] ?? '',
              style: TextStyle(color: AppColors.textSecondary(ctx), fontSize: 13)),
          Text('GH₵ ${revenue.toStringAsFixed(2)}',
              style: TextStyle(
                  color: AppColors.textPrimary(ctx),
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}


class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
              color: AppTheme.success, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        const Text('Live',
            style: TextStyle(
                color: AppTheme.success,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// A full-width sidebar action (theme, sign out) that never overflows.
class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  const _SidebarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
