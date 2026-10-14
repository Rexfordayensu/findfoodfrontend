import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

/// Reasons that need a photo of what arrived (server rule).
const photoRequiredReasons = {'wrong_item', 'missing_item', 'damaged'};

/// A picked photo: its bytes and file name.
typedef IssuePhoto = ({Uint8List bytes, String name});

/// Picks a photo for a report; replaced in tests.
@visibleForTesting
Future<IssuePhoto?> Function() pickIssuePhoto = () async {
  final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600, maxHeight: 1600);
  if (picked == null) return null;
  return (bytes: await picked.readAsBytes(), name: picked.name);
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
  IssuePhoto? _photo;
  bool _sending = false;

  bool get _needsPhoto => photoRequiredReasons.contains(_reason);
  bool get _takesPhoto => _reason != null && _reason != 'not_delivered';

  Future<void> _pickPhoto() async {
    final photo = await pickIssuePhoto();
    if (photo == null || !mounted) return;
    if (photo.bytes.length > 5 * 1024 * 1024) {
      showSettingsMessage(context, 'That photo is too large. Try a smaller one.', isError: true);
      return;
    }
    setState(() => _photo = photo);
  }

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
    if (_needsPhoto && _photo == null) {
      showSettingsMessage(context, 'Add a photo of what you received.', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final photo = _takesPhoto ? _photo : null;
      final photoUrl = photo == null
          ? null
          : await ApiService.uploadIssuePhoto(
              token: token,
              orderId: widget.order.id,
              imageBytes: photo.bytes,
              filename: photo.name,
            );
      await ApiService.reportOrderIssue(
        token: token,
        orderId: widget.order.id,
        reason: _reason!,
        details: _details.text.trim(),
        photoUrl: photoUrl,
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
        if (_takesPhoto) ...[
          const SizedBox(height: 8),
          _PhotoField(
            photo: _photo,
            required: _needsPhoto,
            onPick: _pickPhoto,
            onRemove: () => setState(() => _photo = null),
          ),
        ],
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('issue-details'),
          controller: _details,
          hint: 'What happened? (optional)',
          prefixIcon: Icons.edit_note_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        const _HonestyNote(),
        const SizedBox(height: 16),
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

class _PhotoField extends StatelessWidget {
  final IssuePhoto? photo;
  final bool required;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PhotoField({
    required this.photo,
    required this.required,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final picked = photo;
    if (picked != null) {
      return Container(
        key: const Key('issue-photo-preview'),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(picked.bytes, width: 64, height: 64, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(width: 64, height: 64)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Photo added',
                  style: TextStyle(color: textPri, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(picked.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textSec, fontSize: 12)),
            ]),
          ),
          TextButton(onPressed: onPick, child: const Text('Change')),
          IconButton(
            tooltip: 'Remove photo',
            onPressed: onRemove,
            icon: Icon(Icons.close_rounded, color: textSec, size: 20),
          ),
        ]),
      );
    }
    return Material(
      color: AppTheme.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const Key('issue-add-photo'),
        borderRadius: BorderRadius.circular(14),
        onTap: onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accentDeep.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.accentDeep, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Add a photo of what arrived',
                    style: TextStyle(color: textPri, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                    required
                        ? 'Needed for this report. Show the food and the packaging.'
                        : 'Optional, but it helps us sort it out faster.',
                    style: TextStyle(color: textSec, fontSize: 12, height: 1.35)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HonestyNote extends StatelessWidget {
  const _HonestyNote();

  @override
  Widget build(BuildContext context) {
    final textSec = AppColors.textSecondary(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.verified_user_outlined, size: 16, color: textSec),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'We check every report with the restaurant, the rider and the delivery code. '
          'False reports can get an account suspended.',
          style: TextStyle(color: textSec, fontSize: 12, height: 1.4),
        ),
      ),
    ]);
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
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          _RiskChip(risk: (issue['customer'] as Map?)?['risk'] as String?),
          const Icon(Icons.chevron_right_rounded),
        ]),
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
  final _refundItems = <int>{};
  String? _busy;

  List<Map> get _items =>
      (widget.issue['items'] as List? ?? const []).whereType<Map>().toList();

  int? get _total => widget.issue['order_total'] as int?;

  int _lineTotal(Map line) =>
      ((line['price'] as num?) ?? 0).toInt() * ((line['quantity'] as num?) ?? 1).toInt();

  /// Pesewas for the ticked items, or null to refund the whole order.
  int? get _partialAmount {
    if (_refundItems.isEmpty) return null;
    final amount = _refundItems.fold<int>(0, (sum, i) => sum + _lineTotal(_items[i]));
    final total = _total;
    if (amount <= 0 || (total != null && amount >= total)) return null;
    return amount;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _resolve(String action) async {
    setState(() => _busy = action);
    try {
      final amount = action == 'refund' ? _partialAmount : null;
      await ApiService.resolveIssue(
        token: context.read<AuthProvider>().token!,
        issueId: widget.issue['id'] as int,
        action: action,
        note: _note.text.trim(),
        amount: amount,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSettingsMessage(
          context,
          action == 'dismiss'
              ? 'Report dismissed.'
              : amount == null
                  ? 'Refund started for the whole order.'
                  : 'Refund of ${formatCedis(amount)} started.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _viewPhoto(String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(children: [
          InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final total = _total;
    final photoUrl = issue['photo_url'] as String?;
    final customer = issue['customer'] as Map?;
    final evidence = issue['evidence'] as Map?;
    final partial = _partialAmount;
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
        if ((issue['details'] as String?)?.isNotEmpty ?? false) ...[
          Text('“${issue['details']}”',
              style: TextStyle(color: textPri, fontSize: 14, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
        ],
        if (photoUrl != null) ...[
          GestureDetector(
            key: const Key('issue-photo'),
            onTap: () => _viewPhoto(photoUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                photoUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  alignment: Alignment.center,
                  color: AppColors.surface(context),
                  child: Text("Couldn't load the photo",
                      style: TextStyle(color: textSec, fontSize: 13)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (photoRequiredReasons.contains(issue['reason'])) ...[
          Text('No photo was attached.', style: TextStyle(color: textSec, fontSize: 13)),
          const SizedBox(height: 12),
        ],
        if (customer != null) ...[
          _TrustCard(customer: customer),
          const SizedBox(height: 10),
        ],
        if (evidence != null && evidence.isNotEmpty) ...[
          _EvidenceCard(evidence: evidence),
          const SizedBox(height: 16),
        ],
        if (_items.isNotEmpty) ...[
          Text('What to refund',
              style: TextStyle(color: textPri, fontWeight: FontWeight.w700, fontSize: 14)),
          Text('Tick only what went wrong, or leave all unticked to refund the whole order.',
              style: TextStyle(color: textSec, fontSize: 12, height: 1.35)),
          const SizedBox(height: 4),
          for (var i = 0; i < _items.length; i++)
            CheckboxListTile(
              key: Key('refund-item-$i'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _refundItems.contains(i),
              onChanged: _busy != null
                  ? null
                  : (checked) => setState(() =>
                      checked == true ? _refundItems.add(i) : _refundItems.remove(i)),
              title: Text('${_items[i]['quantity']}× ${_items[i]['name']}',
                  style: TextStyle(color: textPri, fontSize: 14)),
              secondary: _items[i]['price'] == null
                  ? null
                  : Text(formatCedis(_lineTotal(_items[i])),
                      style: TextStyle(color: textSec, fontSize: 13)),
            ),
          const SizedBox(height: 8),
        ],
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
          label: partial != null
              ? 'Refund ${formatCedis(partial)}'
              : 'Refund whole order${total == null ? '' : ' (${formatCedis(total)})'}',
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

class _RiskChip extends StatelessWidget {
  final String? risk;
  const _RiskChip({required this.risk});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (risk) {
      'high' => ('High risk', AppTheme.danger),
      'new' => ('New customer', AppTheme.warning),
      'normal' => ('Good standing', AppTheme.success),
      _ => (null, AppTheme.info),
    };
    if (label == null) return const SizedBox.shrink();
    return Container(
      key: Key('risk-$risk'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _InfoCard({super.key, required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 6),
        ...children,
      ]),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _Fact(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: tint),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: color ?? AppColors.textSecondary(context), fontSize: 12.5, height: 1.35)),
        ),
      ]),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final Map customer;
  const _TrustCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final days = customer['account_days'] as int?;
    final completed = customer['completed_orders'] ?? 0;
    final reports = customer['reports_90d'] ?? 0;
    final refunds = customer['refunds_90d'] ?? 0;
    final refunded = (customer['refunded_amount_90d'] as num?)?.toInt() ?? 0;
    return _InfoCard(
      key: const Key('issue-trust'),
      title: 'Customer track record',
      trailing: _RiskChip(risk: customer['risk'] as String?),
      children: [
        _Fact(Icons.person_outline_rounded,
            days == null ? 'Account age unknown' : 'Account ${_age(days)} old'),
        _Fact(Icons.receipt_long_outlined,
            '$completed completed order${completed == 1 ? '' : 's'}'),
        _Fact(
          Icons.flag_outlined,
          '$reports report${reports == 1 ? '' : 's'} and $refunds refund${refunds == 1 ? '' : 's'} '
          'in the last 90 days${refunded > 0 ? ' (${formatCedis(refunded)} refunded)' : ''}',
          color: customer['risk'] == 'high' ? AppTheme.danger : null,
        ),
      ],
    );
  }

  static String _age(int days) {
    if (days < 1) return 'less than a day';
    if (days < 60) return '$days day${days == 1 ? '' : 's'}';
    return '${days ~/ 30} months';
  }
}

class _EvidenceCard extends StatelessWidget {
  final Map evidence;
  const _EvidenceCard({required this.evidence});

  @override
  Widget build(BuildContext context) {
    String? time(String key) {
      final value = DateTime.tryParse('${evidence[key]}')?.toLocal();
      if (value == null) return null;
      return '${value.day}/${value.month} ${value.hour.toString().padLeft(2, '0')}:'
          '${value.minute.toString().padLeft(2, '0')}';
    }

    final collected = time('collected_at');
    final completed = time('completed_at');
    final confirmed = evidence['customer_confirmed_with_code'] == true;
    return _InfoCard(
      key: const Key('issue-evidence'),
      title: 'Handover evidence',
      children: [
        if (collected != null)
          _Fact(Icons.storefront_outlined, 'Rider collected it with the pickup code at $collected'),
        if (completed != null)
          _Fact(Icons.home_outlined, 'Delivered at $completed'),
        _Fact(
          confirmed ? Icons.verified_rounded : Icons.help_outline_rounded,
          confirmed
              ? 'The customer gave the rider their delivery code'
              : 'Not confirmed with the customer\'s delivery code',
          color: confirmed ? AppTheme.success : AppTheme.warning,
        ),
      ],
    );
  }
}
