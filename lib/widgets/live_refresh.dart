import 'dart:async';

import 'package:flutter/widgets.dart';

/// Keeps a screen's data current by re-fetching it on a timer.
///
/// Refreshes are skipped while the app is in the background or a previous
/// refresh is still running, and the timer stops when the screen is disposed.
mixin LiveRefresh<T extends StatefulWidget> on State<T> {
  /// How often live screens refresh. Tests may shorten or disable it (null).
  static Duration? interval = const Duration(seconds: 10);

  Timer? _liveTimer;
  bool _liveRefreshing = false;

  void startLiveRefresh(Future<void> Function() refresh) {
    _liveTimer?.cancel();
    final every = interval;
    if (every == null) return;
    _liveTimer = Timer.periodic(every, (_) async {
      final state = WidgetsBinding.instance.lifecycleState;
      if (!mounted || _liveRefreshing) return;
      if (state != null && state != AppLifecycleState.resumed) return;
      _liveRefreshing = true;
      try {
        await refresh();
      } finally {
        _liveRefreshing = false;
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }
}
