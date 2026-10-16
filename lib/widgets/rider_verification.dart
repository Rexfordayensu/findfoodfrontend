import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart' show SheetHeader, showEditProfileSheet, showSettingsSheet, showSettingsMessage;
import 'greeting_header.dart';
import 'user_avatar.dart' show EditableAvatar, UserAvatar;
import 'widgets.dart';

const vehicleLabels = {
  'motorbike': 'Motorbike',
  'bicycle': 'Bicycle',
  'car': 'Car',
  'on_foot': 'On foot',
};

// ── Rider: get verified ──────────────────────────────────────────────────────

/// Shown to riders who aren't approved yet, in place of the jobs list.
class RiderVerificationPanel extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const RiderVerificationPanel({super.key, required this.data, required this.onChanged});

  @override
  State<RiderVerificationPanel> createState() => _RiderVerificationPanelState();
}

class _RiderVerificationPanelState extends State<RiderVerificationPanel> {
  final _card = TextEditingController();
  final _licence = TextEditingController();
  final _plate = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  String _vehicle = 'motorbike';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _card.text = '${d['ghana_card'] ?? ''}';
    _licence.text = '${d['licence_number'] ?? ''}';
    _plate.text = '${d['plate'] ?? ''}';
    _emergencyName.text = '${d['emergency_name'] ?? ''}';
    _emergencyPhone.text = '${d['emergency_phone'] ?? ''}';
    _vehicle = '${d['vehicle'] ?? 'motorbike'}';
  }

  @override
  void dispose() {
    for (final c in [_card, _licence, _plate, _emergencyName, _emergencyPhone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final data = await ApiService.getRiderVerification(context.read<AuthProvider>().token!);
      widget.onChanged(data);
    } catch (_) {}
  }

  Future<void> _submit() async {
    final motor = _vehicle == 'motorbike' || _vehicle == 'car';
    if (!RegExp(r'^GHA-?\d{9}-?\d$', caseSensitive: false).hasMatch(_card.text.trim())) {
      showSettingsMessage(context, 'Enter your Ghana Card number, e.g. GHA-123456789-0.', isError: true);
      return;
    }
    if (motor && (_licence.text.trim().length < 4 || _plate.text.trim().length < 4)) {
      showSettingsMessage(context, 'Add your licence number and number plate.', isError: true);
      return;
    }
    if (_emergencyName.text.trim().length < 2 || _emergencyPhone.text.trim().length < 9) {
      showSettingsMessage(context, 'Add someone we can call in an emergency.', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      final data = await ApiService.submitRiderVerification(context.read<AuthProvider>().token!, {
        'ghana_card': _card.text.trim(),
        'vehicle': _vehicle,
        'licence_number': motor ? _licence.text.trim() : null,
        'plate': motor ? _plate.text.trim() : null,
        'emergency_name': _emergencyName.text.trim(),
        'emergency_phone': _emergencyPhone.text.trim(),
      });
      widget.onChanged(data);
      if (mounted) showSettingsMessage(context, "Sent! We'll let you know once you're approved.");
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final status = '${d['status']}';
    final missing = ((d['missing'] as List?) ?? const []).map((m) => '$m').toSet();
    final auth = context.watch<AuthProvider>();
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    Widget step(int n, String title, bool done, Widget? action) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? AppTheme.success : AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: done ? AppTheme.success : AppColors.border(context)),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : Text('$n', style: TextStyle(color: textSec, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(color: textPri, fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null)),
            ),
            if (!done && action != null) action,
          ]),
        );

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
        children: [
          GreetingHeader(
            name: auth.name ?? '',
            role: 'rider',
            status: status == 'pending'
                ? "We're checking your details."
                : "Let's get you verified so you can start earning.",
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (status == 'pending')
                _Banner(
                  key: const Key('verification-pending'),
                  color: AppTheme.info,
                  icon: Icons.hourglass_top_rounded,
                  title: 'Thanks! Your details are with FindFood',
                  body: 'We may call you to meet and see your Ghana Card'
                      "${d['vehicle'] == 'motorbike' || d['vehicle'] == 'car' ? ' and licence' : ''}. "
                      "You'll get a notification as soon as you're approved.",
                )
              else ...[
                if (status == 'rejected')
                  _Banner(
                    key: const Key('verification-rejected'),
                    color: AppTheme.danger,
                    icon: Icons.info_rounded,
                    title: "We couldn't approve you yet",
                    body: '${d['rejection_reason'] ?? 'Please check your details.'}. Fix it below and send again.',
                  )
                else
                  const _Banner(
                    color: AppTheme.accentDeep,
                    icon: Icons.verified_user_rounded,
                    title: 'Riders are checked before their first job',
                    body: 'It keeps customers and restaurants safe. It takes a few minutes to fill in.',
                  ),
                const SizedBox(height: 16),
                step(1, 'A clear photo of your face', !missing.contains('photo'),
                    const EditableAvatar(size: 44)),
                step(2, 'Your phone number', !missing.contains('phone'),
                    TextButton(
                      key: const Key('verification-add-phone'),
                      onPressed: () async {
                        await showEditProfileSheet(context);
                        await _refresh();
                      },
                      child: const Text('Add'),
                    )),
                step(3, 'Your ID and vehicle', false, null),
                const SizedBox(height: 6),
                AppTextField(key: const Key('verify-card'), controller: _card,
                    hint: 'Ghana Card number (GHA-123456789-0)', prefixIcon: Icons.badge_outlined),
                const SizedBox(height: 12),
                Text('How do you deliver?', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in vehicleLabels.entries)
                    ChoiceChip(
                      key: Key('vehicle-${e.key}'),
                      label: Text(e.value),
                      selected: _vehicle == e.key,
                      onSelected: (_) => setState(() => _vehicle = e.key),
                    ),
                ]),
                if (_vehicle == 'motorbike' || _vehicle == 'car') ...[
                  const SizedBox(height: 12),
                  AppTextField(key: const Key('verify-licence'), controller: _licence,
                      hint: "Driver's licence number", prefixIcon: Icons.credit_card_rounded),
                  const SizedBox(height: 10),
                  AppTextField(key: const Key('verify-plate'), controller: _plate,
                      hint: 'Number plate, e.g. GR 1234-24', prefixIcon: Icons.pin_outlined),
                ],
                const SizedBox(height: 16),
                Text('Emergency contact', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                AppTextField(key: const Key('verify-emergency-name'), controller: _emergencyName,
                    hint: 'Their name', prefixIcon: Icons.person_outline_rounded),
                const SizedBox(height: 10),
                AppTextField(key: const Key('verify-emergency-phone'), controller: _emergencyPhone,
                    hint: 'Their phone number', prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                Text('Only FindFood admins see these details. We never share your Ghana Card number.',
                    style: TextStyle(color: textSec, fontSize: 12, height: 1.4)),
                const SizedBox(height: 16),
                PrimaryButton(
                  key: const Key('verify-submit'),
                  label: status == 'rejected' ? 'Send again' : 'Send for approval',
                  isLoading: _sending,
                  onPressed: _sending || missing.isNotEmpty ? null : _submit,
                ),
                if (missing.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Add your photo and phone number first (steps 1 and 2).',
                        style: TextStyle(color: AppColors.accentText(context), fontSize: 12.5)),
                  ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title, body;
  const _Banner({super.key, required this.color, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(body, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13, height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}

// ── Admin: check riders ──────────────────────────────────────────────────────

/// Admin → Approvals → Riders: riders waiting for a check, and the others.
class RiderApprovalsPage extends StatefulWidget {
  final Future<void> Function()? onCountChanged;
  const RiderApprovalsPage({super.key, this.onCountChanged});

  @override
  State<RiderApprovalsPage> createState() => _RiderApprovalsPageState();
}

class _RiderApprovalsPageState extends State<RiderApprovalsPage> {
  String _status = 'pending';
  List<Map<String, dynamic>>? _riders;
  String? _error;
  final _busy = <int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final riders = await ApiService.getRiderVerifications(context.read<AuthProvider>().token!, _status);
      if (mounted) {
        setState(() {
          _riders = riders;
          _error = null;
        });
      }
      await widget.onCountChanged?.call();
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _decide(Map<String, dynamic> rider, bool approve) async {
    String? reason;
    if (!approve) {
      reason = await showSettingsSheet<String>(context, _RejectForm(name: '${rider['name']}'));
      if (reason == null) return;
    } else {
      final sure = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Approve ${rider['name']}?'),
          content: const Text('Only approve after checking their Ghana Card'
              ' (and licence for a motorbike or car) in person. They can take jobs straight away.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(key: const Key('rider-approve-confirm'),
                onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Approve')),
          ],
        ),
      );
      if (sure != true) return;
    }
    if (!mounted) return;
    final id = rider['rider_id'] as int;
    setState(() => _busy.add(id));
    try {
      final token = context.read<AuthProvider>().token!;
      if (approve) {
        await ApiService.approveRider(token, id);
      } else {
        await ApiService.rejectRider(token, id, reason!);
      }
      if (mounted) {
        showSettingsMessage(context, approve ? '${rider['name']} is approved.' : '${rider['name']} has been told what to fix.');
      }
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final riders = _riders;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Wrap(spacing: 8, children: [
            for (final (value, label) in [
              ('pending', 'Waiting'), ('approved', 'Approved'), ('rejected', 'Not approved'),
              ('unsubmitted', 'Not sent yet'),
            ])
              ChoiceChip(
                key: Key('riders-filter-$value'),
                label: Text(label),
                selected: _status == value,
                onSelected: (_) {
                  setState(() {
                    _status = value;
                    _riders = null;
                  });
                  _load();
                },
              ),
          ]),
          const SizedBox(height: 14),
          if (_error != null && riders == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load riders",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (riders == null)
            const Padding(padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
          else if (riders.isEmpty)
            EmptyState(
              icon: Icons.verified_user_outlined,
              title: _status == 'pending' ? 'No riders waiting' : 'Nobody here',
              subtitle: _status == 'pending' ? 'New riders appear here after sending their details.' : '',
            )
          else
            for (final r in riders)
              Container(
                key: Key('rider-check-${r['rider_id']}'),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    UserAvatar(name: '${r['name']}', url: r['avatar_url'] as String?, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r['name']}',
                            style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('${r['phone'] ?? 'No phone'} · ${r['email']}',
                            style: TextStyle(color: textSec, fontSize: 12.5)),
                      ]),
                    ),
                  ]),
                  if (r['ghana_card'] != null) ...[
                    const SizedBox(height: 12),
                    _detail(context, 'Ghana Card', '${r['ghana_card']}'),
                    _detail(context, 'Vehicle', '${r['vehicle_label'] ?? r['vehicle'] ?? '-'}'
                        '${r['plate'] != null ? ' · ${r['plate']}' : ''}'),
                    if (r['licence_number'] != null) _detail(context, 'Licence', '${r['licence_number']}'),
                    _detail(context, 'Emergency', '${r['emergency_name']} · ${r['emergency_phone']}'),
                  ],
                  if (r['rejection_reason'] != null && r['status'] == 'rejected')
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Not approved: ${r['rejection_reason']}',
                          style: const TextStyle(color: AppTheme.danger, fontSize: 12.5)),
                    ),
                  if (r['status'] == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          key: Key('rider-reject-${r['rider_id']}'),
                          onPressed: _busy.contains(r['rider_id']) ? null : () => _decide(r, false),
                          child: const Text('Not yet'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          key: Key('rider-approve-${r['rider_id']}'),
                          onPressed: _busy.contains(r['rider_id']) ? null : () => _decide(r, true),
                          child: const Text('Approve'),
                        ),
                      ),
                    ]),
                  ],
                ]),
              ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 90,
              child: Text(k, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13))),
          Expanded(child: Text(v,
              style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
      );
}

class _RejectForm extends StatefulWidget {
  final String name;
  const _RejectForm({required this.name});

  @override
  State<_RejectForm> createState() => _RejectFormState();
}

class _RejectFormState extends State<_RejectForm> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      SheetHeader(title: "Don't approve ${widget.name} yet",
          subtitle: "Tell them what to fix. They'll see this and can send their details again."),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in ['The Ghana Card number is wrong', 'Please add a clearer face photo',
            "The plate number doesn't match", 'We could not reach you by phone'])
          ActionChip(label: Text(s), onPressed: () => setState(() => _reason.text = s)),
      ]),
      const SizedBox(height: 12),
      AppTextField(key: const Key('reject-reason'), controller: _reason, hint: 'What should they fix?',
          prefixIcon: Icons.edit_note_rounded),
      const SizedBox(height: 14),
      PrimaryButton(
        key: const Key('reject-confirm'),
        label: 'Send',
        onPressed: () {
          if (_reason.text.trim().length < 3) {
            showSettingsMessage(context, 'Tell them what to fix.', isError: true);
            return;
          }
          Navigator.of(context).pop(_reason.text.trim());
        },
      ),
    ]);
  }
}
