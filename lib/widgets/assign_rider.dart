import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/notifications_provider.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import 'live_refresh.dart';
import 'widgets.dart';

/// "m:ss" for a countdown.
String countdown(Duration left) {
  final seconds = left.inSeconds.clamp(0, 359999);
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// Rebuilds every second until [until], showing the time left.
class Countdown extends StatefulWidget {
  final DateTime until;
  final Widget Function(BuildContext context, Duration left) builder;
  const Countdown({super.key, required this.until, required this.builder});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
      if (DateTime.now().isAfter(widget.until)) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.until.difference(DateTime.now());
    return widget.builder(context, left.isNegative ? Duration.zero : left);
  }
}

/// A small round "call" button for a phone number.
class CallButton extends StatelessWidget {
  final String phone;
  final String who;
  const CallButton({super.key, required this.phone, required this.who});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Call $who ($phone)',
      child: InkResponse(
        onTap: () => launchUrlString('tel:${phone.replaceAll(' ', '')}'),
        radius: 18,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.call_rounded, color: AppTheme.success, size: 16),
        ),
      ),
    );
  }
}

// ── Restaurant: choose a rider ───────────────────────────────────────────────

/// Under a delivery order that still needs a rider: "Assign rider", or the
/// request the restaurant is waiting on (with time left and Cancel).
class RiderAssignmentRow extends StatelessWidget {
  final Order order;
  final Future<void> Function() onChanged;
  const RiderAssignmentRow({super.key, required this.order, required this.onChanged});

  Future<void> _cancel(BuildContext context) async {
    try {
      await ApiService.withdrawRiderOffer(context.read<AuthProvider>().token!, order.id);
      await onChanged();
    } catch (e) {
      if (context.mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asked = order.offeredRiderName;
    final until = order.offerExpiresAt;
    if (asked != null && until != null) {
      return Container(
        key: Key('rider-offer-${order.id}'),
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentDeep),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Countdown(
              until: until,
              builder: (context, left) => Text(
                'Waiting for $asked to accept · ${countdown(left)}',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          TextButton(
            key: Key('rider-offer-cancel-${order.id}'),
            onPressed: () => _cancel(context),
            child: const Text('Cancel'),
          ),
        ]),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: Key('assign-rider-${order.id}'),
        onPressed: () async {
          if (await showAssignRiderSheet(context, order)) await onChanged();
        },
        icon: const Icon(Icons.two_wheeler_rounded, size: 18),
        label: const Text('Assign rider'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary(context),
          side: BorderSide(color: AppColors.border(context)),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Lists riders for the order; picking one sends them a request. Resolves to
/// true once a request was sent.
Future<bool> showAssignRiderSheet(BuildContext context, Order order) async =>
    await showSettingsSheet<bool>(context, _RiderPicker(order: order)) ?? false;

class _RiderPicker extends StatefulWidget {
  final Order order;
  const _RiderPicker({required this.order});

  @override
  State<_RiderPicker> createState() => _RiderPickerState();
}

class _RiderPickerState extends State<_RiderPicker> {
  List<Map<String, dynamic>>? _riders;
  String? _error;
  int? _sending;
  bool _showUnavailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await ApiService.getOrderRiders(context.read<AuthProvider>().token!, widget.order.id);
      if (!mounted) return;
      setState(() {
        _riders = List<Map<String, dynamic>>.from(data['riders'] as List? ?? const []);
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _ask(Map<String, dynamic> rider) async {
    final name = '${rider['name']}';
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Ask $name to deliver?'),
        content: Text(
            "We'll send $name a request for order #${widget.order.id}. They have 3 minutes "
            "to accept. If they can't, we'll tell you and the job opens to all riders."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not now')),
          FilledButton(
              key: const Key('assign-rider-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Send request')),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _sending = rider['id'] as int);
    try {
      await ApiService.offerRider(
          context.read<AuthProvider>().token!, widget.order.id, rider['id'] as int);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSettingsMessage(context, 'Request sent to $name.');
    } catch (e) {
      if (mounted) {
        showSettingsMessage(context, friendlyMessage(e), isError: true);
        setState(() => _sending = null);
        await _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final riders = _riders;
    final available = [for (final r in riders ?? const <Map<String, dynamic>>[]) if (r['eligible'] == true) r];
    final unavailable = [for (final r in riders ?? const <Map<String, dynamic>>[]) if (r['eligible'] != true) r];
    final textSec = AppColors.textSecondary(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: 'Assign a rider',
          subtitle: 'Order #${widget.order.id}'
              '${widget.order.deliveryAddress == null ? '' : ' · to ${widget.order.deliveryPlace}'}',
        ),
        if (_error != null)
          EmptyState(
              icon: Icons.wifi_off_rounded,
              title: "Couldn't load riders",
              subtitle: _error!,
              actionLabel: 'Retry',
              onAction: _load)
        else if (riders == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          )
        else ...[
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                  'No riders are free right now. The order stays open, so the next free '
                  'rider can take it.',
                  style: TextStyle(color: textSec, fontSize: 13.5, height: 1.4)),
            )
          else
            for (final r in available)
              _RiderTile(rider: r, sending: _sending == r['id'], onTap: _sending == null ? () => _ask(r) : null),
          if (unavailable.isNotEmpty) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              key: const Key('assign-rider-show-unavailable'),
              onPressed: () => setState(() => _showUnavailable = !_showUnavailable),
              icon: Icon(_showUnavailable ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              label: Text('${unavailable.length} not available'),
            ),
            if (_showUnavailable)
              for (final r in unavailable) _RiderTile(rider: r, sending: false, onTap: null),
          ],
        ],
      ],
    );
  }
}

class _RiderTile extends StatelessWidget {
  final Map<String, dynamic> rider;
  final bool sending;
  final VoidCallback? onTap;
  const _RiderTile({required this.rider, required this.sending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = '${rider['name'] ?? 'Rider'}';
    final eligible = rider['eligible'] == true;
    final busy = (rider['active_deliveries'] as num?)?.toInt() ?? 0;
    final phone = rider['phone'] as String?;
    final avatar = rider['avatar_url'] as String?;
    final (statusText, statusColor) = !eligible
        ? ('${rider['reason'] ?? 'Not available'}', AppColors.textHint(context))
        : busy == 0
            ? ('Available now', AppTheme.success)
            : ('Available · on $busy delivery', AppTheme.warning);
    return Opacity(
      opacity: eligible ? 1 : 0.55,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: AppColors.border(context)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('rider-option-${rider['id']}'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
                  backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.accentDeep, fontWeight: FontWeight.w800))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name,
                        style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(statusText,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: statusColor, fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    if (phone != null)
                      Text(phone,
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
                  ]),
                ),
                if (phone != null) ...[
                  CallButton(phone: phone, who: name),
                  const SizedBox(width: 8),
                ],
                if (sending)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                else if (eligible)
                  Icon(Icons.chevron_right_rounded, color: AppColors.textHint(context)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Rider: requests from restaurants ─────────────────────────────────────────

/// "Requests for you" at the top of the rider's jobs: accept or decline
/// within the time left. Hidden when there are none.
class RiderOffersPanel extends StatefulWidget {
  /// Called after accepting, e.g. to refresh the rider's jobs.
  final VoidCallback? onAccepted;
  const RiderOffersPanel({super.key, this.onAccepted});

  @override
  State<RiderOffersPanel> createState() => _RiderOffersPanelState();
}

class _RiderOffersPanelState extends State<RiderOffersPanel>
    with LiveRefresh<RiderOffersPanel> {
  List<Map<String, dynamic>> _offers = const [];
  int? _busy;
  int _lastUnread = -1;

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A push (new request) bumps the bell; look for requests straight away.
    final unread = Provider.of<NotificationsProvider?>(context)?.unread ?? 0;
    if (_lastUnread != -1 && unread != _lastUnread) _load();
    _lastUnread = unread;
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final offers = await ApiService.getDeliveryOffers(token);
      if (mounted) setState(() => _offers = offers);
    } catch (_) {}
  }

  Future<void> _answer(Map<String, dynamic> offer, bool accept) async {
    final id = offer['id'] as int;
    setState(() => _busy = id);
    final token = context.read<AuthProvider>().token!;
    try {
      if (accept) {
        await ApiService.acceptDeliveryOffer(token, id);
        if (mounted) {
          showSettingsMessage(context,
              'Order #${offer['order_id']} is yours. Find it in My Deliveries for your pickup code.');
        }
        widget.onAccepted?.call();
      } else {
        await ApiService.declineDeliveryOffer(token, id);
      }
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = null);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_offers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Column(
        key: const Key('rider-offers'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Requests for you',
              style: TextStyle(
                  color: AppColors.textPrimary(context), fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final offer in _offers) _OfferCard(
            offer: offer,
            busy: _busy == offer['id'],
            onAnswer: (accept) => _answer(offer, accept),
            onExpired: _load,
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final bool busy;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onExpired;
  const _OfferCard({required this.offer, required this.busy, required this.onAnswer,
      required this.onExpired});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final until = DateTime.now().add(Duration(seconds: (offer['seconds_left'] as num?)?.toInt() ?? 0));
    final items = (offer['items'] as List? ?? const [])
        .map((l) => '${l['quantity']}× ${l['name']}')
        .join(', ');
    return Container(
      key: Key('rider-offer-card-${offer['id']}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent, width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTheme.accent.withValues(alpha: 0.18), blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.storefront_rounded, color: AppTheme.accentDeep, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${offer['restaurant_name'] ?? 'A restaurant'} asked you',
                style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          if (offer['total_amount'] is int)
            Text(formatCedis(offer['total_amount'] as int),
                style: TextStyle(color: AppColors.accentText(context), fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        Text('Order #${offer['order_id']}${items.isEmpty ? '' : ' · $items'}',
            style: TextStyle(color: textSec, fontSize: 13)),
        if (offer['restaurant_address'] != null)
          Text('Pick up: ${offer['restaurant_address']}',
              style: TextStyle(color: textSec, fontSize: 13)),
        const SizedBox(height: 12),
        Countdown(
          until: until,
          builder: (context, left) {
            if (left == Duration.zero) {
              WidgetsBinding.instance.addPostFrameCallback((_) => onExpired());
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: left.inSeconds / 180,
                  minHeight: 5,
                  color: left.inSeconds > 30 ? AppTheme.accent : AppTheme.danger,
                  backgroundColor: AppColors.border(context),
                ),
              ),
              const SizedBox(height: 4),
              Text('${countdown(left)} left to answer',
                  style: TextStyle(color: textSec, fontSize: 12)),
            ]);
          },
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              key: Key('rider-offer-decline-${offer['id']}'),
              onPressed: busy ? null : () => onAnswer(false),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              key: Key('rider-offer-accept-${offer['id']}'),
              label: 'Accept delivery',
              isLoading: busy,
              onPressed: busy ? null : () => onAnswer(true),
            ),
          ),
        ]),
      ]),
    );
  }
}
