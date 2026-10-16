import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart' show formatCedis;
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import '../../widgets/widgets.dart';

/// What each admin role is for, in plain words.
const adminRoleInfo = {
  'owner': (
    label: 'Owner',
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFFF59E0B),
    summary: 'Everything, including commission, delivery fees, the team and the activity log.',
  ),
  'support': (
    label: 'Support',
    icon: Icons.support_agent_rounded,
    color: Color(0xFF3B82F6),
    summary: 'Orders, refunds (up to a limit), problem reports, the support inbox, reviews, suspending users.',
  ),
  'operations': (
    label: 'Operations',
    icon: Icons.tune_rounded,
    color: Color(0xFF8B5CF6),
    summary: 'Approving restaurants and riders, orders, announcements, promo codes, pausing the platform.',
  ),
  'finance': (
    label: 'Finance',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF22C55E),
    summary: 'Payments, refunds, exports for the accountant, and paying riders.',
  ),
};

String _ago(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${months[at.month - 1]}';
}

class _PageTitle extends StatelessWidget {
  final String title, subtitle;
  final Widget? action;
  const _PageTitle(this.title, this.subtitle, {this.action});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: AppColors.textPrimary(context), fontSize: 28,
                  fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5, height: 1.4)),
        ]),
      ),
      if (action != null) ...[const SizedBox(width: 12), action!],
    ]);
  }
}

// ── Team ─────────────────────────────────────────────────────────────────────

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getAdminTeam(context.read<AuthProvider>().token!);
      if (mounted) {
        setState(() {
          _data = data;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _invite() async {
    final member = await showSettingsSheet<Map<String, dynamic>>(context, const _InviteForm());
    if (member != null) await _load();
  }

  Future<void> _manage(Map<String, dynamic> member) async {
    final action = await showSettingsSheet<String>(context, _MemberActions(member: member));
    if (action == null || !mounted) return;
    final token = context.read<AuthProvider>().token!;
    try {
      if (action == 'remove') {
        final sure = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Remove ${member['name']}?'),
            content: const Text('They lose admin access straight away and are signed out. '
                'You can invite them again later.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              FilledButton(
                key: const Key('team-remove-confirm'),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        if (sure != true) return;
        await ApiService.removeAdmin(token, member['id'] as int);
        if (mounted) showSettingsMessage(context, '${member['name']} no longer has admin access.');
      } else {
        await ApiService.changeAdminRole(token, member['id'] as int, action);
        if (mounted) {
          showSettingsMessage(context, '${member['name']} is now ${adminRoleInfo[action]!.label}.');
        }
      }
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final me = context.read<AuthProvider>().userId;
    final members = ((data?['members'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final active = members.where((m) => m['is_active'] == true).toList();
    final removed = members.where((m) => m['is_active'] != true).toList();
    final textSec = AppColors.textSecondary(context);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _PageTitle(
            'Team',
            'Invite people to help run FindFood. Each role only sees what it needs, '
                'and everything they do is in the activity log.',
            action: FilledButton.icon(
              key: const Key('team-invite'),
              onPressed: data == null ? null : _invite,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Invite'),
            ),
          ),
          const SizedBox(height: 18),
          if (_error != null && data == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load the team",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (data == null)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
            )
          else ...[
            for (final m in active) _MemberTile(member: m, isMe: m['id'] == me, onTap: () => _manage(m)),
            if (removed.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Removed', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final m in removed) _MemberTile(member: m, isMe: false, onTap: null),
            ],
            const SizedBox(height: 22),
            Text('What each role can do',
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final entry in adminRoleInfo.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(entry.value.icon, size: 20, color: entry.value.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '${entry.value.label}: ',
                          style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
                      TextSpan(text: entry.key == 'support'
                          ? entry.value.summary.replaceFirst('up to a limit',
                              'up to ${formatCedis((data['support_refund_limit'] as num?)?.toInt() ?? 20000)}')
                          : entry.value.summary),
                    ]), style: TextStyle(color: textSec, fontSize: 13, height: 1.4)),
                  ),
                ]),
              ),
          ],
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isMe;
  final VoidCallback? onTap;
  const _MemberTile({required this.member, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = adminRoleInfo[member['admin_role']] ?? adminRoleInfo['owner']!;
    final name = '${member['name']}';
    final removed = member['is_active'] != true;
    final textSec = AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.border(context))),
        child: InkWell(
          key: Key('team-member-${member['id']}'),
          borderRadius: BorderRadius.circular(14),
          onTap: isMe || removed ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: info.color.withValues(alpha: 0.16),
                child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: TextStyle(color: info.color, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isMe ? '$name (you)' : name,
                      style: TextStyle(
                          color: removed ? textSec : AppColors.textPrimary(context),
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('${member['email']}', style: TextStyle(color: textSec, fontSize: 12.5)),
                  if (member['invited'] == true && !removed)
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text('Invited · hasn\'t set a password yet',
                          style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (removed ? AppColors.border(context) : info.color).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(info.icon, size: 14, color: removed ? textSec : info.color),
                  const SizedBox(width: 4),
                  Text(removed ? 'Removed' : info.label,
                      style: TextStyle(
                          color: removed ? textSec : info.color, fontSize: 12, fontWeight: FontWeight.w800)),
                ]),
              ),
              if (!isMe && !removed) ...[
                const SizedBox(width: 4),
                Icon(Icons.more_vert_rounded, color: textSec, size: 20),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _RolePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final entry in adminRoleInfo.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: selected == entry.key ? entry.value.color.withValues(alpha: 0.10) : AppColors.surface(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: selected == entry.key ? entry.value.color : AppColors.border(context),
                  width: selected == entry.key ? 1.6 : 1),
            ),
            child: InkWell(
              key: Key('role-${entry.key}'),
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(entry.key),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(entry.value.icon, color: entry.value.color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(entry.value.label,
                          style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(entry.value.summary,
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, height: 1.35)),
                    ]),
                  ),
                  if (selected == entry.key)
                    Icon(Icons.check_circle_rounded, color: entry.value.color, size: 20),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _InviteForm extends StatefulWidget {
  const _InviteForm();

  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  String _role = 'support';
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final name = _name.text.trim(), email = _email.text.trim();
    if (name.isEmpty || !email.contains('@')) {
      showSettingsMessage(context, 'Enter their name and email address.', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      final member = await ApiService.inviteAdmin(context.read<AuthProvider>().token!,
          name: name, email: email, role: _role);
      if (!mounted) return;
      Navigator.of(context).pop(member);
      showSettingsMessage(context, 'Invitation sent to $email.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader(
          title: 'Invite an admin',
          subtitle: "They'll get an email to set a password. Use an email that isn't already on FindFood.",
        ),
        AppTextField(key: const Key('invite-name'), controller: _name, hint: 'Their name',
            prefixIcon: Icons.person_outline_rounded),
        const SizedBox(height: 10),
        AppTextField(key: const Key('invite-email'), controller: _email, hint: 'Email address',
            prefixIcon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        Text('Role', style: TextStyle(color: AppColors.textSecondary(context), fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _RolePicker(selected: _role, onChanged: (r) => setState(() => _role = r)),
        const SizedBox(height: 8),
        PrimaryButton(key: const Key('invite-send'), label: 'Send invitation', isLoading: _sending,
            onPressed: _sending ? null : _send),
      ],
    );
  }
}

class _MemberActions extends StatefulWidget {
  final Map<String, dynamic> member;
  const _MemberActions({required this.member});

  @override
  State<_MemberActions> createState() => _MemberActionsState();
}

class _MemberActionsState extends State<_MemberActions> {
  late String _role = '${widget.member['admin_role']}';

  @override
  Widget build(BuildContext context) {
    final changed = _role != widget.member['admin_role'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(title: '${widget.member['name']}', subtitle: '${widget.member['email']}'),
        _RolePicker(selected: _role, onChanged: (r) => setState(() => _role = r)),
        const SizedBox(height: 8),
        PrimaryButton(
          key: const Key('team-save-role'),
          label: changed ? 'Make ${adminRoleInfo[_role]!.label}' : 'No changes',
          onPressed: changed ? () => Navigator.of(context).pop(_role) : null,
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            key: const Key('team-remove'),
            onPressed: () => Navigator.of(context).pop('remove'),
            icon: const Icon(Icons.person_remove_alt_1_outlined, color: AppTheme.danger, size: 18),
            label: const Text('Remove admin access', style: TextStyle(color: AppTheme.danger)),
          ),
        ),
      ],
    );
  }
}

// ── Activity log ─────────────────────────────────────────────────────────────

IconData _actionIcon(String action) {
  final kind = action.split('.').first;
  return switch (kind) {
    'team' => Icons.group_rounded,
    'restaurant' => Icons.storefront_rounded,
    'user' => Icons.person_rounded,
    'commission' => Icons.percent_rounded,
    'delivery' => Icons.delivery_dining_rounded,
    'payout' => Icons.payments_rounded,
    'report' => Icons.report_rounded,
    'order' => Icons.receipt_long_rounded,
    'rider' => Icons.electric_bike_rounded,
    'promo' => Icons.local_offer_rounded,
    'announcement' => Icons.campaign_rounded,
    'platform' => Icons.toggle_on_rounded,
    'review' => Icons.star_rounded,
    'support' => Icons.support_agent_rounded,
    _ => Icons.history_rounded,
  };
}

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final _entries = <Map<String, dynamic>>[];
  bool _loading = true, _more = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    setState(() => _loading = true);
    try {
      final page = await ApiService.getAuditLog(context.read<AuthProvider>().token!,
          beforeId: reset || _entries.isEmpty ? null : _entries.last['id'] as int);
      if (!mounted) return;
      setState(() {
        if (reset) _entries.clear();
        _entries.addAll(page);
        _more = page.length == 50;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSec = AppColors.textSecondary(context);
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const _PageTitle('Activity log',
              'Every change made by an admin: who did it, and when. It can’t be edited or deleted.'),
          const SizedBox(height: 18),
          if (_error != null && _entries.isEmpty)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load the log",
                subtitle: _error!, actionLabel: 'Retry', onAction: () => _load(reset: true))
          else if (_entries.isEmpty && !_loading)
            const EmptyState(icon: Icons.history_rounded, title: 'Nothing yet',
                subtitle: 'Admin changes will appear here.')
          else
            for (final e in _entries)
              Padding(
                key: Key('audit-${e['id']}'),
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.14), shape: BoxShape.circle),
                    child: Icon(_actionIcon('${e['action']}'), size: 17, color: AppColors.accentText(context)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${e['summary']}',
                          style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14, height: 1.35)),
                      const SizedBox(height: 2),
                      Text(
                          '${e['admin_name'] ?? 'A removed admin'}'
                          '${e['admin_role'] != null ? ' (${adminRoleInfo[e['admin_role']]?.label ?? e['admin_role']})' : ''}'
                          ' · ${_ago(e['created_at'])}',
                          style: TextStyle(color: textSec, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
            )
          else if (_more && _entries.isNotEmpty)
            Center(
              child: TextButton(
                key: const Key('audit-more'),
                onPressed: _load,
                child: const Text('Show older'),
              ),
            ),
        ],
      ),
    );
  }
}
