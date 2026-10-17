import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import 'map_pins.dart';
import 'rider_map_view.dart' deferred as view;

/// Who is looking at an order's map; it changes the wording.
enum MapViewer { customer, restaurant, rider, admin }

/// The map library is only fetched when a map is first shown.
Future<void>? _viewLoading;
Future<void> _loadView() => _viewLoading ??= view.loadLibrary();

/// The map, or a calm placeholder while it loads (and in tests, where
/// there's no browser to draw it).
class _MapArea extends StatelessWidget {
  final List<MapPin> pins;
  final bool interactive;
  final int recenterTick;
  final String? focusId;
  const _MapArea({required this.pins, this.interactive = false, this.recenterTick = 0, this.focusId});

  /// Maps are drawn by the browser; elsewhere (tests) a placeholder stands in.
  static bool supported = kIsWeb;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surface(context),
      alignment: Alignment.center,
      child: Icon(Icons.map_outlined, size: 40, color: AppColors.textHint(context)),
    );
    if (!supported) return placeholder;
    return FutureBuilder<void>(
      future: _loadView(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || snap.hasError) return placeholder;
        return view.PinsMap(
          pins: pins,
          interactive: interactive,
          recenterTick: recenterTick,
          focusId: focusId,
        );
      },
    );
  }
}

/// The OpenStreetMap credit its free licence asks for.
class MapCredit extends StatelessWidget {
  const MapCredit({super.key});

  @override
  Widget build(BuildContext context) => Text('Map © OpenFreeMap · © OpenStreetMap contributors',
      style: TextStyle(color: AppColors.textHint(context), fontSize: 10.5));
}

/// One order's live map data, refreshed every few seconds.
class _Tracking {
  final Map<String, dynamic> data;
  _Tracking(this.data);

  bool get tracking => data['tracking'] == true;
  Map<String, dynamic>? get rider => (data['rider'] as Map?)?.cast<String, dynamic>();
  Map<String, dynamic>? get shop => (data['restaurant'] as Map?)?.cast<String, dynamic>();
  Map<String, dynamic>? get drop => (data['destination'] as Map?)?.cast<String, dynamic>();
  String get riderName => (data['rider_name'] as String?) ?? 'Your rider';
  bool get toCustomer => data['leg'] == 'to_customer';

  List<MapPin> pins(MapViewer viewer) {
    double? n(Object? v) => (v as num?)?.toDouble();
    final out = <MapPin>[];
    final shop = this.shop, drop = this.drop, rider = this.rider;
    if (shop != null && n(shop['lat']) != null) {
      out.add(MapPin(
          id: 'shop',
          kind: PinKind.shop,
          lat: n(shop['lat'])!,
          lng: n(shop['lng'])!,
          label: viewer == MapViewer.restaurant ? 'You' : '${shop['name'] ?? 'Restaurant'}'));
    }
    if (drop != null && n(drop['lat']) != null) {
      out.add(MapPin(
          id: 'home',
          kind: PinKind.home,
          lat: n(drop['lat'])!,
          lng: n(drop['lng'])!,
          label: viewer == MapViewer.customer ? 'You' : 'Drop-off'));
    }
    if (rider != null && n(rider['lat']) != null) {
      out.add(MapPin(
          id: 'rider',
          kind: PinKind.rider,
          lat: n(rider['lat'])!,
          lng: n(rider['lng'])!,
          label: viewer == MapViewer.rider ? 'You' : riderName,
          live: rider['live'] == true));
    }
    return out;
  }

  /// "Kofi is about 6 min away" and friends.
  ({String text, bool live}) status(MapViewer viewer) {
    final rider = this.rider;
    final name = riderName;
    if (!tracking) return (text: 'Live tracking has ended for this order.', live: false);
    if (rider == null) {
      return (
        text: viewer == MapViewer.rider
            ? 'Your location shows here once your phone shares it.'
            : "Waiting for $name's location. It shows once their FindFood app is open.",
        live: false,
      );
    }
    if (rider['live'] != true) {
      final minutes = (((rider['age_seconds'] as num?) ?? 0) / 60).round();
      return (text: '$name was last seen $minutes min ago.', live: false);
    }
    final target = toCustomer ? drop : shop;
    String? away;
    if (target != null) {
      final km = travelKm((rider['lat'] as num).toDouble(), (rider['lng'] as num).toDouble(),
          (target['lat'] as num).toDouble(), (target['lng'] as num).toDouble());
      away = km < 0.15 ? 'nearly there' : 'about ${travelMinutes(km)} min away (${km.toStringAsFixed(1)} km)';
    }
    final text = switch ((viewer, toCustomer)) {
      (MapViewer.customer, false) =>
        '$name is picking up your food${away == null ? '' : ' · $away from the restaurant'}.',
      (MapViewer.customer, true) => away == null ? '$name is on the way to you.' : '$name is $away.',
      (MapViewer.restaurant, false) => away == null ? '$name is coming to collect.' : '$name is $away from you.',
      (MapViewer.restaurant, true) => '$name is taking the food to the customer.',
      (_, false) => 'Heading to the restaurant${away == null ? '' : ' · $away'}.',
      (_, true) => 'Heading to the customer${away == null ? '' : ' · $away'}.',
    };
    return (text: text, live: true);
  }
}

/// Polls one order's map while it's on screen.
mixin _TrackingPoller<T extends StatefulWidget> on State<T> {
  _Tracking? tracking;
  String? trackingError;
  Timer? _timer;

  /// How often the map refreshes (null: once, as in tests).
  static Duration? every = kIsWeb ? const Duration(seconds: 5) : null;

  int get trackedOrderId;

  void startTracking() {
    _fetch();
    final every = _TrackingPoller.every;
    if (every != null) _timer = Timer.periodic(every, (_) => _fetch());
  }

  Future<void> _fetch() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final data = _Tracking(await ApiService.getOrderTracking(token, trackedOrderId));
      if (!mounted) return;
      setState(() {
        tracking = data;
        trackingError = null;
      });
      if (!data.tracking) _timer?.cancel(); // finished: nothing more will move
    } catch (e) {
      if (mounted && tracking == null) setState(() => trackingError = "Couldn't load the map.");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// A small live map of a delivery: the restaurant, the drop-off and the
/// rider's dot moving between them. Opens full screen.
class RiderMapCard extends StatefulWidget {
  final int orderId;
  final MapViewer viewer;
  final double height;
  const RiderMapCard({super.key, required this.orderId, required this.viewer, this.height = 190});

  @override
  State<RiderMapCard> createState() => _RiderMapCardState();
}

class _RiderMapCardState extends State<RiderMapCard> with _TrackingPoller<RiderMapCard> {
  @override
  int get trackedOrderId => widget.orderId;

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  @override
  Widget build(BuildContext context) {
    final data = tracking;
    final status = data?.status(widget.viewer);
    final pins = data?.pins(widget.viewer) ?? const <MapPin>[];
    return Container(
      key: Key('rider-map-${widget.orderId}'),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: widget.height, child: _MapArea(pins: pins)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: Row(children: [
            _LiveDot(live: status?.live ?? false),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                status?.text ?? trackingError ?? 'Loading the map…',
                key: Key('rider-map-status-${widget.orderId}'),
                style: TextStyle(
                    color: AppColors.textPrimary(context), fontWeight: FontWeight.w700, fontSize: 14, height: 1.35),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
          child: Row(children: [
            const SizedBox(width: 6),
            const Expanded(child: MapCredit()),
            TextButton.icon(
              key: Key('rider-map-open-${widget.orderId}'),
              onPressed: () => openRiderMap(context, widget.orderId, widget.viewer),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentText(context),
                textStyle:
                    const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              icon: const Icon(Icons.open_in_full_rounded, size: 17),
              label: const Text('Full map'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _LiveDot extends StatelessWidget {
  final bool live;
  const _LiveDot({required this.live});

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: live ? const Color(0xFF2563EB) : AppColors.textHint(context),
          shape: BoxShape.circle,
          boxShadow: live
              ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 4)]
              : null,
        ),
      );
}

/// What each pin colour means.
class _Legend extends StatelessWidget {
  final MapViewer viewer;
  const _Legend({required this.viewer});

  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 11,
            height: 11,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5)),
        ]);
    return Wrap(spacing: 14, runSpacing: 6, children: [
      item(const Color(0xFF2563EB), viewer == MapViewer.rider ? 'You' : 'Rider'),
      item(const Color(0xFFF59E0B), 'Restaurant'),
      item(const Color(0xFF16A34A), viewer == MapViewer.customer ? 'You' : 'Drop-off'),
    ]);
  }
}

Future<void> openRiderMap(BuildContext context, int orderId, MapViewer viewer) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RiderMapScreen(orderId: orderId, viewer: viewer),
    ));

/// Full-screen live map of one order.
class RiderMapScreen extends StatefulWidget {
  final int orderId;
  final MapViewer viewer;
  const RiderMapScreen({super.key, required this.orderId, required this.viewer});

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> with _TrackingPoller<RiderMapScreen> {
  int _recenter = 0;

  @override
  int get trackedOrderId => widget.orderId;

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  @override
  Widget build(BuildContext context) {
    final data = tracking;
    final status = data?.status(widget.viewer);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(title: Text('Order #${widget.orderId} · live map')),
      body: Column(children: [
        Expanded(
          child: _MapArea(pins: data?.pins(widget.viewer) ?? const [], interactive: true, recenterTick: _recenter),
        ),
        // The panel sits below the map, not over it: buttons drawn on top of
        // a web map don't always receive taps.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.sheet(context),
            border: Border(top: BorderSide(color: AppColors.border(context))),
          ),
          child: SafeArea(
            top: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                _LiveDot(live: status?.live ?? false),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(status?.text ?? trackingError ?? 'Loading the map…',
                      style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          height: 1.35)),
                ),
              ]),
              const SizedBox(height: 12),
              _Legend(viewer: widget.viewer),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('rider-map-recenter'),
                  onPressed: () => setState(() => _recenter++),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary(context),
                    side: BorderSide(color: AppColors.border(context)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle:
                        const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 19),
                  label: const Text('Show everyone'),
                ),
              ),
              const SizedBox(height: 10),
              const MapCredit(),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Admin: every rider out on a delivery, live.
class AdminLiveMapScreen extends StatefulWidget {
  const AdminLiveMapScreen({super.key});

  @override
  State<AdminLiveMapScreen> createState() => _AdminLiveMapScreenState();
}

class _AdminLiveMapScreenState extends State<AdminLiveMapScreen> {
  List<Map<String, dynamic>>? _riders;
  String? _error;
  String? _focus;
  int _recenter = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    final every = _TrackingPoller.every;
    if (every != null) _timer = Timer.periodic(every, (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final riders = await ApiService.getLiveRiders(context.read<AuthProvider>().token!);
      if (mounted) {
        setState(() {
          _riders = riders;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && _riders == null) setState(() => _error = "Couldn't load the riders.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final riders = _riders ?? const [];
    final textSec = AppColors.textSecondary(context);
    final pins = [
      for (final r in riders)
        MapPin(
          id: 'rider-${r['rider_id']}',
          kind: PinKind.rider,
          lat: (r['lat'] as num).toDouble(),
          lng: (r['lng'] as num).toDouble(),
          label: '${r['name']}',
          live: r['live'] == true,
        ),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(title: const Text('Riders on the road')),
      body: Column(children: [
        Expanded(child: _MapArea(pins: pins, interactive: true, recenterTick: _recenter, focusId: _focus)),
        Material(
          color: AppColors.sheet(context),
          shape: Border(top: BorderSide(color: AppColors.border(context))),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280, minWidth: double.infinity),
            child: SafeArea(
              top: false,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        _riders == null
                            ? (_error ?? 'Loading…')
                            : riders.isEmpty
                                ? 'No riders are out on a delivery right now.'
                                : '${riders.length} rider${riders.length == 1 ? '' : 's'} on the road',
                        key: const Key('live-map-summary'),
                        style:
                            TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    if (riders.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() {
                          _focus = null;
                          _recenter++;
                        }),
                        child: const Text('Show all'),
                      ),
                  ]),
                  for (final r in riders)
                    ListTile(
                      key: Key('live-rider-${r['rider_id']}'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: _LiveDot(live: r['live'] == true),
                      title: Text('${r['name']}',
                          style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        [
                          for (final o in (r['orders'] as List).cast<Map>())
                            '#${o['id']} · ${o['restaurant'] ?? 'Restaurant'}',
                          if (r['live'] != true)
                            'last seen ${(((r['age_seconds'] as num?) ?? 0) / 60).round()} min ago',
                        ].join('  ·  '),
                        style: TextStyle(color: textSec, fontSize: 12.5),
                      ),
                      trailing: const Icon(Icons.my_location_rounded, size: 20),
                      onTap: () => setState(() {
                        _focus = 'rider-${r['rider_id']}';
                        _recenter++;
                      }),
                    ),
                  const SizedBox(height: 6),
                  const MapCredit(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
