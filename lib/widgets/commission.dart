import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart' show showSettingsMessage;
import 'widgets.dart';

/// "15%" or "12.5%".
String percentLabel(num value) =>
    value == value.roundToDouble() ? '${value.round()}%' : '${value.toStringAsFixed(1)}%';

/// Admin: FindFood's commission on each order, and its history.
class CommissionPage extends StatefulWidget {
  const CommissionPage({super.key});

  @override
  State<CommissionPage> createState() => _CommissionPageState();
}

class _CommissionPageState extends State<CommissionPage> {
  Map<String, dynamic>? _data;
  String? _error;
  double? _draft;
  bool _saving = false;
  final _field = TextEditingController();

  static const _example = 5000; // GH₵ 50.00

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getCommission(context.read<AuthProvider>().token!);
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
        _draft = (data['percent'] as num).toDouble();
        _field.text = _draft!.toStringAsFixed(_draft! % 1 == 0 ? 0 : 1);
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  double get _max => ((_data?['max_percent'] as num?) ?? 40).toDouble();

  void _setDraft(double value, {bool fromField = false}) {
    final clamped = value.clamp(0, _max).toDouble();
    setState(() => _draft = (clamped * 2).round() / 2); // steps of 0.5%
    if (!fromField) _field.text = percentLabel(_draft!).replaceAll('%', '');
  }

  Future<void> _save() async {
    final draft = _draft!;
    final current = (_data!['percent'] as num).toDouble();
    if (draft == current) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Change commission to ${percentLabel(draft)}?'),
        content: Text(
            'Restaurants will receive ${percentLabel(100 - draft)} of each new order '
            '(now ${percentLabel(100 - current)}). Orders already paid keep their rate. '
            "We'll notify every restaurant."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              key: const Key('commission-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Change it')),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final data = await ApiService.setCommission(context.read<AuthProvider>().token!, draft);
      if (!mounted) return;
      setState(() => _data = data);
      showSettingsMessage(context,
          'Commission is now ${percentLabel(draft)}. Restaurants have been told.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final data = _data;
    if (_error != null && data == null) {
      return EmptyState(
          icon: Icons.wifi_off_rounded,
          title: "Couldn't load the commission",
          subtitle: _error!,
          actionLabel: 'Retry',
          onAction: _load);
    }
    if (data == null || _draft == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    final current = (data['percent'] as num).toDouble();
    final draft = _draft!;
    final changed = draft != current;
    final commission = (_example * draft / 100).round();
    final history = (data['history'] as List? ?? const []).cast<Map<String, dynamic>>();

    return ListView(
      key: const Key('commission-page'),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        Text('Commission',
            style: TextStyle(
                color: textPri, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text("FindFood's share of each order. Restaurants are paid the rest automatically.",
            style: TextStyle(color: textSec, fontSize: 13.5)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.accent.withValues(alpha: 0.16),
              AppTheme.accent.withValues(alpha: 0.05),
            ]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Current commission', style: TextStyle(color: textSec, fontSize: 13)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(percentLabel(current),
                  key: const Key('commission-current'),
                  style: TextStyle(
                      color: AppColors.accentText(context),
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1)),
              const SizedBox(width: 10),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('restaurants receive ${percentLabel(100 - current)}',
                      style: TextStyle(color: textSec, fontSize: 14)),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        Text('Change it',
            style: TextStyle(color: textPri, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: SliderTheme(
              // 80 half-percent steps: no tick marks, just the track.
              data: SliderTheme.of(context).copyWith(
                tickMarkShape: SliderTickMarkShape.noTickMark,
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              ),
              child: Slider(
              key: const Key('commission-slider'),
              value: draft,
              min: 0,
              max: _max,
              divisions: (_max * 2).round(),
              label: percentLabel(draft),
              activeColor: AppTheme.accentDeep,
              onChanged: _saving ? null : _setDraft,
            ),
            ),
          ),
          SizedBox(
            width: 86,
            child: TextField(
              key: const Key('commission-field'),
              controller: _field,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(suffixText: '%', isDense: true),
              onChanged: (text) {
                final value = double.tryParse(text.trim());
                if (value != null) _setDraft(value, fromField: true);
              },
            ),
          ),
        ]),
        Container(
          key: const Key('commission-example'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('On a ${formatCedis(_example)} order',
                style: TextStyle(color: textPri, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: Text('Restaurant receives',
                      style: TextStyle(color: textSec, fontSize: 13))),
              Text(formatCedis(_example - commission),
                  style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                  child: Text('FindFood keeps', style: TextStyle(color: textSec, fontSize: 13))),
              Text(formatCedis(commission),
                  style: TextStyle(color: textPri, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 6),
            Text("Paystack's fee (about 2%) comes out of FindFood's part.",
                style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const Key('commission-save'),
          label: changed
              ? 'Change to ${percentLabel(draft)} for new orders'
              : 'Move the slider to change it',
          isLoading: _saving,
          onPressed: changed && !_saving ? _save : null,
        ),
        const SizedBox(height: 28),
        Text('History',
            style: TextStyle(color: textPri, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Text('Unchanged since launch (${percentLabel((data['default_percent'] as num?) ?? 15)}).',
              style: TextStyle(color: textSec, fontSize: 13))
        else
          for (final change in history)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.history_rounded, size: 17, color: textSec),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${percentLabel(change['previous_percent'] as num)} → '
                    '${percentLabel(change['percent'] as num)}'
                    '${change['changed_by'] == null ? '' : ' by ${change['changed_by']}'}',
                    style: TextStyle(color: textPri, fontSize: 13.5),
                  ),
                ),
                Text(_when(change['changed_at']),
                    style: TextStyle(color: textSec, fontSize: 12)),
              ]),
            ),
      ],
    );
  }

  static String _when(Object? iso) {
    final at = DateTime.tryParse('$iso')?.toLocal();
    if (at == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${at.day} ${months[at.month - 1]} ${at.year}';
  }
}
