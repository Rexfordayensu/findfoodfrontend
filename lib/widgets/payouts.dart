import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import 'widgets.dart';

/// "MTN Mobile Money ••4567" for a payout status, or null if none.
String? payoutAccountLabel(Map<String, dynamic>? payout) {
  if (payout == null || payout['active'] != true) return null;
  return '${payout['provider_name'] ?? 'Account'} ••${payout['account_last4'] ?? ''}';
}

/// Where the restaurant (or, with [rider], the rider) is paid. Resolves to
/// the new status once saved.
Future<Map<String, dynamic>?> showPayoutSheet(BuildContext context, {bool rider = false}) =>
    showSettingsSheet<Map<String, dynamic>>(context, _PayoutForm(rider: rider));

class _PayoutForm extends StatefulWidget {
  final bool rider;
  const _PayoutForm({this.rider = false});

  @override
  State<_PayoutForm> createState() => _PayoutFormState();
}

class _PayoutFormState extends State<_PayoutForm> {
  final _number = TextEditingController();
  String _type = 'momo';
  String? _provider;
  List<Map<String, dynamic>>? _providers;
  Map<String, dynamic>? _current;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token!;
    (widget.rider ? ApiService.getMyRiderPayout(token) : ApiService.getMyPayout(token))
        .then((status) {
      if (mounted) setState(() => _current = status);
    }).catchError((_) {});
    _loadProviders();
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _providers = null;
      _provider = null;
      _error = null;
    });
    try {
      final list = await ApiService.getPayoutProviders(
          context.read<AuthProvider>().token!, _type);
      if (mounted) setState(() => _providers = list);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _save() async {
    if (_provider == null) {
      showSettingsMessage(
          context, _type == 'momo' ? 'Choose your network.' : 'Choose your bank.',
          isError: true);
      return;
    }
    if (_number.text.replaceAll(RegExp(r'\D'), '').length < 9) {
      showSettingsMessage(context,
          _type == 'momo' ? 'Enter your mobile money number.' : 'Enter your account number.',
          isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final status = await (widget.rider ? ApiService.setMyRiderPayout : ApiService.setMyPayout)(
        token: context.read<AuthProvider>().token!,
        type: _type,
        providerCode: _provider!,
        accountNumber: _number.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(status);
      final name = status['account_name'];
      final where = widget.rider
          ? 'Your delivery pay goes there.'
          : 'Your share of each order goes there automatically.';
      showSettingsMessage(
          context, name == null ? 'Payouts set up. $where' : 'Payouts set up for $name. $where');
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
    final current = _current;
    final share = (current?['share_percent'] as num?)?.round() ?? 85;
    Widget typeChip(String value, String label, IconData icon) {
      final active = _type == value;
      return Expanded(
        child: GestureDetector(
          key: Key('payout-type-$value'),
          onTap: () {
            if (_type == value) return;
            setState(() => _type = value);
            _loadProviders();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 17, color: active ? Colors.black : textSec),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.black : textSec,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5)),
            ]),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: 'Payouts',
          subtitle: widget.rider
              ? 'Where FindFood sends your delivery pay.'
              : 'You receive $share% of every order, paid automatically by Paystack.',
        ),
        if (payoutAccountLabel(current) != null) ...[
          Container(
            key: const Key('payout-current'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.35)),
            ),
            child: Row(children: [
              const Icon(Icons.verified_rounded, color: AppTheme.success, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Paid to ${payoutAccountLabel(current)}'
                  '${current?['account_name'] == null ? '' : ' (${current!['account_name']})'}',
                  style: TextStyle(color: textPri, fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Text('To change it, enter the new account below.',
              style: TextStyle(color: textSec, fontSize: 12)),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(children: [
            typeChip('momo', 'Mobile money', Icons.phone_android_rounded),
            typeChip('bank', 'Bank account', Icons.account_balance_rounded),
          ]),
        ),
        const SizedBox(height: 14),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13))
        else if (_providers == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          )
        else if (_type == 'momo') ...[
          Text('Your network', style: TextStyle(color: textSec, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final p in _providers!)
            _NetworkTile(
              code: '${p['code']}',
              name: '${p['name']}',
              selected: _provider == '${p['code']}',
              onTap: () => setState(() => _provider = '${p['code']}'),
            ),
        ] else
          _BankField(
            banks: _providers!,
            selected: _provider,
            onChanged: (code) => setState(() => _provider = code),
          ),
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('payout-number'),
          controller: _number,
          hint: _type == 'momo' ? 'MoMo number, e.g. 0241234567' : 'Account number',
          prefixIcon: _type == 'momo' ? Icons.phone_outlined : Icons.numbers_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 8),
        Text(
            '${widget.rider ? 'Use an account in your name.' : 'Use an account in your or your business\'s name.'} Paystack checks it '
            'before payouts start. FindFood keeps only the last 4 digits.',
            style: TextStyle(color: textSec, fontSize: 12, height: 1.4)),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const Key('payout-save'),
          label: payoutAccountLabel(current) == null ? 'Start getting paid' : 'Update payout account',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

/// Brand colours for Ghana's mobile money networks, so each is easy to spot.
({Color bg, Color fg, String mark}) _networkLook(String code, String name) {
  final key = '$code $name'.toLowerCase();
  if (key.contains('mtn')) return (bg: const Color(0xFFFFCC00), fg: Colors.black, mark: 'MTN');
  if (key.contains('vod') || key.contains('telecel')) {
    return (bg: const Color(0xFFE4002B), fg: Colors.white, mark: 'T');
  }
  if (key.contains('airtel') || key.contains('tigo') || key.contains('atl')) {
    return (bg: const Color(0xFF1B3F94), fg: Colors.white, mark: 'AT');
  }
  final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
  return (bg: AppTheme.accent, fg: Colors.black, mark: initial);
}

/// One mobile money network to choose: logo, name, and a tick when chosen.
class _NetworkTile extends StatelessWidget {
  final String code, name;
  final bool selected;
  final VoidCallback onTap;
  const _NetworkTile({required this.code, required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final look = _networkLook(code, name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppTheme.accent.withValues(alpha: 0.12) : AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: selected ? AppTheme.accentDeep : AppColors.border(context),
              width: selected ? 1.6 : 1),
        ),
        child: InkWell(
          key: Key('payout-network-$code'),
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: look.bg, borderRadius: BorderRadius.circular(10)),
                child: Text(look.mark,
                    style: TextStyle(
                        color: look.fg,
                        fontSize: look.mark.length > 2 ? 11 : 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? const Icon(Icons.check_circle_rounded,
                        key: ValueKey('on'), color: AppTheme.accentDeep, size: 22)
                    : Icon(Icons.circle_outlined,
                        key: const ValueKey('off'), color: AppColors.border(context), size: 22),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The chosen bank; tapping opens a searchable list (there are many banks).
class _BankField extends StatelessWidget {
  final List<Map<String, dynamic>> banks;
  final String? selected;
  final ValueChanged<String> onChanged;
  const _BankField({required this.banks, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final name = banks.where((b) => '${b['code']}' == selected).map((b) => '${b['name']}').firstOrNull;
    return Material(
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: InkWell(
        key: const Key('payout-provider'),
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final code = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.sheet(context),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _BankSearch(banks: banks, selected: selected),
          );
          if (code != null) onChanged(code);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(children: [
            Icon(Icons.account_balance_outlined, color: AppColors.textSecondary(context), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name ?? 'Choose your bank',
                  style: TextStyle(
                      color: name == null ? AppColors.textHint(context) : AppColors.textPrimary(context),
                      fontSize: 15,
                      fontWeight: name == null ? FontWeight.w500 : FontWeight.w700)),
            ),
            Icon(Icons.expand_more_rounded, color: AppColors.textSecondary(context)),
          ]),
        ),
      ),
    );
  }
}

class _BankSearch extends StatefulWidget {
  final List<Map<String, dynamic>> banks;
  final String? selected;
  const _BankSearch({required this.banks, required this.selected});

  @override
  State<_BankSearch> createState() => _BankSearchState();
}

class _BankSearchState extends State<_BankSearch> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = widget.banks.where((b) => '${b['name']}'.toLowerCase().contains(q)).toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: TextField(
              key: const Key('bank-search'),
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search banks',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? Center(
                    child: Text('No bank matches "$_query"',
                        style: TextStyle(color: AppColors.textSecondary(context))))
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (_, i) {
                      final bank = shown[i];
                      final chosen = '${bank['code']}' == widget.selected;
                      return ListTile(
                        title: Text('${bank['name']}',
                            style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: chosen ? FontWeight.w800 : FontWeight.w500)),
                        trailing: chosen
                            ? const Icon(Icons.check_rounded, color: AppTheme.accentDeep)
                            : null,
                        onTap: () => Navigator.of(context).pop('${bank['code']}'),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

/// On the Orders tab until a payout account is added.
class PayoutReminderBanner extends StatefulWidget {
  const PayoutReminderBanner({super.key});

  @override
  State<PayoutReminderBanner> createState() => _PayoutReminderBannerState();
}

class _PayoutReminderBannerState extends State<PayoutReminderBanner> {
  bool _needed = false;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      ApiService.getMyPayout(token).then((status) {
        if (mounted) setState(() => _needed = status['active'] != true);
      }).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_needed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Material(
        color: AppTheme.accent.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.45)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('payout-reminder'),
          onTap: () async {
            final status = await showPayoutSheet(context);
            if (status != null && mounted) setState(() => _needed = status['active'] != true);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accentDeep, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Add your MoMo or bank to get paid automatically',
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5)),
              ),
              const Icon(Icons.chevron_right_rounded),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The restaurant's share, what Paystack paid out, and what's owed.
class EarningsSplitCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSetUpPayouts;
  const EarningsSplitCard({super.key, required this.data, required this.onSetUpPayouts});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final payout = data['payout'] as Map<String, dynamic>?;
    final share = (payout?['share_percent'] as num?)?.round() ?? 85;
    final commission = (payout?['commission_percent'] as num?)?.round() ?? 15;
    final earnings = (data['your_earnings'] as num?)?.toInt() ?? 0;
    final paid = (data['paid_automatically'] as num?)?.toInt() ?? 0;
    final owed = (data['owed_by_findfood'] as num?)?.toInt() ?? 0;
    final sales = (data['total_revenue'] as num?)?.toInt() ?? 0;
    final account = payoutAccountLabel(payout);
    Widget row(String label, String value, {Color? color, Key? key}) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(key: key, children: [
            Expanded(child: Text(label, style: TextStyle(color: textSec, fontSize: 13))),
            Text(value,
                style: TextStyle(
                    color: color ?? textPri, fontSize: 13.5, fontWeight: FontWeight.w700)),
          ]),
        );
    return Container(
      key: const Key('earnings-split'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your earnings · $share% of sales', style: TextStyle(color: textSec, fontSize: 13)),
        const SizedBox(height: 6),
        Text(formatCedis(earnings),
            style: TextStyle(
                color: AppColors.accentText(context),
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1)),
        const SizedBox(height: 6),
        row('Sales from ${data['delivered_orders'] ?? 0} delivered orders', formatCedis(sales)),
        row('FindFood commission ($commission%)', '−${formatCedis(sales - earnings)}'),
        Divider(height: 22, color: AppColors.border(context)),
        row(account == null ? 'Paid automatically' : 'Paid to $account', formatCedis(paid),
            color: AppTheme.success, key: const Key('earnings-paid')),
        if (owed > 0)
          row('FindFood owes you', formatCedis(owed),
              color: AppTheme.warning, key: const Key('earnings-owed')),
        if (account == null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('earnings-setup-payouts'),
              onPressed: onSetUpPayouts,
              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
              label: const Text('Add your MoMo or bank to get paid'),
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Text('Paystack sends your share after each order, usually the next working day.',
              style: TextStyle(color: textSec, fontSize: 12, height: 1.4)),
        ],
      ]),
    );
  }
}
