import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart'
    show SheetHeader, showSettingsSheet, showSettingsMessage;
import 'widgets.dart';

// ── Customer: check the food before giving the code ──────────────────────────

/// When the food reaches the customer: tick each item (and the seal), then
/// the delivery code appears. Giving the code means everything was there.
class DoorstepCheckCard extends StatefulWidget {
  final Order order;
  final ValueChanged<Order> onChecked;
  const DoorstepCheckCard(
      {super.key, required this.order, required this.onChecked});

  @override
  State<DoorstepCheckCard> createState() => _DoorstepCheckCardState();
}

class _DoorstepCheckCardState extends State<DoorstepCheckCard> {
  final _ticked = <int>{};
  bool _seal = false;
  bool _busy = false;

  Order get _order => widget.order;
  bool get _hasSeal => _order.sealed == true;
  bool get _allTicked =>
      _ticked.length == _order.items.length && (!_hasSeal || _seal);

  Future<void> _submit(bool allThere) async {
    setState(() => _busy = true);
    try {
      final updated = await ApiService.doorstepCheck(
          context.read<AuthProvider>().token!, _order.id, allThere);
      if (mounted) widget.onChecked(updated);
    } catch (e) {
      if (mounted) {
        showSettingsMessage(context, friendlyMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _somethingWrong() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Something not right?'),
        content: Text(
          _order.fulfillmentMethod == 'pickup'
              ? "Tell the counter now. We'll note that you flagged it at collection, "
                  'then you can report it with a photo.'
              : "We'll note that you flagged it at the door. Take your food, give the "
                  'rider the code, then report it here with a photo straight away.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Go back')),
          FilledButton(
              key: const Key('doorstep-problem-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Flag it')),
        ],
      ),
    );
    if (sure == true) await _submit(false);
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final pickup = _order.fulfillmentMethod == 'pickup';
    Widget tick(
        {required Key key,
        required bool value,
        required ValueChanged<bool> onChanged,
        required Widget title}) {
      return CheckboxListTile(
        key: key,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppTheme.success,
        value: value,
        onChanged: _busy ? null : (v) => onChanged(v ?? false),
        title: title,
      );
    }

    return Material(
      key: const Key('doorstep-check'),
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: AppTheme.accent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fact_check_rounded,
                  color: AppTheme.accentDeep, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        pickup
                            ? 'Check your food at the counter'
                            : 'Food here? Check it first',
                        style: TextStyle(
                            color: textPri,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                        'Tick what you have. Your code appears once everything is there.',
                        style: TextStyle(
                            color: textSec, fontSize: 12.5, height: 1.35)),
                  ]),
            ),
          ]),
          if (_order.packedPhotoUrl != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(_order.packedPhotoUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 56, height: 56)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'How ${_order.restaurantName ?? 'the restaurant'} packed it',
                    style: TextStyle(color: textSec, fontSize: 12.5)),
              ),
            ]),
          ],
          const SizedBox(height: 6),
          for (var i = 0; i < _order.items.length; i++)
            tick(
              key: Key('doorstep-item-$i'),
              value: _ticked.contains(i),
              onChanged: (v) =>
                  setState(() => v ? _ticked.add(i) : _ticked.remove(i)),
              title: Text(
                  '${_order.items[i].quantity}× ${_order.items[i].name ?? 'Item'}',
                  style: TextStyle(color: textPri, fontSize: 14)),
            ),
          if (_hasSeal)
            tick(
              key: const Key('doorstep-seal'),
              value: _seal,
              onChanged: (v) => setState(() => _seal = v),
              title: Text('The seal or tape is unbroken',
                  style: TextStyle(color: textPri, fontSize: 14)),
            ),
          const SizedBox(height: 10),
          PrimaryButton(
            key: const Key('doorstep-all-there'),
            label: "Everything's here · show my code",
            isLoading: _busy,
            onPressed: _busy || !_allTicked ? null : () => _submit(true),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('doorstep-problem'),
              onPressed: _busy ? null : _somethingWrong,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                backgroundColor: AppTheme.danger.withValues(alpha: 0.05),
                side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.55), width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              icon: const Icon(Icons.report_gmailerrorred_rounded, size: 20),
              label: const Text("Something's missing or wrong"),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Before the food arrives: where the code will come from.
class CodeComingCard extends StatelessWidget {
  final bool pickup;
  const CodeComingCard({super.key, required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('code-coming'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(children: [
        Icon(Icons.lock_clock_rounded,
            color: AppColors.textSecondary(context), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            pickup
                ? 'Your collection code appears when your food is being prepared. '
                    "You'll check your food at the counter first."
                : "Your delivery code appears when your rider is on the way. You'll "
                    'check your food at the door before giving it.',
            style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
                height: 1.4),
          ),
        ),
      ]),
    );
  }
}

// ── Restaurant: pack it up (photo and seal) ──────────────────────────────────

/// A picked photo; replaced in tests.
@visibleForTesting
Future<({Uint8List bytes, String name})?> Function() pickPackPhoto = () async {
  final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600);
  if (picked == null) return null;
  return (bytes: await picked.readAsBytes(), name: picked.name);
};

/// Before "Mark ready": a photo of the packed food and whether it's sealed.
/// Resolves to whether it was sealed, or null if the kitchen backed out.
Future<bool?> showPackSheet(BuildContext context, Order order) =>
    showSettingsSheet<bool>(context, _PackForm(order: order));

class _PackForm extends StatefulWidget {
  final Order order;
  const _PackForm({required this.order});

  @override
  State<_PackForm> createState() => _PackFormState();
}

class _PackFormState extends State<_PackForm> {
  bool _sealed = true;
  bool _uploading = false;
  Uint8List? _preview;

  Future<void> _takePhoto() async {
    final photo = await pickPackPhoto();
    if (photo == null || !mounted) return;
    setState(() {
      _uploading = true;
      _preview = photo.bytes;
    });
    try {
      await ApiService.uploadPackPhoto(
        token: context.read<AuthProvider>().token!,
        orderId: widget.order.id,
        imageBytes: photo.bytes,
        filename: photo.name,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _preview = null);
        showSettingsMessage(context, friendlyMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final items = widget.order.items;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(title: 'Pack it up', subtitle: 'Order #${widget.order.id}'),
        if (items.isNotEmpty)
          Text(
              items
                  .map((l) => '${l.quantity}× ${l.name ?? 'Item'}')
                  .join(' · '),
              style: TextStyle(
                  color: textPri, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _preview != null
                    ? Image.memory(_preview!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(width: 64, height: 64))
                    : Container(
                        width: 64,
                        height: 64,
                        color: AppTheme.accent.withValues(alpha: 0.18),
                        child: const Icon(Icons.add_a_photo_rounded,
                            color: AppTheme.accentDeep, size: 28),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (_preview != null && !_uploading) ...[
                          const Icon(Icons.check_circle_rounded,
                              color: AppTheme.success, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                              _uploading
                                  ? 'Uploading…'
                                  : _preview != null
                                      ? 'Photo added'
                                      : 'Photo of the packed food',
                              style: TextStyle(
                                  color: textPri,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      Text(
                          'Recommended: it proves what you packed if a customer says something was missing.',
                          style: TextStyle(
                              color: textSec, fontSize: 12, height: 1.35)),
                    ]),
              ),
            ]),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('pack-photo'),
              onPressed: _uploading ? null : _takePhoto,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentText(context),
                backgroundColor: AppTheme.accent.withValues(alpha: 0.10),
                side: const BorderSide(color: AppTheme.accentDeep, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              icon: Icon(_preview != null ? Icons.refresh_rounded : Icons.photo_camera_rounded, size: 20),
              label: Text(_uploading
                  ? 'Uploading…'
                  : _preview != null
                      ? 'Retake photo'
                      : 'Take a photo'),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        CheckboxListTile(
          key: const Key('pack-sealed'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppTheme.success,
          value: _sealed,
          onChanged: (v) => setState(() => _sealed = v ?? false),
          title: Text('Sealed with tape or a sticker',
              style: TextStyle(
                  color: textPri, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(
              'The customer checks the seal before giving their code.',
              style: TextStyle(color: textSec, fontSize: 12)),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          key: const Key('pack-ready'),
          label: 'Mark ready',
          onPressed:
              _uploading ? null : () => Navigator.of(context).pop(_sealed),
        ),
      ],
    );
  }
}

// ── Restaurant: answer problem reports ───────────────────────────────────────

/// "1 report to answer" above the restaurant's orders; opens the reports.
class RestaurantIssuesBanner extends StatefulWidget {
  /// Bumped by the dashboard's refresh so the banner reloads with it.
  final int refreshTick;
  const RestaurantIssuesBanner({super.key, this.refreshTick = 0});

  @override
  State<RestaurantIssuesBanner> createState() => _RestaurantIssuesBannerState();
}

class _RestaurantIssuesBannerState extends State<RestaurantIssuesBanner> {
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RestaurantIssuesBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final reports = await ApiService.getRestaurantIssues(token);
      if (mounted) setState(() => _reports = reports);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final waiting =
        _reports.where((r) => r['restaurant_response'] == null).length;
    if (_reports.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Material(
        color: AppTheme.danger.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('restaurant-issues'),
          onTap: () => context.go('/restaurant/reports'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              const Icon(Icons.report_rounded,
                  color: AppTheme.danger, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  waiting > 0
                      ? '$waiting problem report${waiting == 1 ? '' : 's'} to answer'
                      : 'Problem reports: waiting for FindFood',
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ReportAnswer extends StatefulWidget {
  final Map<String, dynamic> report;
  const _ReportAnswer({required this.report});

  @override
  State<_ReportAnswer> createState() => _ReportAnswerState();
}

class _ReportAnswerState extends State<_ReportAnswer> {
  final _note = TextEditingController();
  String? _answer;
  String? _busy;

  @override
  void initState() {
    super.initState();
    _answer = widget.report['restaurant_response'] as String?;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send(String response) async {
    setState(() => _busy = response);
    try {
      await ApiService.answerIssue(
        token: context.read<AuthProvider>().token!,
        issueId: widget.report['id'] as int,
        response: response,
        note: _note.text.trim(),
      );
      if (mounted) setState(() => _answer = response);
    } catch (e) {
      if (mounted) {
        showSettingsMessage(context, friendlyMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final items = (r['items'] as List? ?? const [])
        .map((l) => '${l['quantity']}× ${l['name']}')
        .join(', ');
    Widget photo(String? url, String label) => url == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(url,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 96, height: 96)),
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: textSec, fontSize: 11)),
            ]),
          );
    return Container(
      key: Key('restaurant-issue-${r['id']}'),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Order #${r['order_id']} · ${r['reason_label']}',
            style: TextStyle(
                color: textPri, fontWeight: FontWeight.w800, fontSize: 15)),
        if (items.isNotEmpty)
          Text('Ordered: $items',
              style: TextStyle(color: textSec, fontSize: 12.5)),
        if ((r['details'] as String?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 6),
          Text('“${r['details']}”',
              style: TextStyle(
                  color: textPri, fontSize: 13.5, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          photo(r['photo_url'] as String?, "Customer's photo"),
          photo(r['packed_photo_url'] as String?, 'Your packing photo'),
        ]),
        const SizedBox(height: 10),
        if (_answer != null)
          Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.success, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  _answer == 'packed'
                      ? 'You said it was packed. FindFood will look into it.'
                      : 'You said it was your mistake. Thanks for being honest.',
                  style: TextStyle(color: textSec, fontSize: 13)),
            ),
          ])
        else ...[
          AppTextField(
            key: Key('restaurant-issue-note-${r['id']}'),
            controller: _note,
            hint: 'Anything to add? (optional)',
            prefixIcon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: FilledButton(
                key: Key('restaurant-issue-packed-${r['id']}'),
                onPressed: _busy == null ? () => _send('packed') : null,
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white),
                child: Text(_busy == 'packed' ? 'Sending…' : 'It was packed'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                key: Key('restaurant-issue-mistake-${r['id']}'),
                onPressed: _busy == null ? () => _send('our_mistake') : null,
                child:
                    Text(_busy == 'our_mistake' ? 'Sending…' : 'Our mistake'),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

/// The restaurant's Reports tab: reports to answer, waiting on FindFood, and
/// past ones with how they ended.
class RestaurantReportsPage extends StatefulWidget {
  /// Told the number still waiting for an answer (for the tab's badge).
  final ValueChanged<int>? onWaitingChanged;
  const RestaurantReportsPage({super.key, this.onWaitingChanged});

  @override
  State<RestaurantReportsPage> createState() => _RestaurantReportsPageState();
}

class _RestaurantReportsPageState extends State<RestaurantReportsPage> {
  List<Map<String, dynamic>>? _reports;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final reports = await ApiService.getRestaurantIssues(token, status: 'all');
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _error = null;
      });
      widget.onWaitingChanged?.call(reports
          .where((r) => r['status'] == 'open' && r['restaurant_response'] == null)
          .length);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final reports = _reports;
    final toAnswer = [
      for (final r in reports ?? const <Map<String, dynamic>>[])
        if (r['status'] == 'open' && r['restaurant_response'] == null) r
    ];
    final waiting = [
      for (final r in reports ?? const <Map<String, dynamic>>[])
        if (r['status'] == 'open' && r['restaurant_response'] != null) r
    ];
    final done = [
      for (final r in reports ?? const <Map<String, dynamic>>[])
        if (r['status'] != 'open') r
    ];
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text(text.toUpperCase(),
              style: TextStyle(
                  color: AppColors.textHint(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8)),
        );
    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: _load,
        child: ListView(
          key: const Key('restaurant-reports'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text('Problem reports',
                style: TextStyle(
                    color: textPri, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
            const SizedBox(height: 4),
            Text('When a customer says food was wrong, missing or damaged, tell us what you '
                'packed. Your packing photo and seal are your proof.',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13, height: 1.4)),
            if (reports == null && _error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else if (reports == null)
              EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: "Couldn't load reports",
                  subtitle: _error!,
                  actionLabel: 'Retry',
                  onAction: _load)
            else if (reports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: EmptyState(
                  icon: Icons.verified_rounded,
                  title: 'No problem reports',
                  subtitle: 'Keep taking packing photos and sealing packs, and it stays that way.',
                ),
              )
            else ...[
              if (toAnswer.isNotEmpty) ...[
                label('To answer'),
                for (final r in toAnswer) _ReportAnswer(report: r),
              ],
              if (waiting.isNotEmpty) ...[
                label('Waiting for FindFood'),
                for (final r in waiting) _ReportAnswer(report: r),
              ],
              if (done.isNotEmpty) ...[
                label('Resolved'),
                for (final r in done) _PastReport(report: r),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PastReport extends StatelessWidget {
  final Map<String, dynamic> report;
  const _PastReport({required this.report});

  @override
  Widget build(BuildContext context) {
    final refunded = report['status'] == 'refunded';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(children: [
        Icon(refunded ? Icons.payments_outlined : Icons.verified_rounded,
            color: refunded ? AppTheme.warning : AppTheme.success, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Order #${report['order_id']} · ${report['reason_label']}',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            Text(
                refunded
                    ? 'The customer was refunded.'
                    : "Closed: we couldn't confirm a problem. You're in the clear.",
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
          ]),
        ),
      ]),
    );
  }
}
