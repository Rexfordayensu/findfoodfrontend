import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/models.dart' show formatCedis;
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import '../../widgets/live_refresh.dart';
import '../../widgets/rider_map.dart';
import '../../widgets/widgets.dart';

const _statusLabels = {
  'awaiting_payment': 'Awaiting payment',
  'pending': 'New',
  'preparing': 'Preparing',
  'ready': 'Ready',
  'out_for_delivery': 'On the way',
  'delivered': 'Delivered',
  'picked_up': 'Collected',
  'cancelled': 'Cancelled',
};

Color _statusColor(String status) => switch (status) {
      'pending' => AppTheme.info,
      'preparing' => AppTheme.warning,
      'ready' => AppTheme.accentDeep,
      'out_for_delivery' => const Color(0xFF8B5CF6),
      'delivered' || 'picked_up' => AppTheme.success,
      'cancelled' => AppTheme.danger,
      _ => const Color(0xFF9E9E9E),
    };

String _time(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  final now = DateTime.now();
  final hm = '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
  if (at.year == now.year && at.month == now.month && at.day == now.day) return hm;
  return '${at.day}/${at.month} $hm';
}

/// Admin → Orders: live orders, the stuck ones first, and what to do about them.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> with LiveRefresh<AdminOrdersPage> {
  String _view = 'attention';
  String _query = '';
  Map<String, dynamic>? _data;
  String? _error;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(_load);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getOrdersBoard(context.read<AuthProvider>().token!,
          view: _view, query: _view == 'all' ? _query : null);
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

  void _switch(String view) {
    setState(() {
      _view = view;
      _data = _data == null ? null : {..._data!, 'orders': const []};
    });
    _load();
  }

  Future<void> _open(Map<String, dynamic> order) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => OrderDeskSheet(orderId: order['id'] as int),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final counts = (_data?['counts'] as Map?) ?? const {};
    final orders = ((_data?['orders'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final textSec = AppColors.textSecondary(context);
    Widget tab(String view, String label, int? count) {
      final active = _view == view;
      return Expanded(
        child: GestureDetector(
          key: Key('orders-tab-$view'),
          onTap: () => _switch(view),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(count == null ? label : '$label ($count)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: active ? Colors.black : textSec, fontWeight: FontWeight.w700, fontSize: 13.5)),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Row(children: [
            Expanded(
              child: Text('Orders',
                  style: TextStyle(color: AppColors.textPrimary(context), fontSize: 28,
                      fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
            OutlinedButton.icon(
              key: const Key('orders-live-map'),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AdminLiveMapScreen())),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.border(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Live map'),
            ),
          ]),
          const SizedBox(height: 4),
          Text('Step in when an order is stuck: call people, find a rider, cancel or refund.',
              style: TextStyle(color: textSec, fontSize: 13.5, height: 1.4)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(children: [
              tab('attention', 'Needs attention', (counts['attention'] as num?)?.toInt()),
              tab('active', 'Live', (counts['active'] as num?)?.toInt()),
              tab('all', 'All', null),
            ]),
          ),
          if (_view == 'all') ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('orders-search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                _query = v.trim();
                _load();
              },
              decoration: InputDecoration(
                hintText: 'Order number, customer or restaurant',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () {
                    _query = _search.text.trim();
                    _load();
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (_error != null && _data == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load orders",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (_data == null)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
            )
          else if (orders.isEmpty)
            EmptyState(
              icon: _view == 'attention' ? Icons.check_circle_outline_rounded : Icons.receipt_long_outlined,
              title: _view == 'attention' ? 'All running smoothly' : 'No orders here',
              subtitle: _view == 'attention'
                  ? 'Nothing is stuck right now. Orders that wait too long show up here.'
                  : 'Live orders will appear here.',
            )
          else
            for (final o in orders) _OrderCard(order: o, onTap: () => _open(o)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = '${order['status']}';
    final attention = order['attention'] as Map?;
    final urgent = attention?['severity'] == 'urgent';
    final textSec = AppColors.textSecondary(context);
    final delivery = order['fulfillment_method'] == 'delivery';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: attention == null
                  ? AppColors.border(context)
                  : (urgent ? AppTheme.danger : AppTheme.warning).withValues(alpha: 0.6),
              width: attention == null ? 1 : 1.4),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('desk-order-${order['id']}'),
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (attention != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: (urgent ? AppTheme.danger : AppTheme.warning).withValues(alpha: 0.12),
                child: Row(children: [
                  Icon(urgent ? Icons.error_rounded : Icons.schedule_rounded,
                      size: 16, color: urgent ? AppTheme.danger : AppTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${attention['reason']} · ${attention['minutes']} min',
                        style: TextStyle(
                            color: urgent ? AppTheme.danger : const Color(0xFFB45309),
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('#${order['id']}',
                      style: TextStyle(color: AppColors.textPrimary(context),
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabels[status] ?? status,
                        style: TextStyle(color: _statusColor(status), fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                  const Spacer(),
                  Text(formatCedis((order['total_amount'] as num).toInt()),
                      style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 6),
                Text('${order['restaurant_name'] ?? 'Restaurant'} → ${order['customer_name'] ?? 'Customer'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13.5)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(delivery ? Icons.delivery_dining_rounded : Icons.storefront_rounded,
                      size: 15, color: textSec),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      delivery
                          ? (order['rider_name'] != null ? 'Rider: ${order['rider_name']}' : 'No rider yet')
                          : 'Pickup',
                      style: TextStyle(color: textSec, fontSize: 12.5),
                    ),
                  ),
                  Text(_time(order['created_at']), style: TextStyle(color: textSec, fontSize: 12)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// One order in full, with the admin's actions.
class OrderDeskSheet extends StatefulWidget {
  final int orderId;
  const OrderDeskSheet({super.key, required this.orderId});

  @override
  State<OrderDeskSheet> createState() => _OrderDeskSheetState();
}

class _OrderDeskSheetState extends State<OrderDeskSheet> {
  Map<String, dynamic>? _order;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order = await ApiService.getAdminOrderDetail(context.read<AuthProvider>().token!, widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _run(Future<void> Function(String token) action, String done) async {
    setState(() => _busy = true);
    try {
      await action(context.read<AuthProvider>().token!);
      if (mounted) showSettingsMessage(context, done);
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final order = _order!;
    final paid = (order['amount_paid'] as num).toInt();
    final result = await showSettingsSheet<({String reason, String refund})>(
        context, _CancelForm(paid: paid, canRefund: context.read<AuthProvider>().can('refunds')));
    if (result == null) return;
    await _run(
        (t) => ApiService.adminCancelOrder(t, widget.orderId, result.reason, result.refund),
        'Order #${widget.orderId} cancelled. Everyone has been told.');
  }

  Future<void> _release() async {
    final reason = await showSettingsSheet<String>(context, const _ReasonForm(
      title: 'Take the job back from the rider?',
      subtitle: 'The order goes back to the available jobs, and the rider is told not to collect it.',
      suggestions: ['Not answering calls', 'Rider asked to drop it', 'Too far away', 'Taking too long'],
      action: 'Take it back',
    ));
    if (reason == null) return;
    await _run((t) => ApiService.adminReleaseRider(t, widget.orderId, reason),
        'The job is open for other riders again.');
  }

  Future<void> _offer() async {
    final riderId = await showSettingsSheet<int>(context, _RiderChooser(orderId: widget.orderId));
    if (riderId == null) return;
    await _run((t) => ApiService.adminOfferRider(t, widget.orderId, riderId),
        'Rider asked. They have 3 minutes to answer.');
  }

  Future<void> _refund() async {
    final order = _order!;
    final result = await showSettingsSheet<({int amount, String method, String reason})>(
        context, _RefundForm(paid: (order['amount_paid'] as num).toInt(),
            limit: (order['refund_limit'] as num?)?.toInt()));
    if (result == null) return;
    await _run((t) => ApiService.adminRefundOrder(t, widget.orderId, result.amount, result.method, result.reason),
        '${formatCedis(result.amount)} sent back to the customer.');
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final auth = context.read<AuthProvider>();
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(title, style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 15)),
        );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, controller) {
        if (order == null) {
          return Center(
            child: _error != null
                ? Text(_error!, style: TextStyle(color: textSec))
                : const CircularProgressIndicator(color: AppTheme.accent),
          );
        }
        final can = (order['can'] as Map?) ?? const {};
        final attention = order['attention'] as Map?;
        final status = '${order['status']}';
        final people = [
          ('Customer', order['customer'] as Map?, Icons.person_rounded),
          ('Restaurant', order['restaurant'] as Map?, Icons.storefront_rounded),
          ('Rider', order['rider'] as Map?, Icons.delivery_dining_rounded),
        ];
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Text('Order #${order['id']}',
                  style: TextStyle(color: textPri, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabels[status] ?? status,
                    style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ]),
            if (order['cancel_reason'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Cancelled by ${order['cancelled_by'] ?? 'someone'}: ${order['cancel_reason']}',
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
              ),
            if (attention != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${attention['reason']} for ${attention['minutes']} minutes.',
                    style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w700)),
              ),
            ],
            if (order['rider'] != null &&
                const ['pending', 'preparing', 'ready', 'out_for_delivery'].contains(status)) ...[
              section('Where the rider is'),
              RiderMapCard(orderId: order['id'] as int, viewer: MapViewer.admin, height: 170),
            ],
            section('People'),
            for (final (label, person, icon) in people)
              if (person != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Icon(icon, size: 20, color: textSec),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${person['name'] ?? label}',
                            style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
                        Text(
                            [label, person['phone'] ?? 'no phone saved', if (label == 'Restaurant') person['address']]
                                .whereType<String>()
                                .join(' · '),
                            style: TextStyle(color: textSec, fontSize: 12)),
                      ]),
                    ),
                    if ((person['phone'] ?? '').toString().isNotEmpty)
                      IconButton.filledTonal(
                        key: Key('call-${label.toLowerCase()}'),
                        tooltip: 'Call $label',
                        onPressed: () => launchUrlString('tel:${'${person['phone']}'.replaceAll(' ', '')}'),
                        icon: const Icon(Icons.call_rounded, size: 18),
                      ),
                  ]),
                ),
            if (order['fulfillment_method'] == 'delivery' && order['delivery_address'] != null)
              Text('Delivering to ${order['delivery_address']}', style: TextStyle(color: textSec, fontSize: 12.5)),
            if (auth.can('orders.manage') || auth.can('refunds')) ...[
              section('Actions'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (can['offer_rider'] == true && auth.can('orders.manage'))
                  _ActionChip(key: const Key('desk-offer'), icon: Icons.person_search_rounded,
                      label: 'Ask a rider', onTap: _busy ? null : _offer),
                if (can['release_rider'] == true && auth.can('orders.manage'))
                  _ActionChip(key: const Key('desk-release'), icon: Icons.person_remove_rounded,
                      label: 'Take job from rider', onTap: _busy ? null : _release),
                if (can['refund'] == true && auth.can('refunds'))
                  _ActionChip(key: const Key('desk-refund'), icon: Icons.currency_exchange_rounded,
                      label: 'Refund', onTap: _busy ? null : _refund),
                if (can['cancel'] == true && auth.can('orders.manage'))
                  _ActionChip(key: const Key('desk-cancel'), icon: Icons.cancel_outlined,
                      label: 'Cancel order', danger: true, onTap: _busy ? null : _cancel),
              ]),
              if (order['offer'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'Waiting for ${(order['offer'] as Map)['rider_name']} to answer '
                      '(${(order['offer'] as Map)['seconds_left']}s left).',
                      style: TextStyle(color: AppColors.accentText(context), fontWeight: FontWeight.w600)),
                ),
            ],
            section('Food'),
            for (final item in (order['items'] as List).cast<Map>())
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Text('${item['quantity']}×  ', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
                  Expanded(child: Text('${item['name']}', style: TextStyle(color: textPri))),
                  Text(formatCedis(((item['price'] as num) * (item['quantity'] as num)).toInt()),
                      style: TextStyle(color: textSec)),
                ]),
              ),
            if (order['kitchen_note'] != null)
              Text('Note: ${order['kitchen_note']}', style: TextStyle(color: textSec, fontStyle: FontStyle.italic)),
            section('Money'),
            _kv(context, 'Total', formatCedis((order['total_amount'] as num).toInt())),
            if ((order['delivery_fee'] as num? ?? 0) > 0)
              _kv(context, 'Delivery fee', formatCedis((order['delivery_fee'] as num).toInt())),
            _kv(context, 'Paid', formatCedis((order['amount_paid'] as num).toInt())),
            for (final p in (order['payments'] as List).cast<Map>())
              _kv(context, '${p['provider']} · ${p['reference']}',
                  '${formatCedis((p['amount'] as num).toInt())} · ${p['status']}', small: true),
            section('What happened'),
            for (final t in (order['timeline'] as List).cast<Map>())
              _kv(context, '${t['label']}', _time(t['at'])),
            for (final h in (order['admin_history'] as List).cast<Map>())
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${h['summary']} · ${h['admin_name'] ?? 'admin'} · ${_time(h['at'])}',
                    style: TextStyle(color: AppColors.accentText(context), fontSize: 12.5)),
              ),
          ],
        );
      },
    );
  }

  Widget _kv(BuildContext context, String k, String v, {bool small = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(
            child: Text(k,
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: small ? 12 : 13.5)),
          ),
          Text(v,
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: small ? 12 : 13.5,
                  fontWeight: small ? FontWeight.w500 : FontWeight.w700)),
        ]),
      );
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback? onTap;
  const _ActionChip({super.key, required this.icon, required this.label, this.danger = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.danger : AppColors.textPrimary(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: danger ? AppTheme.danger.withValues(alpha: 0.5) : AppColors.border(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

/// A reason picker: quick suggestions, or type one.
class _ReasonForm extends StatefulWidget {
  final String title, subtitle, action;
  final List<String> suggestions;
  const _ReasonForm({required this.title, required this.subtitle, required this.suggestions, required this.action});

  @override
  State<_ReasonForm> createState() => _ReasonFormState();
}

class _ReasonFormState extends State<_ReasonForm> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      SheetHeader(title: widget.title, subtitle: widget.subtitle),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in widget.suggestions)
          ActionChip(label: Text(s), onPressed: () => setState(() => _reason.text = s)),
      ]),
      const SizedBox(height: 12),
      AppTextField(key: const Key('reason-field'), controller: _reason, hint: 'Reason',
          prefixIcon: Icons.edit_note_rounded),
      const SizedBox(height: 14),
      PrimaryButton(
        key: const Key('reason-confirm'),
        label: widget.action,
        onPressed: () {
          final reason = _reason.text.trim();
          if (reason.length < 3) {
            showSettingsMessage(context, 'Add a short reason.', isError: true);
            return;
          }
          Navigator.of(context).pop(reason);
        },
      ),
    ]);
  }
}

class _CancelForm extends StatefulWidget {
  final int paid;
  final bool canRefund;
  const _CancelForm({required this.paid, required this.canRefund});

  @override
  State<_CancelForm> createState() => _CancelFormState();
}

class _CancelFormState extends State<_CancelForm> {
  final _reason = TextEditingController();
  late String _refund = widget.paid > 0 && widget.canRefund ? 'original' : 'none';

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      if (widget.paid > 0 && widget.canRefund) ...[
        ('original', 'Refund to their card or MoMo', 'Takes a few days to show'),
        ('credit', 'Give FindFood credit', 'Instant; they can use it on their next order'),
      ],
      ('none', widget.paid > 0 ? 'No refund' : 'Nothing was paid', widget.paid > 0 ? 'e.g. fraud or a duplicate' : ''),
    ];
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      SheetHeader(
        title: 'Cancel this order?',
        subtitle: widget.paid > 0
            ? 'The customer paid ${formatCedis(widget.paid)}. The customer, restaurant and rider are all told.'
            : 'The customer, restaurant and rider are all told.',
      ),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in ['Restaurant closed', 'No rider available', 'Customer asked to cancel',
            'Customer unreachable', 'Duplicate order'])
          ActionChip(label: Text(s), onPressed: () => setState(() => _reason.text = s)),
      ]),
      const SizedBox(height: 12),
      AppTextField(key: const Key('cancel-reason'), controller: _reason, hint: 'Reason (shown to the customer)',
          prefixIcon: Icons.edit_note_rounded),
      const SizedBox(height: 12),
      RadioGroup<String>(
        groupValue: _refund,
        onChanged: (v) => setState(() => _refund = v!),
        child: Column(children: [
          for (final (value, label, detail) in options)
            RadioListTile<String>(
              key: Key('cancel-refund-$value'),
              value: value,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: detail.isEmpty ? null : Text(detail),
            ),
        ]),
      ),
      if (widget.paid > 0 && !widget.canRefund)
        Text('Your role can cancel without a refund only. Ask support or finance to refund it.',
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
      const SizedBox(height: 10),
      PrimaryButton(
        key: const Key('cancel-confirm'),
        label: 'Cancel order',
        onPressed: () {
          final reason = _reason.text.trim();
          if (reason.length < 3) {
            showSettingsMessage(context, 'Add a short reason for the customer.', isError: true);
            return;
          }
          Navigator.of(context).pop((reason: reason, refund: _refund));
        },
      ),
    ]);
  }
}

class _RefundForm extends StatefulWidget {
  final int paid;
  final int? limit;
  const _RefundForm({required this.paid, required this.limit});

  @override
  State<_RefundForm> createState() => _RefundFormState();
}

class _RefundFormState extends State<_RefundForm> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  String _method = 'credit';

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      SheetHeader(
        title: 'Refund without cancelling',
        subtitle: 'For a late delivery, a missing drink... The customer paid ${formatCedis(widget.paid)}.'
            '${widget.limit != null ? ' Your limit is ${formatCedis(widget.limit!)} per order.' : ''}',
      ),
      TextField(
        key: const Key('refund-amount'),
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Amount', prefixText: 'GH₵ '),
      ),
      const SizedBox(height: 10),
      AppTextField(key: const Key('refund-reason'), controller: _reason, hint: 'Reason',
          prefixIcon: Icons.edit_note_rounded),
      RadioGroup<String>(
        groupValue: _method,
        onChanged: (v) => setState(() => _method = v!),
        child: const Column(children: [
          RadioListTile<String>(
            value: 'credit', contentPadding: EdgeInsets.zero,
            title: Text('FindFood credit', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('Instant, for their next order'),
          ),
          RadioListTile<String>(
            value: 'original', contentPadding: EdgeInsets.zero,
            title: Text('Card or MoMo', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('Takes a few days to show'),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      PrimaryButton(
        key: const Key('refund-confirm'),
        label: 'Send refund',
        onPressed: () {
          final cedis = double.tryParse(_amount.text.trim());
          final reason = _reason.text.trim();
          if (cedis == null || cedis <= 0 || reason.length < 3) {
            showSettingsMessage(context, 'Enter an amount and a reason.', isError: true);
            return;
          }
          Navigator.of(context).pop((amount: (cedis * 100).round(), method: _method, reason: reason));
        },
      ),
    ]);
  }
}

class _RiderChooser extends StatefulWidget {
  final int orderId;
  const _RiderChooser({required this.orderId});

  @override
  State<_RiderChooser> createState() => _RiderChooserState();
}

class _RiderChooserState extends State<_RiderChooser> {
  List<Map<String, dynamic>>? _riders;
  String? _error;

  @override
  void initState() {
    super.initState();
    ApiService.adminOrderRiders(context.read<AuthProvider>().token!, widget.orderId).then((r) {
      if (mounted) setState(() => _riders = r);
    }).catchError((Object e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    });
  }

  @override
  Widget build(BuildContext context) {
    final riders = _riders;
    final textSec = AppColors.textSecondary(context);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHeader(title: 'Ask a rider', subtitle: 'They get 3 minutes to accept. Available riders first.'),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: AppTheme.danger))
      else if (riders == null)
        const Center(child: CircularProgressIndicator(color: AppTheme.accent))
      else if (riders.isEmpty)
        Text('No riders yet.', style: TextStyle(color: textSec))
      else
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView(shrinkWrap: true, children: [
            for (final r in riders)
              ListTile(
                key: Key('choose-rider-${r['id']}'),
                contentPadding: EdgeInsets.zero,
                enabled: r['eligible'] == true,
                leading: Icon(Icons.circle, size: 12,
                    color: r['online'] == true ? AppTheme.success : AppColors.border(context)),
                title: Text('${r['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(r['eligible'] == true
                    ? '${r['online'] == true ? 'Online' : 'Offline'} · ${r['active_deliveries']} active'
                    : '${r['reason']}'),
                onTap: () => Navigator.of(context).pop(r['id'] as int),
              ),
          ]),
        ),
    ]);
  }
}
