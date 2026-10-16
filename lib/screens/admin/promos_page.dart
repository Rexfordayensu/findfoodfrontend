import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart' show formatCedis;
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import '../../widgets/widgets.dart';

String _date(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${months[at.month - 1]}';
}

/// Admin → Promo codes: create codes for customers, see how they're used.
class PromosPage extends StatefulWidget {
  const PromosPage({super.key});

  @override
  State<PromosPage> createState() => _PromosPageState();
}

class _PromosPageState extends State<PromosPage> {
  List<Map<String, dynamic>>? _promos;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final promos = await ApiService.getPromos(context.read<AuthProvider>().token!);
      if (mounted) {
        setState(() {
          _promos = promos;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _create() async {
    final created = await showSettingsSheet<Map<String, dynamic>>(context, const _PromoForm());
    if (created != null) {
      await _load();
      if (mounted) showSettingsMessage(context, '${created['code']} is live. Share it with customers!');
    }
  }

  Future<void> _toggle(Map<String, dynamic> promo, bool active) async {
    try {
      await ApiService.updatePromo(context.read<AuthProvider>().token!, promo['id'] as int, {'active': active});
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promos = _promos;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Promo codes',
                    style: TextStyle(color: textPri, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Codes customers type at checkout. FindFood pays the discount; restaurants still '
                    'get their full share.',
                    style: TextStyle(color: textSec, fontSize: 13.5, height: 1.4)),
              ]),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('promo-new'),
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New code'),
            ),
          ]),
          const SizedBox(height: 16),
          if (_error != null && promos == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load promo codes",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (promos == null)
            const Padding(padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
          else if (promos.isEmpty)
            const EmptyState(icon: Icons.local_offer_outlined, title: 'No promo codes yet',
                subtitle: 'Try "FIRST50": half off a first order, to get people trying FindFood.')
          else
            for (final p in promos)
              Container(
                key: Key('promo-${p['code']}'),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (p['active'] == true ? AppTheme.accent : AppColors.border(context))
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${p['code']}',
                              style: TextStyle(color: textPri, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                        if (p['active'] != true) ...[
                          const SizedBox(width: 8),
                          Text('Paused', style: TextStyle(color: textSec, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ]),
                      const SizedBox(height: 6),
                      Text('${p['description']}', style: TextStyle(color: textPri, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        [
                          '${p['uses']}${p['max_uses'] != null ? '/${p['max_uses']}' : ''} used',
                          '${formatCedis((p['discount_given'] as num).toInt())} given',
                          if (p['first_order_only'] == true) 'first orders only',
                          if ((p['min_order'] as num) > 0) 'min ${formatCedis((p['min_order'] as num).toInt())}',
                          if (p['ends_at'] != null) 'ends ${_date(p['ends_at'])}',
                        ].join(' · '),
                        style: TextStyle(color: textSec, fontSize: 12.5),
                      ),
                    ]),
                  ),
                  Switch(
                    key: Key('promo-switch-${p['code']}'),
                    value: p['active'] == true,
                    onChanged: (v) => _toggle(p, v),
                  ),
                ]),
              ),
        ],
      ),
    );
  }
}

class _PromoForm extends StatefulWidget {
  const _PromoForm();

  @override
  State<_PromoForm> createState() => _PromoFormState();
}

class _PromoFormState extends State<_PromoForm> {
  final _code = TextEditingController();
  final _value = TextEditingController();
  final _cap = TextEditingController();
  final _min = TextEditingController();
  final _maxUses = TextEditingController();
  final _description = TextEditingController();
  String _kind = 'percent';
  bool _firstOrder = false;
  DateTime? _ends;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_code, _value, _cap, _min, _maxUses, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _pesewas(TextEditingController c) {
    final v = double.tryParse(c.text.trim());
    return v == null || v <= 0 ? null : (v * 100).round();
  }

  Future<void> _save() async {
    final code = _code.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{3,20}$').hasMatch(code)) {
      showSettingsMessage(context, 'Codes are 3–20 letters and numbers, e.g. FIRST50.', isError: true);
      return;
    }
    final body = <String, dynamic>{
      'code': code,
      'kind': _kind,
      'first_order_only': _firstOrder,
      if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
      if (_pesewas(_min) != null) 'min_order': _pesewas(_min),
      if (int.tryParse(_maxUses.text.trim()) != null) 'max_uses': int.parse(_maxUses.text.trim()),
      if (_ends != null) 'ends_at': DateTime(_ends!.year, _ends!.month, _ends!.day, 23, 59).toUtc().toIso8601String(),
    };
    if (_kind == 'percent') {
      final percent = int.tryParse(_value.text.trim());
      if (percent == null || percent < 1 || percent > 100) {
        showSettingsMessage(context, 'Enter a percentage from 1 to 100.', isError: true);
        return;
      }
      body['value'] = percent;
      if (_pesewas(_cap) != null) body['max_discount'] = _pesewas(_cap);
    } else if (_kind == 'amount') {
      if (_pesewas(_value) == null) {
        showSettingsMessage(context, 'Enter how much it takes off.', isError: true);
        return;
      }
      body['value'] = _pesewas(_value);
    }
    setState(() => _saving = true);
    try {
      final created = await ApiService.createPromo(context.read<AuthProvider>().token!, body);
      if (mounted) Navigator.of(context).pop(created);
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSec = AppColors.textSecondary(context);
    InputDecoration money(String label) => InputDecoration(labelText: label, prefixText: 'GH₵ ', isDense: true);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHeader(title: 'New promo code', subtitle: 'Customers type it at checkout.'),
      TextField(
        key: const Key('promo-code'),
        controller: _code,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(labelText: 'Code, e.g. FIRST50', isDense: true),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final (value, label) in [('percent', '% off'), ('amount', 'GH₵ off'), ('free_delivery', 'Free delivery')])
          ChoiceChip(key: Key('promo-kind-$value'), label: Text(label), selected: _kind == value,
              onSelected: (_) => setState(() => _kind = value)),
      ]),
      const SizedBox(height: 12),
      if (_kind == 'percent')
        Row(children: [
          Expanded(child: TextField(key: const Key('promo-value'), controller: _value,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Percent off', suffixText: '%', isDense: true))),
          const SizedBox(width: 10),
          Expanded(child: TextField(key: const Key('promo-cap'), controller: _cap,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: money('Up to (optional)'))),
        ])
      else if (_kind == 'amount')
        TextField(key: const Key('promo-value'), controller: _value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: money('Amount off')),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(key: const Key('promo-min'), controller: _min,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: money('Minimum food spend'))),
        const SizedBox(width: 10),
        Expanded(child: TextField(key: const Key('promo-max-uses'), controller: _maxUses,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total uses (optional)', isDense: true))),
      ]),
      const SizedBox(height: 10),
      TextField(key: const Key('promo-description'), controller: _description,
          decoration: const InputDecoration(labelText: 'What customers see (optional)', isDense: true)),
      SwitchListTile(
        key: const Key('promo-first-order'),
        contentPadding: EdgeInsets.zero,
        value: _firstOrder,
        onChanged: (v) => setState(() => _firstOrder = v),
        title: const Text('First orders only', style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Each customer can use a code once.', style: TextStyle(color: textSec, fontSize: 12)),
      ),
      Row(children: [
        Expanded(child: Text(_ends == null ? 'No end date' : 'Ends ${_ends!.day}/${_ends!.month}/${_ends!.year}',
            style: TextStyle(color: textSec))),
        TextButton(
          key: const Key('promo-ends'),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(context: context, firstDate: now,
                lastDate: now.add(const Duration(days: 365)), initialDate: _ends ?? now.add(const Duration(days: 7)));
            if (picked != null) setState(() => _ends = picked);
          },
          child: Text(_ends == null ? 'Add end date' : 'Change'),
        ),
      ]),
      const SizedBox(height: 8),
      PrimaryButton(key: const Key('promo-save'), label: 'Create code', isLoading: _saving,
          onPressed: _saving ? null : _save),
    ]);
  }
}
