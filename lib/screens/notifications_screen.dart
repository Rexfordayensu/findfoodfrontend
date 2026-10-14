import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/notifications_provider.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../widgets/account_settings.dart' show showSettingsMessage;

/// Every notification, read and unread, newest first, grouped by day.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _unreadOnly = false;
  bool _hidePrompt = false;
  List<Map<String, dynamic>> _attention = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().refresh();
      _loadAttention();
    });
  }

  /// Admins also see what needs acting on right now.
  Future<void> _loadAttention() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin || auth.token == null) return;
    try {
      final items = await ApiService.getAdminNotifications(auth.token!);
      if (!mounted) return;
      setState(() => _attention = items
          .where((n) => const {'approval', 'refund', 'overdue', 'releases', 'issues'}
              .contains(n['kind']))
          .toList());
    } catch (_) {}
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<NotificationsProvider>().refresh(),
      _loadAttention(),
    ]);
  }

  void _open(AppNotification note) {
    final notes = context.read<NotificationsProvider>();
    notes.markRead(note);
    final link = note.link;
    if (link == null || !link.startsWith('/')) return;
    // Details open on top; dashboards replace the page.
    if (link.startsWith('/order-tracking/') || link.startsWith('/chat/')) {
      context.push(link);
    } else {
      context.go(link);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotificationsProvider>();
    final textPri = AppColors.textPrimary(context);
    final shown = _unreadOnly ? notes.items.where((n) => !n.read).toList() : notes.items;
    final groups = _groupByDay(shown);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: Text('Notifications',
            style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          TextButton(
            key: const Key('notifications-read-all'),
            onPressed: notes.unread == 0 ? null : notes.markAllRead,
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: _refresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                if (notes.canAskForPush && !_hidePrompt) ...[
                  PushPromptCard(onDismiss: () => setState(() => _hidePrompt = true)),
                  const SizedBox(height: 16),
                ],
                _Filter(
                  unreadOnly: _unreadOnly,
                  unread: notes.unread,
                  onChanged: (value) => setState(() => _unreadOnly = value),
                ),
                if (_attention.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _GroupLabel('Needs attention'),
                  for (final item in _attention) _AttentionTile(item: item),
                ],
                if (!notes.loaded)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                  )
                else if (shown.isEmpty)
                  _Empty(unreadOnly: _unreadOnly)
                else
                  for (final (label, items) in groups) ...[
                    const SizedBox(height: 20),
                    _GroupLabel(label),
                    for (final note in items)
                      _NotificationTile(note: note, onTap: () => _open(note)),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<(String, List<AppNotification>)> _groupByDay(List<AppNotification> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  String label(DateTime when) {
    final day = DateTime(when.year, when.month, when.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'This week';
    return 'Earlier';
  }

  final groups = <(String, List<AppNotification>)>[];
  for (final item in items) {
    final name = label(item.createdAt);
    if (groups.isEmpty || groups.last.$1 != name) groups.add((name, []));
    groups.last.$2.add(item);
  }
  return groups;
}

/// "now", "5 min", "3 h", "Yesterday 14:05", "12 Oct".
String notificationTime(DateTime when, [DateTime? now]) {
  now ??= DateTime.now();
  final diff = now.difference(when);
  String hm() => '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final days = today.difference(day).inDays;
  if (days == 0) return '${diff.inHours} h';
  if (days == 1) return 'Yesterday ${hm()}';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${when.day} ${months[when.month - 1]}';
}

(IconData, Color) notificationStyle(String kind) => switch (kind) {
      'new_order' => (Icons.receipt_long_rounded, AppTheme.accentDeep),
      'order_placed' => (Icons.check_circle_rounded, AppTheme.success),
      'preparing' => (Icons.soup_kitchen_rounded, AppTheme.warning),
      'ready' => (Icons.shopping_bag_rounded, AppTheme.accentDeep),
      'rider_assigned' => (Icons.two_wheeler_rounded, AppTheme.info),
      'rider_changed' => (Icons.swap_horiz_rounded, AppTheme.warning),
      'on_the_way' => (Icons.delivery_dining_rounded, AppTheme.info),
      'delivered' => (Icons.celebration_rounded, AppTheme.success),
      'completed' => (Icons.task_alt_rounded, AppTheme.success),
      'cancelled' => (Icons.cancel_rounded, AppTheme.danger),
      'chat' => (Icons.chat_bubble_rounded, AppTheme.info),
      'new_job' => (Icons.delivery_dining_rounded, AppTheme.accentDeep),
      'issue' => (Icons.report_rounded, AppTheme.danger),
      'issue_resolved' => (Icons.support_agent_rounded, AppTheme.success),
      'refund_failed' || 'refund' => (Icons.error_rounded, AppTheme.danger),
      'approval' => (Icons.storefront_rounded, AppTheme.accentDeep),
      'approved' => (Icons.verified_rounded, AppTheme.success),
      'overdue' => (Icons.timer_off_rounded, AppTheme.danger),
      'releases' => (Icons.assignment_return_rounded, AppTheme.warning),
      'issues' => (Icons.report_rounded, AppTheme.danger),
      _ => (Icons.notifications_rounded, AppTheme.accentDeep),
    };

class _Filter extends StatelessWidget {
  final bool unreadOnly;
  final int unread;
  final ValueChanged<bool> onChanged;
  const _Filter({required this.unreadOnly, required this.unread, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, bool value, Key key) {
      final active = unreadOnly == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          key: key,
          label: Text(label),
          selected: active,
          showCheckmark: false,
          onSelected: (_) => onChanged(value),
          selectedColor: AppTheme.accent,
          backgroundColor: AppColors.card(context),
          side: BorderSide(color: active ? AppTheme.accent : AppColors.border(context)),
          shape: const StadiumBorder(),
          labelStyle: TextStyle(
            color: active ? Colors.black : AppColors.textSecondary(context),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
    }

    return Row(children: [
      chip('All', false, const Key('notifications-all')),
      chip(unread > 0 ? 'Unread · $unread' : 'Unread', true, const Key('notifications-unread')),
    ]);
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                color: AppColors.textHint(context),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8)),
      );
}

class _NotificationTile extends StatelessWidget {
  final AppNotification note;
  final VoidCallback onTap;
  const _NotificationTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = notificationStyle(note.kind);
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final unread = !note.read;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: unread
            ? Color.alphaBlend(AppTheme.accent.withValues(alpha: 0.07), AppColors.card(context))
            : AppColors.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: unread
                  ? AppTheme.accent.withValues(alpha: 0.35)
                  : AppColors.border(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('notification-${note.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text(note.title,
                          style: TextStyle(
                              color: textPri,
                              fontSize: 14.5,
                              height: 1.3,
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Text(notificationTime(note.createdAt),
                        style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
                  ]),
                  if (note.body != null && note.body!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(note.body!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSec, fontSize: 13, height: 1.4)),
                  ],
                ]),
              ),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 6),
                  child: Container(
                    key: const Key('notification-unread-dot'),
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                        color: AppTheme.danger, shape: BoxShape.circle),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _AttentionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = notificationStyle('${item['kind']}');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${item['title'] ?? ''}',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text('${item['detail'] ?? ''}',
                style: TextStyle(
                    color: AppColors.textSecondary(context), fontSize: 13, height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool unreadOnly;
  const _Empty({required this.unreadOnly});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
              unreadOnly ? Icons.done_all_rounded : Icons.notifications_none_rounded,
              color: AppTheme.accentDeep,
              size: 34),
        ),
        const SizedBox(height: 18),
        Text(unreadOnly ? "You're all caught up" : 'No notifications yet',
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        const SizedBox(height: 6),
        Text(
            unreadOnly
                ? 'Nothing new since you last looked.'
                : 'Order updates, messages and alerts will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5)),
      ]),
    );
  }
}

/// "Get alerts even when FindFood is closed", with the right next step for
/// this device (allow, or add to the Home Screen first on iPhone).
class PushPromptCard extends StatefulWidget {
  final VoidCallback? onDismiss;
  const PushPromptCard({super.key, this.onDismiss});

  @override
  State<PushPromptCard> createState() => _PushPromptCardState();
}

class _PushPromptCardState extends State<PushPromptCard> {
  bool _busy = false;

  Future<void> _enable() async {
    final notes = context.read<NotificationsProvider>();
    setState(() => _busy = true);
    final result = await notes.enablePush();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case PushResult.enabled:
        showSettingsMessage(context, "Notifications are on. We'll keep you posted.");
      case PushResult.denied:
        showSettingsMessage(context,
            'Notifications are blocked. Allow them for this site in your browser settings.',
            isError: true);
      case PushResult.unsupported || PushResult.needsHomeScreen:
        showSettingsMessage(context, "This browser can't show notifications.", isError: true);
      case PushResult.failed:
        showSettingsMessage(context, "Couldn't turn on notifications. Try again.",
            isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotificationsProvider>();
    final homeScreen = notes.push.needsHomeScreen;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return Container(
      key: const Key('push-prompt'),
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withValues(alpha: 0.22),
            AppTheme.accentDeep.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.notifications_active_rounded, color: Colors.black, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Never miss an update',
                style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              homeScreen
                  ? 'On iPhone, tap Share, then "Add to Home Screen". Open FindFood from '
                      'there to turn on notifications.'
                  : 'Get order updates and messages even when FindFood is closed.',
              style: TextStyle(color: textSec, fontSize: 13, height: 1.4),
            ),
            if (!homeScreen) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: FilledButton(
                  key: const Key('push-enable'),
                  onPressed: _busy ? null : _enable,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  child: Text(_busy ? 'Turning on…' : 'Turn on notifications'),
                ),
              ),
            ],
          ]),
        ),
        if (widget.onDismiss != null)
          IconButton(
            tooltip: 'Not now',
            visualDensity: VisualDensity.compact,
            onPressed: widget.onDismiss,
            icon: Icon(Icons.close_rounded, size: 18, color: textSec),
          ),
      ]),
    );
  }
}
