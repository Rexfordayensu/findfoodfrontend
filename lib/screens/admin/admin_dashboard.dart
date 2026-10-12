import '../customer/food_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/account_settings.dart';
import '../../widgets/greeting_header.dart';
import '../../services/providers.dart';
import '../../services/api_service.dart';

int getPendingApprovalsCount(List<Map<String, dynamic>> restaurants) =>
    restaurants.length;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _pendingApprovalsCount = 0;
  String _navQuery = '';
  bool _sidebarCollapsed = false;

  static const _notificationIcons = {
    'approval': Icons.storefront_outlined,
    'refund': Icons.report_problem_outlined,
    'orders': Icons.receipt_long_outlined,
  };

  final _navItems = [
    {'icon': Icons.grid_view_rounded,           'label': 'Overview'},
    {'icon': Icons.storefront_outlined,          'label': 'Approvals'},
    {'icon': Icons.electric_bike_outlined,       'label': 'Riders'},
    {'icon': Icons.people_outline_rounded,       'label': 'Users'},
    {'icon': Icons.settings_outlined,            'label': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPendingApprovalsCount();
  }

  Future<void> _loadPendingApprovalsCount() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;

    try {
      final list = await ApiService.getPendingRestaurants(auth.token!);
      if (!mounted) return;
      setState(() => _pendingApprovalsCount = getPendingApprovalsCount(list));
    } catch (_) {
      if (!mounted) return;
      setState(() => _pendingApprovalsCount = 0);
    }
  }

  void _showNotifications() {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: ApiService.getAdminNotifications(token),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 36, height: 4,
                      decoration: BoxDecoration(color: AppColors.border(context),
                          borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(height: 18),
                  Text('Notifications', style: TextStyle(
                      color: AppColors.textPrimary(context), fontSize: 20,
                      fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState != ConnectionState.done)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                    )
                  else if (snapshot.hasError)
                    Text(snapshot.error.toString().replaceAll('Exception: ', ''),
                        style: TextStyle(color: AppColors.textSecondary(context)))
                  else if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text("You're all caught up.",
                          style: TextStyle(color: AppColors.textSecondary(context))),
                    )
                  else
                    ...items.map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                                _notificationIcons[item['kind']] ??
                                    Icons.notifications_outlined,
                                color: AppTheme.accent, size: 19),
                          ),
                          title: Text(item['title']?.toString() ?? '',
                              style: TextStyle(color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: Text(item['detail']?.toString() ?? '',
                              style: TextStyle(color: AppColors.textSecondary(context),
                                  fontSize: 12)),
                          onTap: item['kind'] == 'approval'
                              ? () {
                                  Navigator.pop(sheetContext);
                                  setState(() => _selectedIndex = 1);
                                }
                              : null,
                        )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0: return _OverviewPage(onNavigate: (i) => setState(() => _selectedIndex = i));
      case 1: return _ApprovalsPage(onPendingCountChanged: _loadPendingApprovalsCount);
      case 2: return const _RiderDeskPage();
      case 3: return const _UsersPage();
      case 4: return const _AdminSettingsPage();
      default: return _OverviewPage(onNavigate: (i) => setState(() => _selectedIndex = i));
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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
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
                if (!_sidebarCollapsed || !isWide) ...[
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
                        const Text('Admin HQ',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppTheme.accent, fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                if (_sidebarCollapsed && isWide) const Spacer(),
                if (isWide)
                  IconButton(
                    tooltip: _sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                    icon: Icon(_sidebarCollapsed
                        ? Icons.keyboard_double_arrow_right_rounded
                        : Icons.keyboard_double_arrow_left_rounded,
                        color: textHint, size: 18),
                    onPressed: () => setState(
                        () => _sidebarCollapsed = !_sidebarCollapsed),
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
                children: _navItems.asMap().entries.where((entry) {
                  final label = entry.value['label'] as String;
                  return label.toLowerCase().contains(_navQuery.toLowerCase());
                }).map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final active = _selectedIndex == i;
                  return Focus(
                    autofocus: i == 0,
                    onKeyEvent: (_, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        setState(() => _selectedIndex = i);
                        if (!isWide) Navigator.pop(context);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = i);
                      if (!isWide) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
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
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData,
                              size: 18,
                              color: active
                                  ? AppTheme.accent
                                  : textHint),
                          if (!_sidebarCollapsed || !isWide) ...[
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(item['label'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active
                                    ? AppTheme.accent
                                    : textHint,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 14,
                              ))),
                          ],
                          if (i == 1) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(_pendingApprovalsCount.toString(),
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
                        child: Text(
                          (auth.name?.trim().isNotEmpty == true
                                  ? auth.name!.trim()
                                  : 'A')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.name?.trim().isNotEmpty == true
                                  ? auth.name!.trim()
                                  : 'Administrator',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textPri,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text('Admin account',
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
                GestureDetector(
                  onTap: theme.toggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          theme.isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 17, color: AppTheme.accent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          theme.isDark ? 'Light mode' : 'Dark mode',
                          style: TextStyle(
                              color: textPri,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Sign out
                GestureDetector(
                  onTap: () async {
                    if (!await confirmLogout(context) || !context.mounted) return;
                    await auth.logout();
                    if (!context.mounted) return;
                    showLogoutSuccess(context);
                    // Go to feed — splash only plays on cold start
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FoodFeedScreen()),
                      (_) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.danger.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded,
                            size: 17, color: AppTheme.danger),
                        SizedBox(width: 10),
                        Text('Sign out',
                            style: TextStyle(
                                color: AppTheme.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
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
                            padding: const EdgeInsets.fromLTRB(24, 18, 12, 12),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Notifications',
                          icon: const Icon(Icons.notifications_none_rounded),
                          onPressed: _showNotifications,
                        ),
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
                    Expanded(child: _buildPage()),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surf,
        title: Text(_navItems[_selectedIndex]['label'] as String),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: _showNotifications,
          ),
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
      body: SafeArea(
        child: Column(
          children: [
            GreetingHeader(
              name: auth.name?.trim().isNotEmpty == true ? auth.name! : 'Admin',
              role: 'admin',
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            ),
            Expanded(child: _buildPage()),
          ],
        ),
      ),
    );
  }
}

// ─── OVERVIEW ─────────────────────────────────────────────────────────────────
class _OverviewPage extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const _OverviewPage({required this.onNavigate});

  @override
  State<_OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<_OverviewPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String _error = '';
  final Set<String> _expandedStats = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final stats = await ApiService.getPlatformStats(auth.token!);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
                        '${s['total_orders'] ?? 0}',
                        'All time · tap to view', Icons.receipt_long_rounded,
                        AppTheme.accent, cardW,
                        expanded: _expandedStats.contains('Total Orders'),
                        onToggle: () => setState(() => _toggleStat('Total Orders')),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const _AdminOrdersScreen()))),
                    _statCard(context, 'Active Riders',
                        '${s['active_riders'] ?? 0}',
                        'Tap to view all', Icons.electric_bike_rounded,
                        AppTheme.success, cardW,
                        expanded: _expandedStats.contains('Active Riders'),
                        onToggle: () => setState(() => _toggleStat('Active Riders')),
                        onTap: () => widget.onNavigate(2)), // Riders tab
                    _statCard(context, 'Restaurants',
                        '${s['total_restaurants'] ?? 0}',
                        '${s['pending_approvals'] ?? 0} pending · tap to review',
                        Icons.storefront_rounded,
                        AppTheme.warning, cardW,
                        expanded: _expandedStats.contains('Restaurants'),
                        onToggle: () => setState(() => _toggleStat('Restaurants')),
                        onTap: () => widget.onNavigate(1)), // Approvals tab
                    _statCard(context, 'Revenue',
                        'GH₵ ${((s['revenue_today'] ?? 0) / 100).toStringAsFixed(2)}',
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
                        AppTheme.warning, width, () => widget.onNavigate(1)),
                    _quickAction(ctx, 'Manage riders', Icons.electric_bike_outlined,
                        AppTheme.success, width, () => widget.onNavigate(2)),
                    _quickAction(ctx, 'View users', Icons.people_outline_rounded,
                        const Color(0xFF60A5FA), width, () => widget.onNavigate(3)),
                    _quickAction(ctx, 'Open settings', Icons.tune_rounded,
                        AppTheme.accent, width, () => widget.onNavigate(4)),
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
                Text('Local preview', style: TextStyle(
                    color: AppColors.textHint(context), fontSize: 11)),
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

  Widget _activityPanel(BuildContext context) {
    const activity = [
      ('Platform overview refreshed', 'Just now', Icons.refresh_rounded),
      ('Approval queue checked', '12 min ago', Icons.fact_check_outlined),
      ('Revenue report viewed', 'Today', Icons.payments_outlined),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card(context).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: activity.map((item) => ListTile(
          dense: true,
          leading: Icon(item.$3, color: AppTheme.accent, size: 19),
          title: Text(item.$1, style: TextStyle(
              color: AppColors.textPrimary(context), fontSize: 12,
              fontWeight: FontWeight.w600)),
          trailing: Text(item.$2, style: TextStyle(
              color: AppColors.textHint(context), fontSize: 11)),
        )).toList(),
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
          Text(value,
              style: TextStyle(
                  color: AppColors.textPrimary(ctx),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
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
                  maxLines: 1,
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

class _ApprovalsPageState extends State<_ApprovalsPage> {
  List<Map<String, dynamic>> _pending = [];
  bool   _loading = true;
  String _error   = '';
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final list = await ApiService.getPendingRestaurants(auth.token!);
      if (!mounted) return;
      setState(() => _pending = list);
      await widget.onPendingCountChanged();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
        content: Text(e.toString().replaceAll('Exception: ', ''),
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
        content: Text(e.toString().replaceAll('Exception: ', ''),
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

class _RiderDeskPageState extends State<_RiderDeskPage> {
  List<Map<String, dynamic>> _riders = [];
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
    setState(() { _loading = true; _error = ''; });
    try {
      final users = await ApiService.getAllUsers(auth.token!);
      if (!mounted) return;
      setState(() => _riders = users.where((u) => u['role'] == 'rider').toList());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
                style: const TextStyle(
                    color: AppTheme.accent,
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

class _UsersPageState extends State<_UsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _error = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final users = await ApiService.getAllUsers(auth.token!);
      if (!mounted) return;
      setState(() => _users = users);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
        content: Text(e.toString().replaceAll('Exception: ', '')),
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

class _AdminOrdersScreenState extends State<_AdminOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String _error = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final orders = await ApiService.getAllOrdersAdmin(auth.token!);
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w800)),
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

class _AdminRevenueScreenState extends State<_AdminRevenueScreen> {
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
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await ApiService.getRevenueDetails(auth.token!);
      if (!mounted) return;
      setState(() => _data = data as Map<String, dynamic>?);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
                  style: const TextStyle(
                      color: AppTheme.accent, fontWeight: FontWeight.w800, fontSize: 12)),
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
              style: const TextStyle(
                  color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w700)),
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