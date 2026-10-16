import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart' show formatCedis;
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../utils/web_url_helper.dart' show downloadTextFile;
import '../../widgets/account_settings.dart' show showSettingsMessage;
import '../../widgets/widgets.dart';

/// Admin → Finance: money in and out for a period, and a CSV for the accountant.
class FinancePage extends StatefulWidget {
  /// For tests; defaults to today.
  final DateTime? today;
  const FinancePage({super.key, this.today});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  String _range = '30d';
  Map<String, dynamic>? _data;
  String? _error;
  bool _downloading = false;

  DateTime get _today {
    final t = widget.today ?? DateTime.now().toUtc();
    return DateTime(t.year, t.month, t.day);
  }

  (DateTime, DateTime) get _dates {
    final today = _today;
    return switch (_range) {
      'today' => (today, today),
      '7d' => (today.subtract(const Duration(days: 6)), today),
      'month' => (DateTime(today.year, today.month), today),
      'last_month' => (
          DateTime(today.year, today.month - 1),
          DateTime(today.year, today.month, 0)
        ),
      _ => (today.subtract(const Duration(days: 29)), today),
    };
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final (start, end) = _dates;
    try {
      final data = await ApiService.getFinance(
          context.read<AuthProvider>().token!, start, end);
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

  Future<void> _download() async {
    final (start, end) = _dates;
    setState(() => _downloading = true);
    try {
      final csv = await ApiService.getFinanceCsv(
          context.read<AuthProvider>().token!, start, end);
      final name = 'findfood-payments-${_iso(start)}-to-${_iso(end)}.csv';
      final saved = await downloadTextFile(name, csv);
      if (!mounted) return;
      if (saved) {
        showSettingsMessage(
            context, 'Downloaded $name. Open it with Excel or Google Sheets.');
      } else {
        await Clipboard.setData(ClipboardData(text: csv));
        if (mounted) {
          showSettingsMessage(
              context, 'Copied the payments. Paste them into a spreadsheet.');
        }
      }
    } catch (e) {
      if (mounted) {
        showSettingsMessage(context, friendlyMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    int v(String key) => (data?[key] as num?)?.toInt() ?? 0;

    Widget tile(String label, int amount, String hint,
            {Color? color, Key? key}) =>
        Container(
          key: key,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    color: textSec,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(formatCedis(amount),
                  style: TextStyle(
                      color: color ?? textPri,
                      fontSize: 19,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 2),
            Text(hint,
                maxLines: 2,
                style: TextStyle(color: textSec, fontSize: 11.5, height: 1.3)),
          ]),
        );

    final daily =
        ((data?['daily'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final peak = daily.fold<int>(
        1,
        (m, d) => (d['customers_paid'] as num).toInt() > m
            ? (d['customers_paid'] as num).toInt()
            : m);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finance',
                        style: TextStyle(
                            color: textPri,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(
                        'What came in, what went out, and a file for your accountant.',
                        style: TextStyle(
                            color: textSec, fontSize: 13.5, height: 1.4)),
                  ]),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('finance-download'),
              onPressed: _downloading || data == null ? null : _download,
              icon: _downloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download_rounded, size: 18),
              label: const Text('Excel'),
            ),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (value, label) in [
              ('today', 'Today'),
              ('7d', '7 days'),
              ('30d', '30 days'),
              ('month', 'This month'),
              ('last_month', 'Last month'),
            ])
              ChoiceChip(
                key: Key('finance-range-$value'),
                label: Text(label),
                selected: _range == value,
                onSelected: (_) {
                  setState(() => _range = value);
                  _load();
                },
              ),
          ]),
          const SizedBox(height: 16),
          if (_error != null && data == null)
            EmptyState(
                icon: Icons.wifi_off_rounded,
                title: "Couldn't load the figures",
                subtitle: _error!,
                actionLabel: 'Retry',
                onAction: _load)
          else if (data == null)
            const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.accent)))
          else ...[
            Container(
              key: const Key('finance-headline'),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customers paid',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(formatCedis(v('customers_paid')),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                        '${v('orders')} order${v('orders') == 1 ? '' : 's'} · '
                        '${formatCedis(v('credit_used'))} of it in FindFood credit',
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13)),
                  ]),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 900 ? 4 : 2;
              final width =
                  (constraints.maxWidth - 10 * (columns - 1)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final t in <Widget>[
                    tile('FindFood keeps (estimate)', v('findfood_estimate'),
                        'Commission + delivery fees, less rider pay and refunds',
                        color: AppTheme.success,
                        key: const Key('finance-estimate')),
                    tile('Commission', v('commission'),
                        'Your share of the food'),
                    tile('Delivery fees', v('delivery_fees'),
                        'Paid by customers'),
                    tile('Food sales', v('food_sales'), 'Before commission'),
                    tile(
                        'Paid to restaurants',
                        v('paid_to_restaurants_automatically'),
                        'Sent by Paystack automatically'),
                    tile('Owed to restaurants', v('owed_to_restaurants'),
                        'Collected by FindFood, not yet passed on',
                        color: v('owed_to_restaurants') > 0
                            ? AppTheme.warning
                            : null),
                    tile('Rider pay earned', v('rider_pay_earned'),
                        '${formatCedis(v('rider_pay_paid'))} paid out'),
                    tile(
                        'Refunds',
                        v('refunds_to_cards') + v('refunds_as_credit'),
                        '${formatCedis(v('refunds_as_credit'))} as FindFood credit'),
                  ])
                    SizedBox(width: width, child: t)
                ],
              );
            }),
            if (daily.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Day by day',
                  style: TextStyle(
                      color: textPri,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final d in daily.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    SizedBox(
                        width: 54,
                        child: Text(
                            '${d['date']}'.substring(5).replaceFirst('-', '/'),
                            style: TextStyle(color: textSec, fontSize: 12.5))),
                    Expanded(
                      child: LayoutBuilder(builder: (context, c) {
                        final width = c.maxWidth *
                            ((d['customers_paid'] as num) / peak)
                                .clamp(0.02, 1.0);
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: width,
                            height: 10,
                            decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 108,
                      child: Text(
                        '${formatCedis((d['customers_paid'] as num).toInt())} · ${d['orders']}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: textPri,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
            ],
            const SizedBox(height: 10),
            Text(
                'Dates are in Ghana time. Payments count on the day they went through.',
                style: TextStyle(color: textSec, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
