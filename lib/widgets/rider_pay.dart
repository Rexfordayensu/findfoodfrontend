import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart'
    show SettingsTile, SheetHeader, showSettingsSheet, showSettingsMessage;
import 'commission.dart' show percentLabel;
import 'payouts.dart' show showPayoutSheet, payoutAccountLabel;

import 'widgets.dart';

String _when(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${months[at.month - 1]}';
}

// ── Rider: what's owed, paid, and where ──────────────────────────────────────

/// Top of the rider's Earnings: pending pay, paid so far, the payout account.
class RiderPayoutCard extends StatefulWidget {
  const RiderPayoutCard({super.key});

  @override
  State<RiderPayoutCard> createState() => _RiderPayoutCardState();
}

class _RiderPayoutCardState extends State<RiderPayoutCard> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final data = await ApiService.getMyRiderPayout(token);
      if (mounted) setState(() => _data = data);
    } catch (_) {}
  }

  Future<void> _addAccount() async {
    if (await showRiderPayoutSheet(context) != null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const SizedBox.shrink();
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final automatic = data['payout_mode'] == 'automatic';
    final account = payoutAccountLabel(data);
    final payouts = (data['payouts'] as List? ?? const []).cast<Map<String, dynamic>>();
    return Container(
      key: const Key('rider-payout-card'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Waiting to be paid', style: TextStyle(color: textSec, fontSize: 12.5)),
              Text(formatCedis((data['owed'] as num?)?.toInt() ?? 0),
                  key: const Key('rider-owed'),
                  style: TextStyle(color: textPri, fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Paid to you', style: TextStyle(color: textSec, fontSize: 12.5)),
              Text(formatCedis((data['paid_total'] as num?)?.toInt() ?? 0),
                  style: const TextStyle(
                      color: AppTheme.success, fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
          'You earn ${percentLabel((data['rider_share_percent'] as num?) ?? 100)} of each delivery '
          'fee, paid ${automatic ? 'after each delivery' : 'weekly'}.',
          style: TextStyle(color: textSec, fontSize: 12.5, height: 1.4),
        ),
        const SizedBox(height: 12),
        if (account == null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('rider-add-payout'),
              onPressed: _addAccount,
              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
              label: const Text('Add your MoMo to get paid'),
            ),
          )
        else
          InkWell(
            onTap: _addAccount,
            borderRadius: BorderRadius.circular(10),
            child: Row(children: [
              const Icon(Icons.verified_rounded, color: AppTheme.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Paid to $account',
                      style: TextStyle(color: textPri, fontWeight: FontWeight.w600, fontSize: 13.5))),
              Text('Change', style: TextStyle(color: AppColors.accentText(context), fontSize: 13)),
            ]),
          ),
        if (payouts.isNotEmpty) ...[
          Divider(height: 24, color: AppColors.border(context)),
          for (final p in payouts.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(
                    p['status'] == 'paid'
                        ? Icons.check_circle_rounded
                        : p['status'] == 'failed'
                            ? Icons.error_rounded
                            : Icons.schedule_rounded,
                    size: 16,
                    color: p['status'] == 'paid'
                        ? AppTheme.success
                        : p['status'] == 'failed'
                            ? AppTheme.danger
                            : AppTheme.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      '${formatCedis((p['amount'] as num).toInt())} · ${p['order_count']} '
                      'deliver${p['order_count'] == 1 ? 'y' : 'ies'}',
                      style: TextStyle(color: textPri, fontSize: 13)),
                ),
                Text(
                    p['status'] == 'paid'
                        ? _when(p['paid_at'])
                        : p['status'] == 'failed'
                            ? 'Failed'
                            : 'Sending…',
                    style: TextStyle(color: textSec, fontSize: 12)),
              ]),
            ),
        ],
      ]),
    );
  }
}

/// The rider's MoMo or bank account for payouts.
Future<Map<String, dynamic>?> showRiderPayoutSheet(BuildContext context) =>
    showPayoutSheet(context, rider: true);

// ── Restaurant: where the shop is ────────────────────────────────────────────

/// Restaurant Settings row: saves the shop's location, so delivery fees can
/// follow distance.
class ShopLocationTile extends StatefulWidget {
  final bool isSet;
  const ShopLocationTile({super.key, required this.isSet});

  @override
  State<ShopLocationTile> createState() => _ShopLocationTileState();
}

class _ShopLocationTileState extends State<ShopLocationTile> {
  late bool _isSet = widget.isSet;
  bool _saving = false;

  Future<void> _setHere() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Use where you are now?'),
        content: const Text('Do this while you are at the restaurant. Customers '
            'see delivery fees based on how far they are from here.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              key: const Key('shop-location-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Use this location')),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    final token = context.read<AuthProvider>().token!;
    setState(() => _saving = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Turn on location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission was not granted.');
      }
      final position = await Geolocator.getCurrentPosition();
      await ApiService.setRestaurantLocation(token, position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _isSet = true);
      showSettingsMessage(context, 'Shop location saved.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      key: const Key('settings-shop-location'),
      icon: Icons.place_outlined,
      title: 'Shop location',
      subtitle: _saving
          ? 'Finding you…'
          : _isSet
              ? 'Saved · tap to update it'
              : 'Not set · tap while at your shop',
      onTap: _saving ? null : _setHere,
    );
  }
}

// ── Admin: delivery fees and rider pay ───────────────────────────────────────

/// Admin → Rider pay: settings, and paying riders.
class RiderPayPage extends StatefulWidget {
  const RiderPayPage({super.key});

  @override
  State<RiderPayPage> createState() => _RiderPayPageState();
}

class _RiderPayPageState extends State<RiderPayPage> {
  bool _payouts = false;

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    Widget tab(String label, bool value, Key key) {
      final active = _payouts == value;
      return Expanded(
        child: GestureDetector(
          key: key,
          onTap: () => setState(() => _payouts = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.black : AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        Text('Rider pay',
            style: TextStyle(color: textPri, fontSize: 28, fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('What deliveries cost customers, and how riders are paid.',
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(children: [
            tab('Settings', false, const Key('rider-pay-tab-settings')),
            tab('Payouts', true, const Key('rider-pay-tab-payouts')),
          ]),
        ),
        const SizedBox(height: 18),
        if (_payouts) const _RiderPayouts() else const _DeliverySettings(),
      ],
    );
  }
}

class _DeliverySettings extends StatefulWidget {
  const _DeliverySettings();

  @override
  State<_DeliverySettings> createState() => _DeliverySettingsState();
}

class _DeliverySettingsState extends State<_DeliverySettings> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _draft;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getDeliverySettings(context.read<AuthProvider>().token!);
      if (mounted) {
        setState(() {
          _data = data;
          _draft = Map<String, dynamic>.from(data['settings'] as Map);
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  bool get _changed {
    final saved = _data?['settings'] as Map?;
    if (saved == null || _draft == null) return false;
    return _draft!.entries.any((e) => '${saved[e.key]}' != '${e.value}');
  }

  void _set(String key, Object value) => setState(() => _draft![key] = value);

  Future<void> _save() async {
    final draft = _draft!;
    final saved = _data!['settings'] as Map;
    final payChanged = '${draft['rider_share_percent']}' != '${saved['rider_share_percent']}' ||
        draft['payout_mode'] != saved['payout_mode'];
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save delivery and rider pay settings?'),
        content: Text('These apply to new orders from now on.'
            '${payChanged ? ' Riders will be told about the change to their pay.' : ''}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              key: const Key('delivery-settings-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final data = await ApiService.setDeliverySettings(context.read<AuthProvider>().token!, draft);
      if (!mounted) return;
      setState(() {
        _data = data;
        _draft = Map<String, dynamic>.from(data['settings'] as Map);
      });
      showSettingsMessage(context, 'Saved. New orders use these settings.');
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
    if (_error != null && _data == null) {
      return EmptyState(
          icon: Icons.wifi_off_rounded,
          title: "Couldn't load the settings",
          subtitle: _error!,
          actionLabel: 'Retry',
          onAction: _load);
    }
    final d = _draft;
    if (d == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }
    final distance = d['fee_mode'] == 'distance';
    final automatic = d['payout_mode'] == 'automatic';
    final noLocation = (_data!['restaurants_without_location'] as num?)?.toInt() ?? 0;
    final history = (_data!['history'] as List? ?? const []).cast<Map<String, dynamic>>();

    Widget section(String title, String subtitle) => Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: textPri, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: textSec, fontSize: 13)),
          ]),
        );
    Widget choice(String key, String value, String label, String detail, IconData icon) {
      final active = d[key] == value;
      return Expanded(
        child: GestureDetector(
          key: Key('$key-$value'),
          onTap: _saving ? null : () => _set(key, value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? AppTheme.accent.withValues(alpha: 0.14) : AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: active ? AppTheme.accentDeep : AppColors.border(context),
                  width: active ? 1.6 : 1),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: active ? AppTheme.accentDeep : textSec, size: 20),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: textPri, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(detail, style: TextStyle(color: textSec, fontSize: 12, height: 1.35)),
            ]),
          ),
        ),
      );
    }

    return Column(
      key: const Key('delivery-settings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section('Delivery fee', 'What customers pay for delivery, on top of the food.'),
        Row(children: [
          choice('fee_mode', 'flat', 'Flat', 'Same fee for every delivery', Icons.horizontal_rule_rounded),
          const SizedBox(width: 10),
          choice('fee_mode', 'distance', 'By distance', 'Base fee plus an amount per km',
              Icons.route_rounded),
        ]),
        const SizedBox(height: 12),
        if (!distance)
          _MoneyField(label: 'Delivery fee', value: d['flat_fee'] as int,
              keyName: 'flat_fee', onChanged: (v) => _set('flat_fee', v))
        else ...[
          Row(children: [
            Expanded(child: _MoneyField(label: 'Base fee', value: d['base_fee'] as int,
                keyName: 'base_fee', onChanged: (v) => _set('base_fee', v))),
            const SizedBox(width: 10),
            Expanded(child: _MoneyField(label: 'Per km', value: d['per_km'] as int,
                keyName: 'per_km', onChanged: (v) => _set('per_km', v))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _MoneyField(label: 'Minimum', value: d['min_fee'] as int,
                keyName: 'min_fee', onChanged: (v) => _set('min_fee', v))),
            const SizedBox(width: 10),
            Expanded(child: _MoneyField(label: 'Maximum', value: d['max_fee'] as int,
                keyName: 'max_fee', onChanged: (v) => _set('max_fee', v))),
          ]),
          const SizedBox(height: 8),
          Text(
            'Example: 3 km costs ${formatCedis(((d['base_fee'] as int) + 3 * (d['per_km'] as int)).clamp(d['min_fee'] as int, d['max_fee'] as int))}.'
            '${noLocation > 0 ? ' $noLocation restaurant${noLocation == 1 ? ' hasn\'t' : 's haven\'t'} set their location yet, so they use the flat fee (${formatCedis(d['flat_fee'] as int)}).' : ''}',
            style: TextStyle(color: textSec, fontSize: 12.5, height: 1.4),
          ),
          if (noLocation > 0) ...[
            const SizedBox(height: 10),
            _MoneyField(label: 'Flat fee (fallback)', value: d['flat_fee'] as int,
                keyName: 'flat_fee', onChanged: (v) => _set('flat_fee', v)),
          ],
          const SizedBox(height: 14),
          Text("If a customer doesn't share their location",
              style: TextStyle(color: textPri, fontWeight: FontWeight.w700, fontSize: 13.5)),
          const SizedBox(height: 8),
          Row(children: [
            choice('no_location_fee', 'max', 'Charge the maximum',
                'So typing a far address can\'t pay less', Icons.vertical_align_top_rounded),
            const SizedBox(width: 10),
            choice('no_location_fee', 'flat', 'Charge the flat fee',
                'Simpler, but far orders can pay less', Icons.horizontal_rule_rounded),
          ]),
        ],
        section("Riders' share", 'The part of each delivery fee the rider earns.'),
        Row(children: [
          Expanded(
            child: Slider(
              key: const Key('rider-share-slider'),
              value: ((d['rider_share_percent'] as num).toDouble()).clamp(0, 100),
              min: 0,
              max: 100,
              divisions: 20,
              label: percentLabel(d['rider_share_percent'] as num),
              activeColor: AppTheme.accentDeep,
              onChanged: _saving ? null : (v) => _set('rider_share_percent', v.round()),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(percentLabel(d['rider_share_percent'] as num),
                textAlign: TextAlign.right,
                style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ]),
        section('How riders are paid', 'You can switch any time.'),
        Row(children: [
          choice('payout_mode', 'weekly', 'Weekly', 'You pay riders from the Payouts tab',
              Icons.event_repeat_rounded),
          const SizedBox(width: 10),
          choice('payout_mode', 'automatic', 'Automatic', 'Paystack pays riders after each delivery',
              Icons.bolt_rounded),
        ]),
        if (automatic) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
            ),
            child: Text(
                'Automatic payouts send money from your Paystack balance, so keep it funded. '
                'In Paystack, turn off "Confirm transfers with OTP". Riders without a payout '
                'account stay on the Payouts tab until they add one.',
                style: TextStyle(color: textPri, fontSize: 12.5, height: 1.4)),
          ),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          key: const Key('delivery-settings-save'),
          label: _changed ? 'Save changes' : 'No changes',
          isLoading: _saving,
          onPressed: _changed && !_saving ? _save : null,
        ),
        if (history.isNotEmpty) ...[
          section('History', 'Most recent first.'),
          for (final change in history.take(10))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.history_rounded, size: 17, color: textSec),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_describe(change['settings'] as Map),
                      style: TextStyle(color: textPri, fontSize: 13)),
                ),
                Text('${change['changed_by'] ?? ''} · ${_when(change['changed_at'])}',
                    style: TextStyle(color: textSec, fontSize: 12)),
              ]),
            ),
        ],
      ],
    );
  }

  static String _describe(Map s) {
    final fee = s['fee_mode'] == 'distance'
        ? '${formatCedis(s['base_fee'] as int)} + ${formatCedis(s['per_km'] as int)}/km'
        : 'Flat ${formatCedis(s['flat_fee'] as int)}';
    return '$fee · riders ${percentLabel(s['rider_share_percent'] as num)} · '
        '${s['payout_mode'] == 'automatic' ? 'automatic' : 'weekly'}';
  }
}

/// A GH₵ amount entered in cedis, stored in pesewas.
class _MoneyField extends StatefulWidget {
  final String label;
  final String keyName;
  final int value;
  final ValueChanged<int> onChanged;
  const _MoneyField({required this.label, required this.keyName, required this.value,
      required this.onChanged});

  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  late final _ctrl = TextEditingController(text: (widget.value / 100).toStringAsFixed(2));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key('money-${widget.keyName}'),
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: widget.label, prefixText: 'GH₵ ', isDense: true),
      onChanged: (text) {
        final cedis = double.tryParse(text.trim());
        if (cedis != null && cedis >= 0) widget.onChanged((cedis * 100).round());
      },
    );
  }
}

class _RiderPayouts extends StatefulWidget {
  const _RiderPayouts();

  @override
  State<_RiderPayouts> createState() => _RiderPayoutsState();
}

class _RiderPayoutsState extends State<_RiderPayouts> {
  Map<String, dynamic>? _data;
  String? _error;
  final _busy = <int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getRiderPayouts(context.read<AuthProvider>().token!);
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

  Future<void> _pay(Map<String, dynamic> rider, String method) async {
    String? note;
    if (method == 'manual') {
      note = await showSettingsSheet<String>(context, _ManualPaymentForm(rider: rider));
      if (note == null) return;
    } else {
      final sure = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Pay ${rider['name']} ${formatCedis((rider['owed'] as num).toInt())}?'),
          content: Text('Paystack sends it to ${rider['account'] ?? 'their account'} '
              'from your Paystack balance.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                key: const Key('pay-rider-confirm'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Pay')),
          ],
        ),
      );
      if (sure != true) return;
    }
    if (!mounted) return;
    final id = rider['id'] as int;
    setState(() => _busy.add(id));
    try {
      final payout = await ApiService.payRider(
          context.read<AuthProvider>().token!, id, method, note: note);
      if (!mounted) return;
      final failed = payout['status'] == 'failed';
      showSettingsMessage(
          context,
          failed
              ? 'Paystack couldn\'t send it: ${payout['failure_reason'] ?? 'unknown error'}'
              : method == 'manual'
                  ? 'Recorded as paid.'
                  : 'Payment sent to ${rider['name']}.',
          isError: failed);
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy.remove(id));
      await _load();
    }
  }

  Future<void> _payAll() async {
    final riders = ((_data?['riders'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .where((r) => (r['owed'] as num) > 0 && r['active'] == true)
        .toList();
    if (riders.isEmpty) return;
    final total = riders.fold<int>(0, (sum, r) => sum + (r['owed'] as num).toInt());
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Pay ${riders.length} rider${riders.length == 1 ? '' : 's'} ${formatCedis(total)}?'),
        content: const Text('Each rider with a payout account is paid through Paystack. '
            'Riders without one are skipped.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              key: const Key('pay-all-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Pay all')),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    final token = context.read<AuthProvider>().token!;
    var sent = 0;
    for (final rider in riders) {
      setState(() => _busy.add(rider['id'] as int));
      try {
        final payout = await ApiService.payRider(token, rider['id'] as int, 'paystack');
        if (payout['status'] != 'failed') sent++;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(_busy.clear);
    showSettingsMessage(context,
        sent == riders.length ? 'All riders paid.' : '$sent of ${riders.length} paid. Check the failed ones below.',
        isError: sent != riders.length);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final data = _data;
    if (_error != null && data == null) {
      return EmptyState(
          icon: Icons.wifi_off_rounded,
          title: "Couldn't load payouts",
          subtitle: _error!,
          actionLabel: 'Retry',
          onAction: _load);
    }
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }
    final riders = (data['riders'] as List? ?? const []).cast<Map<String, dynamic>>();
    final recent = (data['recent'] as List? ?? const []).cast<Map<String, dynamic>>();
    final payable = riders.where((r) => (r['owed'] as num) > 0 && r['active'] == true).length;
    return Column(
      key: const Key('rider-payouts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Owed to riders', style: TextStyle(color: textSec, fontSize: 13)),
                Text(formatCedis((data['total_owed'] as num).toInt()),
                    key: const Key('riders-total-owed'),
                    style: TextStyle(color: textPri, fontSize: 26, fontWeight: FontWeight.w900)),
                Text(data['payout_mode'] == 'automatic' ? 'Mode: automatic' : 'Mode: weekly',
                    style: TextStyle(color: textSec, fontSize: 12)),
              ]),
            ),
            FilledButton(
              key: const Key('pay-all'),
              onPressed: payable == 0 || _busy.isNotEmpty ? null : _payAll,
              child: Text('Pay all ($payable)'),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        if (riders.isEmpty)
          Text('No riders yet.', style: TextStyle(color: textSec))
        else
          for (final r in riders)
            Container(
              key: Key('rider-payout-${r['id']}'),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${r['name']}',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(
                      '${formatCedis((r['owed'] as num).toInt())} for ${r['owed_deliveries']} '
                      'deliver${r['owed_deliveries'] == 1 ? 'y' : 'ies'}',
                      style: TextStyle(color: textSec, fontSize: 13),
                    ),
                    Text(r['account'] == null ? 'No payout account yet' : 'To ${r['account']}',
                        style: TextStyle(
                            color: r['account'] == null ? AppTheme.warning : textSec, fontSize: 12)),
                  ]),
                ),
                if (_busy.contains(r['id']))
                  const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                else if ((r['owed'] as num) > 0) ...[
                  TextButton(
                    key: Key('mark-paid-${r['id']}'),
                    onPressed: () => _pay(r, 'manual'),
                    child: const Text('Mark paid'),
                  ),
                  if (r['active'] == true)
                    FilledButton(
                      key: Key('pay-rider-${r['id']}'),
                      onPressed: () => _pay(r, 'paystack'),
                      child: const Text('Pay'),
                    ),
                ] else
                  const Text('All paid', style: TextStyle(color: AppTheme.success, fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
              ]),
            ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Recent payouts',
              style: TextStyle(color: textPri, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final p in recent.take(15))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(
                    p['status'] == 'paid'
                        ? Icons.check_circle_rounded
                        : p['status'] == 'failed'
                            ? Icons.error_rounded
                            : Icons.schedule_rounded,
                    size: 17,
                    color: p['status'] == 'paid'
                        ? AppTheme.success
                        : p['status'] == 'failed'
                            ? AppTheme.danger
                            : AppTheme.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${p['rider_name']} · ${formatCedis((p['amount'] as num).toInt())}'
                    '${p['method'] == 'manual' ? ' · marked paid' : ''}'
                    '${p['status'] == 'failed' ? ' · ${p['failure_reason'] ?? 'failed'}' : ''}',
                    style: TextStyle(color: textPri, fontSize: 13),
                  ),
                ),
                Text(_when(p['created_at']), style: TextStyle(color: textSec, fontSize: 12)),
              ]),
            ),
        ],
      ],
    );
  }
}

class _ManualPaymentForm extends StatefulWidget {
  final Map<String, dynamic> rider;
  const _ManualPaymentForm({required this.rider});

  @override
  State<_ManualPaymentForm> createState() => _ManualPaymentFormState();
}

class _ManualPaymentFormState extends State<_ManualPaymentForm> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: 'Mark ${widget.rider['name']} as paid',
          subtitle: 'For ${formatCedis((widget.rider['owed'] as num).toInt())} you paid another way. '
              'No money is sent by FindFood.',
        ),
        AppTextField(
          key: const Key('manual-note'),
          controller: _note,
          hint: 'How you paid, e.g. "MoMo from my phone, Friday"',
          prefixIcon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const Key('manual-confirm'),
          label: 'Mark as paid',
          onPressed: () => Navigator.of(context).pop(_note.text.trim()),
        ),
      ],
    );
  }
}
