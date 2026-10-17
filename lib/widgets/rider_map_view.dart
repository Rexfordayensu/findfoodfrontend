// The map itself (MapLibre drawing OpenFreeMap's free map). Loaded on first
// use only, so the app starts as fast as before (see rider_map.dart).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'map_pins.dart';

/// OpenFreeMap: free map tiles, no account or key, allowed for businesses.
const _mapStyle = 'https://tiles.openfreemap.org/styles/liberty';
const _accra = LatLng(5.6037, -0.1870);
const _source = 'ff-pins';

var _configured = false;
void _configure() {
  if (_configured || !kIsWeb) return;
  _configured = true;
  // The map library is served from our own site (web/maplibre), not a CDN.
  MapLibreMap.webLibrarySource = MapLibreJsSource.urls(
    scriptUrl: Uri.base.resolve('/maplibre/maplibre-gl.mjs').toString(),
    styleUrl: Uri.base.resolve('/maplibre/maplibre-gl.css').toString(),
  );
}

/// A map with pins for the restaurant, the drop-off and riders. Riders glide
/// to their new position whenever [pins] changes.
class PinsMap extends StatefulWidget {
  final List<MapPin> pins;

  /// Drag and zoom (the full-screen map). Small preview maps keep still and
  /// always show every pin.
  final bool interactive;

  /// Change to re-fit the view to the pins (or to [focusId]).
  final int recenterTick;
  final String? focusId;

  const PinsMap({
    super.key,
    required this.pins,
    this.interactive = false,
    this.recenterTick = 0,
    this.focusId,
  });

  @override
  State<PinsMap> createState() => _PinsMapState();
}

class _PinsMapState extends State<PinsMap> {
  MapLibreMapController? _map;
  bool _ready = false;
  // What is drawn right now (mid-glide positions included).
  Map<String, MapPin> _drawn = {};
  Timer? _glide;
  String _framedIds = '';

  @override
  void initState() {
    super.initState();
    _configure();
  }

  @override
  void dispose() {
    _glide?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinsMap old) {
    super.didUpdateWidget(old);
    if (!_ready) return;
    _glideTo(widget.pins);
    final ids = _idsOf(widget.pins);
    if (!widget.interactive || ids != _framedIds) {
      _frame(animate: true);
    } else if (widget.recenterTick != old.recenterTick || widget.focusId != old.focusId) {
      _frame(animate: true);
    }
  }

  static String _idsOf(List<MapPin> pins) => (pins.map((p) => p.id).toList()..sort()).join(',');

  Map<String, dynamic> _geojson(Iterable<MapPin> pins) => {
        'type': 'FeatureCollection',
        'features': [
          for (final p in pins)
            {
              'type': 'Feature',
              'id': p.id,
              'properties': {'kind': p.kind.name, 'label': p.label ?? '', 'live': p.live},
              'geometry': {
                'type': 'Point',
                'coordinates': [p.lng, p.lat],
              },
            },
        ],
      };

  Future<void> _onStyleLoaded() async {
    final map = _map;
    if (map == null) return;
    final kind = ['get', 'kind'];
    await map.addGeoJsonSource(_source, _geojson(widget.pins));
    // A soft halo under riders, so the moving dot stands out.
    await map.addCircleLayer(
      _source,
      'ff-rider-halo',
      const CircleLayerProperties(circleRadius: 18, circleColor: '#2563EB', circleOpacity: 0.16),
      filter: ['==', kind, 'rider'],
      enableInteraction: false,
    );
    await map.addCircleLayer(
      _source,
      'ff-pin-dots',
      CircleLayerProperties(
        circleRadius: ['match', kind, 'rider', 9, 8],
        circleColor: [
          'case',
          ['==', kind, 'rider'],
          ['case', ['get', 'live'], '#2563EB', '#9CA3AF'],
          ['==', kind, 'shop'],
          '#F59E0B',
          '#16A34A',
        ],
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
      ),
      enableInteraction: false,
    );
    await map.addSymbolLayer(
      _source,
      'ff-pin-labels',
      const SymbolLayerProperties(
        textField: ['get', 'label'],
        textFont: ['Noto Sans Bold'],
        textSize: 12.5,
        textOffset: [0, 1.3],
        textAnchor: 'top',
        textColor: '#111827',
        textHaloColor: '#FFFFFF',
        textHaloWidth: 1.8,
        textAllowOverlap: true,
      ),
      enableInteraction: false,
    );
    _drawn = {for (final p in widget.pins) p.id: p};
    _ready = true;
    await _frame(animate: false);
  }

  /// Move riders smoothly from where they're drawn to where they are now.
  void _glideTo(List<MapPin> target) {
    _glide?.cancel();
    final from = Map.of(_drawn);
    final moving = target.any((p) {
      final was = from[p.id];
      return was != null && (was.lat != p.lat || was.lng != p.lng);
    });
    if (!moving) {
      _drawn = {for (final p in target) p.id: p};
      _map?.setGeoJsonSource(_source, _geojson(target));
      return;
    }
    const steps = 30; // ~1.2 s at 25 fps
    var step = 0;
    _glide = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      step++;
      final t = Curves.easeInOut.transform(math.min(1, step / steps));
      final frame = [
        for (final p in target)
          if (from[p.id] case final was?)
            p.at(was.lat + (p.lat - was.lat) * t, was.lng + (p.lng - was.lng) * t)
          else
            p,
      ];
      _drawn = {for (final p in frame) p.id: p};
      _map?.setGeoJsonSource(_source, _geojson(frame));
      if (step >= steps) timer.cancel();
    });
  }

  Future<void> _frame({required bool animate}) async {
    final map = _map;
    final pins = widget.pins;
    if (map == null || pins.isEmpty) return;
    _framedIds = _idsOf(pins);
    final focus = widget.focusId == null ? null : pins.where((p) => p.id == widget.focusId).firstOrNull;
    CameraUpdate update;
    if (focus != null || pins.length == 1) {
      final p = focus ?? pins.first;
      update = CameraUpdate.newLatLngZoom(LatLng(p.lat, p.lng), 15);
    } else {
      var south = pins.first.lat, north = south, west = pins.first.lng, east = west;
      for (final p in pins) {
        south = math.min(south, p.lat);
        north = math.max(north, p.lat);
        west = math.min(west, p.lng);
        east = math.max(east, p.lng);
      }
      // Pins on top of each other: zoom in on them rather than infinitely.
      if (north - south < 0.002 && east - west < 0.002) {
        update = CameraUpdate.newLatLngZoom(LatLng((south + north) / 2, (west + east) / 2), 15);
      } else {
        update = CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
          // Room for the pin labels, and for the map's credit at the bottom.
          left: 56,
          top: 40,
          right: 56,
          bottom: 64,
        );
      }
    }
    try {
      animate ? await map.animateCamera(update) : await map.moveCamera(update);
    } catch (_) {
      // The map may be closing; nothing to frame.
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.pins.firstOrNull;
    final interactive = widget.interactive;
    return MapLibreMap(
      styleString: _mapStyle,
      initialCameraPosition: CameraPosition(
        target: first == null ? _accra : LatLng(first.lat, first.lng),
        zoom: first == null ? 11 : 13,
      ),
      onMapCreated: (controller) => _map = controller,
      onStyleLoadedCallback: _onStyleLoaded,
      dragEnabled: interactive,
      scrollGesturesEnabled: interactive,
      zoomGesturesEnabled: interactive,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      doubleClickZoomEnabled: interactive,
      compassEnabled: false,
      trackCameraPosition: false,
    );
  }
}
