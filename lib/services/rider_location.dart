import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'api_service.dart';

/// How the rider's location sharing is doing.
enum SharingState {
  /// No delivery right now, so nothing is shared.
  idle,

  /// Customers, the restaurant and admins can see the rider move.
  sharing,

  /// The rider hasn't allowed location (or it's switched off).
  blocked,
}

/// Shares the rider's position while they have a delivery, so the customer,
/// the restaurant and admins can watch them come. Runs while the rider app is
/// open; the browser stops it when the app is closed or in the background.
class RiderLocationSharer extends ChangeNotifier {
  RiderLocationSharer._();
  static final instance = RiderLocationSharer._();

  /// Browsers only: tests and other platforms leave it off.
  static bool enabled = kIsWeb;

  // Look for a delivery this often; report at most this often while moving;
  // and resend when standing still so the dot doesn't go grey.
  static const _checkEvery = Duration(seconds: 30);
  static const _minGap = Duration(seconds: 6);
  static const _heartbeat = Duration(seconds: 45);

  SharingState state = SharingState.idle;
  String? _token;
  Timer? _check, _beat;
  StreamSubscription<Position>? _watch;
  Position? _last;
  DateTime? _sentAt;
  bool _sending = false;

  void start(String token) {
    if (!enabled) return;
    _token = token;
    _check?.cancel();
    _check = Timer.periodic(_checkEvery, (_) => refresh());
    refresh();
  }

  void stop() {
    _check?.cancel();
    _check = null;
    _token = null;
    _stopWatching();
    _set(SharingState.idle);
  }

  /// Start or stop sharing depending on whether the rider has a delivery.
  Future<void> refresh() async {
    final token = _token;
    if (token == null) return;
    try {
      final orders = await ApiService.getMyOrders(token);
      final hasJob = orders.any((o) =>
          o.riderId != null &&
          o.fulfillmentMethod == 'delivery' &&
          const ['pending', 'preparing', 'ready', 'out_for_delivery'].contains(o.status));
      if (hasJob) {
        await _startWatching();
      } else {
        _stopWatching();
        _set(SharingState.idle);
      }
    } catch (_) {
      // Offline for a moment: try again at the next check.
    }
  }

  /// After the rider allows location in the browser.
  Future<void> retry() async {
    _stopWatching();
    await refresh();
  }

  Future<void> _startWatching() async {
    if (_watch != null) return;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return _set(SharingState.blocked);
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return _set(SharingState.blocked);
      }
      _watch = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen(_moved, onError: (_) {
        _stopWatching();
        _set(SharingState.blocked);
      });
      _beat?.cancel();
      _beat = Timer.periodic(_heartbeat, (_) {
        if (_last != null) _send(_last!, force: true);
      });
      _set(SharingState.sharing);
    } catch (_) {
      _set(SharingState.blocked);
    }
  }

  void _moved(Position position) {
    _last = position;
    _send(position);
  }

  Future<void> _send(Position p, {bool force = false}) async {
    final token = _token;
    if (token == null || _sending) return;
    final now = DateTime.now();
    if (!force && _sentAt != null && now.difference(_sentAt!) < _minGap) return;
    _sending = true;
    _sentAt = now;
    try {
      final keep = await ApiService.updateRiderLocation(token,
          lat: p.latitude, lng: p.longitude, heading: p.heading >= 0 && p.heading <= 360 ? p.heading : null);
      if (!keep) {
        // The delivery is finished: stop until the next job.
        _stopWatching();
        _set(SharingState.idle);
      }
    } catch (_) {
      // Missed one report; the next one catches up.
    } finally {
      _sending = false;
    }
  }

  void _stopWatching() {
    _watch?.cancel();
    _watch = null;
    _beat?.cancel();
    _beat = null;
    _last = null;
  }

  void _set(SharingState next) {
    if (state == next) return;
    state = next;
    notifyListeners();
  }
}
