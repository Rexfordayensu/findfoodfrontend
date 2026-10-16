import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/account_settings.dart' show showSettingsMessage;
import '../../widgets/widgets.dart';

const _audiences = [
  ('customers', 'Customers', Icons.person_rounded),
  ('riders', 'Riders', Icons.delivery_dining_rounded),
  ('restaurants', 'Restaurants', Icons.storefront_rounded),
  ('everyone', 'Everyone', Icons.groups_rounded),
];

String _when(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${months[at.month - 1]}, ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
}

Widget _title(BuildContext context, String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: AppColors.textPrimary(context), fontSize: 28,
                fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5, height: 1.4)),
      ],
    );

// ── Announcements ────────────────────────────────────────────────────────────

/// Admin → Announcements: send a notification to customers, riders or restaurants.
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  Map<String, dynamic>? _data;
  String? _error;
  String _audience = 'customers';
  String _kind = 'news';
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
    _titleCtrl.addListener(() => setState(() {}));
    _bodyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getAnnouncements(context.read<AuthProvider>().token!);
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

  int get _reach => (((_data?['reach'] as Map?)?[_audience] as Map?)?[_kind] as num?)?.toInt() ?? 0;

  Future<void> _send() async {
    final title = _titleCtrl.text.trim(), body = _bodyCtrl.text.trim();
    if (title.length < 3 || body.length < 3) {
      showSettingsMessage(context, 'Write a title and a message.', isError: true);
      return;
    }
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Send to $_reach ${_reach == 1 ? 'person' : 'people'}?'),
        content: Text('"$title" goes to their notifications and phones straight away. '
            "It can't be unsent."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(key: const Key('announce-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send')),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _sending = true);
    try {
      final result = await ApiService.sendAnnouncement(context.read<AuthProvider>().token!,
          audience: _audience, kind: _kind, title: title, body: body);
      if (!mounted) return;
      showSettingsMessage(context, 'Sent to ${result['sent_to']} people.');
      _titleCtrl.clear();
      _bodyCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final history = ((data?['history'] as List?) ?? const []).cast<Map<String, dynamic>>();
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _title(context, 'Announcements',
              'Send news or an important update to everyone who uses FindFood, or just one group.'),
          const SizedBox(height: 16),
          if (_error != null && data == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load announcements",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else ...[
            Text('Who should get it?', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (value, label, icon) in _audiences)
                ChoiceChip(
                  key: Key('audience-$value'),
                  avatar: Icon(icon, size: 16),
                  label: Text(label),
                  selected: _audience == value,
                  onSelected: (_) => setState(() => _audience = value),
                ),
            ]),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              key: const Key('announce-kind'),
              segments: const [
                ButtonSegment(value: 'news', label: Text('Offers & news'), icon: Icon(Icons.campaign_outlined)),
                ButtonSegment(value: 'important', label: Text('Important'), icon: Icon(Icons.priority_high_rounded)),
              ],
              selected: {_kind},
              onSelectionChanged: (v) => setState(() => _kind = v.first),
            ),
            const SizedBox(height: 6),
            Text(
              _kind == 'news'
                  ? 'Skips people who turned off offers and news.'
                  : 'For service updates only (e.g. delays from rain). Everyone gets it.',
              style: TextStyle(color: textSec, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(key: const Key('announce-title'), controller: _titleCtrl, maxLength: 120,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'Free delivery this weekend!')),
            TextField(key: const Key('announce-body'), controller: _bodyCtrl, maxLength: 300, maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message',
                    hintText: 'Use code WEEKEND at checkout. Ends Sunday.')),
            if (_titleCtrl.text.trim().isNotEmpty) ...[
              Text('Preview', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                key: const Key('announce-preview'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(9)),
                    child: const Icon(Icons.fastfood_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_titleCtrl.text.trim(), style: TextStyle(color: textPri, fontWeight: FontWeight.w800)),
                      Text(_bodyCtrl.text.trim(), style: TextStyle(color: textSec, fontSize: 13)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
            ],
            PrimaryButton(
              key: const Key('announce-send'),
              label: data == null ? 'Send' : 'Send to $_reach ${_reach == 1 ? 'person' : 'people'}',
              isLoading: _sending,
              onPressed: _sending || data == null || _reach == 0 ? null : _send,
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Sent before', style: TextStyle(color: textPri, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final h in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(h['kind'] == 'important' ? Icons.priority_high_rounded : Icons.campaign_outlined,
                        size: 18, color: h['kind'] == 'important' ? AppTheme.danger : AppColors.accentText(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${h['title']}', style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
                        Text('${h['body']}', style: TextStyle(color: textSec, fontSize: 12.5)),
                        Text('${h['sent_to']} ${h['audience']} · ${h['sent_by'] ?? 'admin'} · ${_when(h['created_at'])}',
                            style: TextStyle(color: textSec, fontSize: 11.5)),
                      ]),
                    ),
                  ]),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Platform switches ────────────────────────────────────────────────────────

/// Admin → Platform: pause ordering or delivery, opening hours, delivery distance.
class PlatformPage extends StatefulWidget {
  const PlatformPage({super.key});

  @override
  State<PlatformPage> createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _draft;
  String? _error;
  bool _saving = false;
  final _message = TextEditingController();
  final _km = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _message.dispose();
    _km.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getPlatformSettings(context.read<AuthProvider>().token!);
      if (!mounted) return;
      final s = Map<String, dynamic>.from(data['settings'] as Map);
      setState(() {
        _data = data;
        _draft = s;
        _error = null;
      });
      _message.text = '${s['pause_message'] ?? ''}';
      _km.text = s['max_delivery_km'] == null ? '' : '${s['max_delivery_km']}'.replaceAll(RegExp(r'\.0$'), '');
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Map<String, dynamic> get _body => {
        ..._draft!,
        'pause_message': _message.text.trim(),
        'max_delivery_km': double.tryParse(_km.text.trim()),
      };

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final data = await ApiService.setPlatformSettings(context.read<AuthProvider>().token!, _body);
      if (!mounted) return;
      setState(() {
        _data = data;
        _draft = Map<String, dynamic>.from(data['settings'] as Map);
      });
      showSettingsMessage(context, 'Saved. It applies to new orders straight away.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(String key) async {
    final parts = '${_draft![key]}'.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked != null) {
      setState(() => _draft![key] =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _draft;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final status = _data?['status'] as Map?;
    Widget toggle(String key, String title, String subtitle, {Color? color}) => SwitchListTile(
          key: Key('platform-$key'),
          contentPadding: EdgeInsets.zero,
          value: d![key] == true,
          activeThumbColor: color,
          onChanged: _saving ? null : (v) => setState(() => d[key] = v),
          title: Text(title, style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: TextStyle(color: textSec, fontSize: 12.5)),
        );
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _title(context, 'Platform', 'Pause FindFood in a storm or outage, and set when and how far it delivers.'),
          const SizedBox(height: 16),
          if (_error != null && d == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load the settings",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (d == null)
            const Padding(padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
          else ...[
            if (status != null)
              Container(
                key: const Key('platform-now'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (status['ordering_open'] == true ? AppTheme.success : AppTheme.danger)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Icon(status['ordering_open'] == true ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                      color: status['ordering_open'] == true ? AppTheme.success : AppTheme.danger),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status['ordering_open'] != true
                          ? 'Right now: ordering is closed. ${status['message'] ?? ''}'
                          : status['delivery_open'] != true
                              ? 'Right now: pickup only. Delivery is paused.'
                              : 'Right now: open for ordering and delivery.',
                      style: TextStyle(color: textPri, fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              ),
            const SizedBox(height: 12),
            toggle('ordering_paused', 'Pause all ordering', 'Nobody can place new orders. Orders in progress carry on.',
                color: AppTheme.danger),
            toggle('delivery_paused', 'Pause delivery only', 'Customers can still order for pickup.',
                color: AppTheme.warning),
            TextField(
              key: const Key('platform-message'),
              controller: _message,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Message customers see while paused (optional)',
                hintText: 'Heavy rain: back in an hour. Stay safe!',
              ),
            ),
            const Divider(height: 28),
            toggle('hours_enabled', 'Opening hours', 'Outside these hours, new orders wait until opening.'),
            if (d['hours_enabled'] == true)
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('platform-opens'),
                    onPressed: () => _pickTime('opens_at'),
                    icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                    label: Text('Opens ${d['opens_at']}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('platform-closes'),
                    onPressed: () => _pickTime('closes_at'),
                    icon: const Icon(Icons.nightlight_outlined, size: 18),
                    label: Text('Closes ${d['closes_at']}'),
                  ),
                ),
              ]),
            const Divider(height: 28),
            TextField(
              key: const Key('platform-km'),
              controller: _km,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Furthest delivery (km)',
                hintText: 'Empty = no limit',
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 6),
            Text('Only checked when the customer shares their location and the restaurant has saved theirs.',
                style: TextStyle(color: textSec, fontSize: 12)),
            const SizedBox(height: 18),
            PrimaryButton(key: const Key('platform-save'), label: 'Save', isLoading: _saving,
                onPressed: _saving ? null : _save),
            if (((_data?['history'] as List?) ?? const []).isNotEmpty) ...[
              const SizedBox(height: 22),
              Text('Changes', style: TextStyle(color: textPri, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final h in (_data!['history'] as List).cast<Map>().take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${_when(h['changed_at'])} · ${h['changed_by'] ?? 'admin'}: '
                    '${(h['settings'] as Map)['ordering_paused'] == true ? 'ordering paused' : (h['settings'] as Map)['delivery_paused'] == true ? 'pickup only' : 'open'}',
                    style: TextStyle(color: textSec, fontSize: 12.5),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
