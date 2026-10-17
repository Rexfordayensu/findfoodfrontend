import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../utils/share_helper.dart';
import '../../widgets/account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import '../../widgets/widgets.dart';

/// Starts a group order at [restaurant] (asking how long friends get) and
/// opens it. Signed-out people are sent to sign in first.
Future<void> startGroupOrder(BuildContext context, Restaurant restaurant) async {
  final auth = context.read<AuthProvider>();
  if (!auth.isLoggedIn || auth.token == null) {
    context.go(Uri(path: '/login', queryParameters: {'returnTo': '/restaurants/${restaurant.id}'}).toString());
    return;
  }
  final minutes = await showSettingsSheet<int>(context, _HowLong(restaurantName: restaurant.name));
  if (minutes == null || !context.mounted) return;
  try {
    final group = await ApiService.startGroupOrder(auth.token!, restaurantId: restaurant.id, minutes: minutes);
    if (context.mounted) context.push('/group/${group['code']}');
  } catch (e) {
    if (context.mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
  }
}

/// A card on a restaurant's page inviting people to order together.
class GroupOrderCard extends StatelessWidget {
  final Restaurant restaurant;
  const GroupOrderCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const Key('group-order-start'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => startGroupOrder(context, restaurant),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.45)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.groups_rounded, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order with friends',
                    style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text('One delivery for your hostel or office. Share a link, everyone adds their food, you pay once.',
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5, height: 1.35)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary(context)),
          ]),
        ),
      ),
    );
  }
}

class _HowLong extends StatelessWidget {
  final String restaurantName;
  const _HowLong({required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    Widget option(int minutes, String detail) => ListTile(
          key: Key('group-minutes-$minutes'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.timer_outlined),
          title: Text('$minutes minutes',
              style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
          subtitle: Text(detail, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
          onTap: () => Navigator.of(context).pop(minutes),
        );
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      SheetHeader(
        title: 'Start a group order',
        subtitle: 'From $restaurantName. How long do friends get to add their food? You pay for everyone '
            'and settle up with them yourselves.',
      ),
      option(15, 'Quick: people close by'),
      option(20, 'Usually enough for a hostel floor'),
      option(30, 'More time for everyone to reply'),
      option(45, 'Planning ahead'),
    ]);
  }
}

/// /group/<code>: the shared basket.
class GroupOrderScreen extends StatefulWidget {
  final String code;
  const GroupOrderScreen({super.key, required this.code});

  /// How often the basket refreshes (null in tests: once).
  static Duration? refreshEvery = kIsWeb ? const Duration(seconds: 4) : null;

  @override
  State<GroupOrderScreen> createState() => _GroupOrderScreenState();
}

class _GroupOrderScreenState extends State<GroupOrderScreen> {
  Map<String, dynamic>? _group;
  String? _error;
  Timer? _refresh, _tick;
  bool _busy = false;

  String get _token => context.read<AuthProvider>().token!;

  @override
  void initState() {
    super.initState();
    _load();
    final every = GroupOrderScreen.refreshEvery;
    if (every != null) {
      _refresh = Timer.periodic(every, (_) => _load());
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _group != null && _group!['state'] == 'open') {
          setState(() => _group!['seconds_left'] = ((_group!['seconds_left'] as int) - 1).clamp(0, 1 << 30));
        }
      });
    }
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final group = await ApiService.getGroupOrder(_token, widget.code);
      if (mounted) {
        setState(() {
          _group = group;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && _group == null) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _run(Future<Map<String, dynamic>> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      final group = await action();
      if (!mounted) return;
      setState(() => _group = group);
      if (done != null) showSettingsMessage(context, done);
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Map<String, dynamic>? get _me =>
      ((_group?['people'] as List?) ?? const []).cast<Map<String, dynamic>>().where((p) => p['is_me'] == true).firstOrNull;

  Future<void> _editMyFood() async {
    final group = _group!;
    final restaurantId = (group['restaurant'] as Map)['id'] as int;
    final mine = <int, int>{
      for (final item in ((_me?['items'] as List?) ?? const []).cast<Map>())
        item['menu_item_id'] as int: item['quantity'] as int,
    };
    final chosen = await showModalBottomSheet<Map<int, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MenuPicker(restaurantId: restaurantId, initial: mine),
    );
    if (chosen == null || !mounted) return;
    await _run(
      () => ApiService.setGroupItems(_token, widget.code, [
        for (final e in chosen.entries)
          if (e.value > 0) {'menu_item_id': e.key, 'quantity': e.value},
      ]),
      done: chosen.values.any((q) => q > 0) ? 'Your food is in the basket.' : 'Your food was removed.',
    );
  }

  Future<void> _share() async {
    final group = _group!;
    final name = (group['restaurant'] as Map?)?['name'] ?? 'FindFood';
    final minutes = ((group['seconds_left'] as int) / 60).ceil();
    final text = 'Add your food to our group order from $name on FindFood'
        '${group['state'] == 'open' ? ' (closes in $minutes min)' : ''}. One delivery for all of us.';
    final result = await shareLink(text: text, url: '${group['link']}');
    if (result == ShareResult.unsupported && mounted) {
      await Clipboard.setData(ClipboardData(text: '$text ${group['link']}'));
      if (mounted) showSettingsMessage(context, 'Invite copied. Paste it in your WhatsApp group.');
    }
  }

  /// The host checks out: the basket locks and fills the normal checkout.
  Future<void> _checkout() async {
    setState(() => _busy = true);
    try {
      final group = await ApiService.lockGroupOrder(_token, widget.code);
      if (!mounted) return;
      setState(() => _group = group);
      final restaurant = group['restaurant'] as Map;
      final cart = context.read<CartProvider>();
      cart.loadGroup(
        code: '${group['code']}',
        people: group['people_count'] as int,
        restaurantId: restaurant['id'] as int,
        restaurantName: '${restaurant['name']}',
        restaurantAddress: restaurant['address'] as String?,
        dishes: [
          for (final person in (group['people'] as List).cast<Map>())
            for (final item in (person['items'] as List).cast<Map>())
              (
                MenuItem(
                  id: item['menu_item_id'] as int,
                  name: '${item['name']}',
                  price: item['price'] as int,
                  imageUrl: item['image_url'] as String?,
                  isAvailable: true,
                  restaurantId: restaurant['id'] as int,
                ),
                item['quantity'] as int,
              ),
        ],
      );
      context.push('/cart');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this group order?'),
        content: const Text('Everyone who added food will be told. Nothing has been paid yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep it')),
          TextButton(
            key: const Key('group-cancel-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel order', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (sure == true && mounted) {
      await _run(() => ApiService.cancelGroupOrder(_token, widget.code), done: 'Group order cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('Group order'),
        actions: [
          if (group != null && group['is_host'] == true && !const ['placed', 'cancelled', 'expired'].contains(group['state']))
            IconButton(
              key: const Key('group-cancel'),
              tooltip: 'Cancel group order',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _busy ? null : _cancel,
            ),
        ],
      ),
      body: group == null
          ? Center(
              child: _error != null
                  ? EmptyState(icon: Icons.group_off_rounded, title: "Couldn't open this group order",
                      subtitle: _error!, actionLabel: 'Try again', onAction: _load)
                  : const CircularProgressIndicator(color: AppTheme.accent))
          : RefreshIndicator(
              color: AppTheme.accent,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  _Header(group: group),
                  const SizedBox(height: 14),
                  if (const ['open', 'closing'].contains(group['state'])) ...[
                    _InviteCard(group: group, onShare: _share),
                    const SizedBox(height: 14),
                  ],
                  _MyFood(group: group, me: _me, busy: _busy, onEdit: _editMyFood),
                  const SizedBox(height: 18),
                  Text("Everyone's food",
                      style: TextStyle(color: AppColors.textPrimary(context), fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  for (final person in (group['people'] as List).cast<Map<String, dynamic>>())
                    _PersonCard(person: person),
                ],
              ),
            ),
      bottomNavigationBar: group == null ? null : _BottomBar(group: group, busy: _busy, onCheckout: _checkout,
          onReopen: () => _run(() => ApiService.unlockGroupOrder(_token, widget.code), done: 'Basket reopened.')),
    );
  }
}

String _clock(int seconds) {
  final m = seconds ~/ 60, s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String _stateLine(Map<String, dynamic> g) {
  final host = g['host_name'];
  return switch (g['state']) {
    'open' => '${_clock(g['seconds_left'] as int)} left to add food',
    'closing' => "Time's up. $host is checking out",
    'locked' => '$host is checking out',
    'placed' => _orderLine(g),
    'cancelled' => '$host cancelled this group order',
    _ => 'This group order has closed',
  };
}

String _orderLine(Map<String, dynamic> g) => switch (g['order_status']) {
      'awaiting_payment' => 'Placed. Waiting for ${g['host_name']} to pay',
      'pending' => 'Sent to the restaurant',
      'preparing' => 'Being prepared',
      'ready' => 'Packed and ready',
      'out_for_delivery' => 'On the way',
      'delivered' => 'Delivered. Enjoy!',
      'picked_up' => 'Collected. Enjoy!',
      'cancelled' => 'The order was cancelled',
      _ => 'Order placed',
    };

class _Header extends StatelessWidget {
  final Map<String, dynamic> group;
  const _Header({required this.group});

  @override
  Widget build(BuildContext context) {
    final restaurant = group['restaurant'] as Map?;
    final open = group['state'] == 'open';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.groups_rounded, color: Colors.black, size: 20),
          const SizedBox(width: 6),
          Text('Hosted by ${group['host_name']}${group['is_host'] == true ? ' (you)' : ''}',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
        const SizedBox(height: 8),
        Text('${restaurant?['name'] ?? 'Restaurant'}',
            style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        const SizedBox(height: 10),
        Row(children: [
          Icon(open ? Icons.timer_outlined : Icons.info_outline_rounded, size: 18, color: Colors.black87),
          const SizedBox(width: 6),
          Expanded(
            child: Text(_stateLine(group),
                key: const Key('group-state'),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Wrap(spacing: 8, runSpacing: 6, children: [
              _chip('${group['people_count']} of ${group['max_people']} people'),
              _chip('${group['dish_count']} dish${group['dish_count'] == 1 ? '' : 'es'}'),
            ]),
          ),
          const SizedBox(width: 8),
          Text(formatCedis(group['total'] as int),
              key: const Key('group-total'),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
      ]),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
      );
}

class _InviteCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onShare;
  const _InviteCard({required this.group, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Invite friends',
                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text('Send the link to your hostel or office group. They sign in and add their own food.',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5, height: 1.35)),
          ]),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          key: const Key('group-share'),
          onPressed: onShare,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800),
          ),
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: const Text('Share'),
        ),
      ]),
    );
  }
}

class _MyFood extends StatelessWidget {
  final Map<String, dynamic> group;
  final Map<String, dynamic>? me;
  final bool busy;
  final VoidCallback onEdit;
  const _MyFood({required this.group, required this.me, required this.busy, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final items = ((me?['items'] as List?) ?? const []).cast<Map>();
    final state = group['state'];
    final isHost = group['is_host'] == true;
    final canEdit = state == 'open' || (state == 'closing' && isHost);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('Your food',
                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          if (items.isNotEmpty)
            Text(formatCedis((me?['subtotal'] as int?) ?? 0),
                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(canEdit ? "You haven't added anything yet." : 'You didn’t add any food.',
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5))
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${item['quantity']}× ${item['name']}',
                  style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)),
            ),
        if (canEdit) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('group-edit-food'),
              onPressed: busy ? null : onEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.8), width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              icon: Icon(items.isEmpty ? Icons.add_rounded : Icons.edit_rounded, size: 19),
              label: Text(items.isEmpty ? 'Add your food' : 'Change your food'),
            ),
          ),
        ] else if (!isHost && state == 'closing') ...[
          const SizedBox(height: 8),
          Text("Time's up. Ask ${group['host_name']} if you still want to add something.",
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
        ],
      ]),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Map<String, dynamic> person;
  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final items = (person['items'] as List).cast<Map>();
    final name = person['is_me'] == true ? 'You' : '${person['name']}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppTheme.accent.withValues(alpha: 0.25),
          child: Text(name.characters.first.toUpperCase(),
              style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(name, style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
              if (person['is_host'] == true) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Host', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            if (items.isEmpty)
              Text('Still choosing…', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13))
            else
              Text(items.map((i) => '${i['quantity']}× ${i['name']}').join(', '),
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13, height: 1.35)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(formatCedis(person['subtotal'] as int),
            style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Map<String, dynamic> group;
  final bool busy;
  final VoidCallback onCheckout, onReopen;
  const _BottomBar({required this.group, required this.busy, required this.onCheckout, required this.onReopen});

  @override
  Widget build(BuildContext context) {
    final state = group['state'];
    final isHost = group['is_host'] == true;
    Widget body;
    if (isHost && const ['open', 'closing', 'locked'].contains(state)) {
      final empty = (group['dish_count'] as int) == 0;
      body = Column(mainAxisSize: MainAxisSize.min, children: [
        PrimaryButton(
          key: const Key('group-checkout'),
          label: empty
              ? 'Waiting for food'
              : state == 'locked'
                  ? 'Continue to checkout · ${formatCedis(group['total'] as int)}'
                  : 'Check out · ${formatCedis(group['total'] as int)}',
          icon: Icons.shopping_bag_outlined,
          isLoading: busy,
          onPressed: empty || busy ? null : onCheckout,
        ),
        if (state == 'locked')
          TextButton(
            key: const Key('group-reopen'),
            onPressed: busy ? null : onReopen,
            child: const Text('Reopen the basket so people can change their food'),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('You pay for everyone, then settle up with your friends.',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
          ),
      ]);
    } else if (isHost && state == 'placed' && group['order_id'] != null) {
      body = PrimaryButton(
        key: const Key('group-track'),
        label: group['order_status'] == 'awaiting_payment' ? 'Pay for the order' : 'Track the order',
        icon: Icons.delivery_dining_rounded,
        onPressed: () => context.go(group['order_status'] == 'awaiting_payment' ? '/orders' : '/order-tracking/${group['order_id']}'),
      );
    } else {
      final text = switch (state) {
        'open' => '${group['host_name']} checks out and pays when time is up. Settle up with them for your food.',
        'closing' || 'locked' => '${group['host_name']} is checking out for everyone.',
        'placed' => "You'll get updates here as the order moves. Settle up with ${group['host_name']}.",
        _ => 'This group order is closed.',
      };
      body = Text(text,
          key: const Key('group-member-note'),
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5, height: 1.4));
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.sheet(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: SafeArea(top: false, child: body),
    );
  }
}

/// Pick your dishes from the restaurant's menu.
class _MenuPicker extends StatefulWidget {
  final int restaurantId;
  final Map<int, int> initial;
  const _MenuPicker({required this.restaurantId, required this.initial});

  @override
  State<_MenuPicker> createState() => _MenuPickerState();
}

class _MenuPickerState extends State<_MenuPicker> {
  late final Map<int, int> _chosen = Map.of(widget.initial);
  List<MenuItem>? _menu;
  String? _error;

  @override
  void initState() {
    super.initState();
    ApiService.getMenu(widget.restaurantId).then((menu) {
      if (mounted) setState(() => _menu = menu.where((m) => m.isAvailable).toList());
    }).catchError((Object e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    });
  }

  int get _total => _menu == null
      ? 0
      : _menu!.fold(0, (sum, m) => sum + m.price * (_chosen[m.id] ?? 0));

  @override
  Widget build(BuildContext context) {
    final menu = _menu;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Expanded(
                child: Text('Your food',
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Text(formatCedis(_total),
                  style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: menu == null
                ? Center(
                    child: _error != null
                        ? Text(_error!, style: TextStyle(color: AppColors.textSecondary(context)))
                        : const CircularProgressIndicator(color: AppTheme.accent))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: menu.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
                    itemBuilder: (_, i) {
                      final dish = menu[i];
                      final count = _chosen[dish.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(dish.name,
                                  style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
                              Text(dish.displayPrice,
                                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13)),
                            ]),
                          ),
                          IconButton(
                            key: Key('group-dish-minus-${dish.id}'),
                            onPressed: count == 0 ? null : () => setState(() => _chosen[dish.id] = count - 1),
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                          ),
                          SizedBox(
                            width: 24,
                            child: Text('$count',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
                          ),
                          IconButton(
                            key: Key('group-dish-plus-${dish.id}'),
                            onPressed: count >= 20 ? null : () => setState(() => _chosen[dish.id] = count + 1),
                            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.accentDeep),
                          ),
                        ]),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: PrimaryButton(
              key: const Key('group-dishes-done'),
              label: 'Save my food',
              onPressed: menu == null ? null : () => Navigator.of(context).pop(_chosen),
            ),
          ),
        ]),
      ),
    );
  }
}
