import 'push_bridge_stub.dart'
    if (dart.library.js_interop) 'push_bridge_web.dart' as impl;

/// The browser side of notifications: web push permission and subscription,
/// messages from the service worker (web/sw.js) and the app icon badge.
abstract class PushBridge {
  /// The bridge for this platform (a no-op outside the web).
  factory PushBridge() => impl.createPushBridge();

  /// Whether this browser can receive web push at all.
  bool get supported;

  /// 'default', 'granted', 'denied' or 'unsupported'.
  String get permission;

  /// iPhone and iPad only allow push once FindFood is added to the Home Screen.
  bool get needsHomeScreen;

  /// Asks for permission (call from a tap) and returns the subscription.
  Future<Map<String, dynamic>?> subscribe(String publicKey);

  /// This browser's existing subscription, without prompting.
  Future<Map<String, dynamic>?> current();

  /// Removes this browser's subscription; returns its endpoint.
  Future<String?> unsubscribe();

  /// The number on the installed app's icon (0 clears it).
  void setBadge(int count);

  /// Messages from the service worker: a push arrived, or a notification was
  /// tapped while the app was open ({'type': 'findfood-open', 'url': ...}).
  void listen(void Function(Map<String, dynamic> message) onMessage);
}
