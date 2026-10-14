import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import 'live_refresh.dart';
import 'widgets.dart';

/// Reasons a customer can give, matching the server's app/issues.py.
const issueReasons = {
  'wrong_item': 'Wrong item',
  'missing_item': 'Missing item',
  'damaged': 'Damaged or spilled',
  'other': 'Something else',
};

/// Problems can be reported up to this long after delivery (server rule).
const reportWindow = Duration(hours: 48);

/// After this long on the way, a customer may report "Never arrived".
const notDeliveredAfter = Duration(minutes: 60);

/// Which reasons this order can be reported for right now (empty: none).
Map<String, String> reportableReasons(Order order, DateTime now) {
  if (order.issueStatus == 'open') return const {};
  final collected = order.collectedAt;
  if (order.status == 'out_for_delivery' &&
      collected != null &&
      now.difference(collected) >= notDeliveredAfter) {
    return const {'not_delivered': 'Never arrived'};
  }
  final completed = order.completedAt;
  if (order.isCompleted &&
      completed != null &&
      now.difference(completed) <= reportWindow &&
      order.issueStatus == null) {
    return issueReasons;
  }
  return const {};
}

/// Lets the customer report a problem. Resolves to true when sent.
Future<bool> showReportProblemSheet(BuildContext context, Order order) async {
  final reasons = reportableReasons(order, DateTime.now());
  if (reasons.isEmpty) return false;
  final sent = await showSettingsSheet<bool>(
      context, _ReportForm(order: order, reasons: reasons));
  return sent ?? false;
}

class _ReportForm extends StatefulWidget {
  final Order order;
  final Map<String, String> reasons;
  const _ReportForm({required this.order, required this.reasons});

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  late String? _reason =
      widget.reasons.length == 1 ? widget.reasons.keys.single : null;
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_reason == null) {
      showSettingsMessage(context, 'Choose what went wrong.', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      await ApiService.reportOrderIssue(
        token: context.read<AuthProvider>().token!,
        orderId: widget.order.id,
        reason: _reason!,
        details: _details.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSettingsMessage(context,
          "Thanks for telling us. We'll review it and refund you if something went wrong.");
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
        SheetHeader(
          title: 'Report a problem',
          subtitle: 'Order #${widget.order.id}'
              '${widget.order.restaurantName == null ? '' : ' · ${widget.order.restaurantName}'}',
        ),
        RadioGroup<String>(
          groupValue: _reason,
          onChanged: (value) => setState(() => _reason = value),
          child: Column(children: [
            for (final entry in widget.reasons.entries)
              RadioListTile<String>(
                key: Key('issue-reason-${entry.key}'),
                contentPadding: EdgeInsets.zero,
                value: entry.key,
                title: Text(entry.value),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        AppTextField(
          key: const Key('issue-details'),
          controller: _details,
          hint: 'What happened? (optional)',
          prefixIcon: Icons.edit_note_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          key: const Key('issue-submit'),
          label: 'Send report',
          isLoading: _sending,
          onPressed: _sending ? null : _send,
        ),
      ],
    );
  }
}

/// Shows where a reported problem stands, on the order's tracking screen.
class IssueStatusCard extends StatelessWidget {
  final String status; // open / refunded / dismissed
  final String? note;

  const IssueStatusCard({super.key, required this.status, this.note});

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, body) = switch (status) {
      'refunded' => (
          Icons.check_circle_rounded,
          AppTheme.success,
          'Refunded',
          'We refunded this order. It can take a few days to show on your statement.',
        ),
      'dismissed' => (
          Icons.info_outline_rounded,
          AppColors.textSecondary(context),
          'Report closed',
          "We looked into it and couldn't confirm a problem with this order.",
        ),
      _ => (
          Icons.support_agent_rounded,
          AppTheme.accentDeep,
          'Problem reported',
          "We're reviewing it and will refund you if something went wrong.",
        ),
    };
    return Container(
      key: const Key('issue-status-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(body,
                style: TextStyle(
                    color: AppColors.textSecondary(context), fontSize: 13, height: 1.4)),
            if (note != null && note!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('“${note!.trim()}”',
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
            ],
          ]),
        ),
      ]),
    );
  }
}

// ── Admin ───────────────────────────────────────────────────────────────────

/// Open problem reports on the admin overview, refreshed live.
class AdminIssuesPanel extends StatefulWidget {
  const AdminIssuesPanel({super.key});

  @override
  State<AdminIssuesPanel> createState() => _AdminIssuesPanelState();
}

class _AdminIssuesPanelState extends State<AdminIssuesPanel>
    with LiveRefresh<AdminIssuesPanel> {
  List<Map<String, dynamic>> _issues = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(_load);
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final issues = await ApiService.getAdminIssues(token);
      if (mounted) setState(() { _issues = issues; _loaded = true; });
    } catch (_) {
      // Keep the last list; the overview still works without it.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _issues.isEmpty) return const SizedBox.shrink();
    final textPri = AppColors.textPrimary(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        key: const Key('admin-issues'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Problem reports',
                style: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${_issues.length}',
                  style: const TextStyle(
                      color: AppTheme.danger, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 12),
          for (final issue in _issues) ...[
            _IssueTile(
              issue: issue,
              onResolved: _load,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  final Map<String, dynamic> issue;
  final Future<void> Function() onResolved;
  const _IssueTile({required this.issue, required this.onResolved});

  @override
  Widget build(BuildContext context) {
    final created = DateTime.tryParse('${issue['created_at']}')?.toLocal();
    return Material(
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: Key('admin-issue-${issue['id']}'),
        leading: const Icon(Icons.report_gmailerrorred_rounded, color: AppTheme.danger),
        title: Text('Order #${issue['order_id']} · ${issue['reason_label']}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          [
            if (issue['customer_name'] != null) issue['customer_name'],
            if (issue['restaurant_name'] != null) issue['restaurant_name'],
            if (created != null)
              '${created.day}/${created.month} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final resolved = await showSettingsSheet<bool>(
              context, _ResolveForm(issue: issue));
          if (resolved == true) await onResolved();
        },
      ),
    );
  }
}

class _ResolveForm extends StatefulWidget {
  final Map<String, dynamic> issue;
  const _ResolveForm({required this.issue});

  @override
  State<_ResolveForm> createState() => _ResolveFormState();
}

class _ResolveFormState extends State<_ResolveForm> {
  final _note = TextEditingController();
  String? _busy;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _resolve(String action) async {
    setState(() => _busy = action);
    try {
      await ApiService.resolveIssue(
        token: context.read<AuthProvider>().token!,
        issueId: widget.issue['id'] as int,
        action: action,
        note: _note.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSettingsMessage(context,
          action == 'refund' ? 'Refund started for the customer.' : 'Report dismissed.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final textSec = AppColors.textSecondary(context);
    final items = (issue['items'] as List? ?? const [])
        .map((line) => '${line['quantity']}× ${line['name']}')
        .join(', ');
    final total = issue['order_total'] is int ? formatCedis(issue['order_total'] as int) : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: 'Order #${issue['order_id']} · ${issue['reason_label']}',
          subtitle: [
            if (issue['customer_name'] != null) 'Customer: ${issue['customer_name']}',
            if (issue['restaurant_name'] != null) issue['restaurant_name'],
            if (issue['rider_name'] != null) 'Rider: ${issue['rider_name']}',
          ].join(' · '),
        ),
        if (items.isNotEmpty)
          Text('Ordered: $items${total == null ? '' : ' ($total)'}',
              style: TextStyle(color: textSec, fontSize: 13)),
        if ((issue['details'] as String?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          Text('“${issue['details']}”',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 14,
                  fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 16),
        AppTextField(
          key: const Key('issue-note'),
          controller: _note,
          hint: 'Note for the customer (optional)',
          prefixIcon: Icons.chat_bubble_outline_rounded,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const Key('issue-refund'),
          label: 'Refund customer${total == null ? '' : ' ($total)'}',
          isLoading: _busy == 'refund',
          onPressed: _busy == null ? () => _resolve('refund') : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            key: const Key('issue-dismiss'),
            onPressed: _busy == null ? () => _resolve('dismiss') : null,
            child: const Text('Dismiss report'),
          ),
        ),
      ],
    );
  }
}
