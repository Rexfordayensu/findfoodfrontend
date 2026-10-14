import 'dart:async';

import 'package:flutter/widgets.dart';

import 'api_service.dart';
import 'providers.dart';
import 'push_bridge.dart';

/// One entry in the bell's list.
class AppNotification {
  final int id;
  final String kind;
  final String title;
  final String? body;
  final String? link;
  final int? orderId;
  final DateTime createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    this.body,
    this.link,
    this.orderId,
    required this.createdAt,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: (json['id'] as num).toInt(),
        kind: '${json['kind'] ?? ''}',
        title: '${json['title'] ?? ''}',
        body: json['body'] as String?,
        link: json['link'] as String?,
        orderId: (json['order_id'] as num?)?.toInt(),
        createdAt: (DateTime.tryParse('${json['created_at']}') ?? DateTime.now()).toLocal(),
        read: json['read'] == true,
      );

  AppNotification asRead() => AppNotification(
        id: id, kind: kind, title: title, body: body, link: link,
        orderId: orderId, createdAt: createdAt, read: true,
      );
}

/// How turning on push went.
enum PushResult { enabled, denied, unsupported, needsHomeScreen, failed }

/// The signed-in person's notifications: the bell's count and list, web push
/// on this device, and the number on the installed app's icon.
class NotificationsProvider extends ChangeNotifier with WidgetsBindingObserver {
  /// How often the bell checks for new notifications while the app is open
  /// (pushes also refresh it straight away). Tests set this to null.
  static Duration? pollInterval = const Duration(seconds: 30);

  NotificationsProvider({PushBridge? bridge}) : push = bridge ?? PushBridge() {
    push.listen(_onPushMessage);
    WidgetsBinding.instance.addObserver(this);
  }

  final PushBridge push;

  /// Opens an app route, e.g. when a notification is tapped while the app is
  /// open. Set by the app to its router.
  void Function(String location)? onOpen;

  String? _token;
  Timer? _timer;
  String? _publicKey;
  List<AppNotification> _items = const [];
  int _unread = 0;
  bool _loaded = false;
  bool _loading = false;
  bool _deviceSubscribed = false;

  List<AppNotification> get items => _items;
  int get unread => _unread;
  bool get loaded => _loaded;
  bool get loading => _loading;
  bool get deviceSubscribed => _deviceSubscribed;

  /// Whether to offer "Turn on notifications" on this device.
  bool get canAskForPush =>
      push.needsHomeScreen || (push.supported && push.permission == 'default');

  /// Follows sign-in and sign-out.
  void updateAuth(AuthProvider auth) {
    final token = auth.isLoggedIn ? auth.token : null;
    if (token == _token) return;
    final previous = _token;
    final sameSession = previous != null && token != null;
    _token = token;
    if (token == null) {
      _forgetDevice(previous);
      _timer?.cancel();
      _items = const [];
      _unread = 0;
      _loaded = false;
      _deviceSubscribed = false;
      push.setBadge(0);
      notifyListeners();
      return;
    }
    if (sameSession) return; // the token was just renewed
    refresh();
    _startPolling();
    _syncDevice();
  }

  void _startPolling() {
    _timer?.cancel();
    final interval = pollInterval;
    if (interval != null) _timer = Timer.periodic(interval, (_) => refresh());
  }

  Future<void> refresh() async {
    final token = _token;
    if (token == null || _loading) return;
    _loading = true;
    try {
      final data = await ApiService.getNotifications(token);
      if (token != _token) return;
      _items = [
        for (final item in (data['items'] as List? ?? const []))
          if (item is Map<String, dynamic>) AppNotification.fromJson(item),
      ];
      _setUnread((data['unread'] as num?)?.toInt() ?? 0);
      _loaded = true;
      notifyListeners();
    } catch (_) {
      // Keep the last list; the next poll or push tries again.
    } finally {
      _loading = false;
    }
  }

  void _setUnread(int count) {
    _unread = count;
    push.setBadge(count);
  }

  Future<void> markRead(AppNotification note) async {
    final token = _token;
    if (token == null || note.read) return;
    _items = [for (final n in _items) n.id == note.id ? n.asRead() : n];
    _setUnread((_unread - 1).clamp(0, 1 << 30));
    notifyListeners();
    try {
      _setUnread(await ApiService.markNotificationRead(token, note.id));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final token = _token;
    if (token == null || _unread == 0) return;
    _items = [for (final n in _items) n.read ? n : n.asRead()];
    _setUnread(0);
    notifyListeners();
    try {
      await ApiService.markAllNotificationsRead(token);
    } catch (_) {
      await refresh();
    }
  }

  // ── Push on this device ────────────────────────────────────────────────────

  /// Asks to show notifications on this device. Call it straight from a tap:
  /// browsers only show the permission prompt in response to one.
  Future<PushResult> enablePush() async {
    final token = _token;
    if (push.needsHomeScreen) return PushResult.needsHomeScreen;
    if (!push.supported) return PushResult.unsupported;
    if (push.permission == 'denied') return PushResult.denied;
    if (token == null) return PushResult.failed;
    try {
      final key = _publicKey ??= await ApiService.getPushPublicKey();
      final subscription = await push.subscribe(key);
      if (subscription == null) {
        notifyListeners();
        return push.permission == 'denied' ? PushResult.denied : PushResult.failed;
      }
      await ApiService.subscribePush(token, subscription);
      _deviceSubscribed = true;
      notifyListeners();
      return PushResult.enabled;
    } catch (_) {
      notifyListeners();
      return PushResult.failed;
    }
  }

  Future<void> disablePush() async {
    final token = _token;
    final endpoint = await push.unsubscribe();
    if (token != null && endpoint != null) {
      try {
        await ApiService.unsubscribePush(token, endpoint);
      } catch (_) {}
    }
    _deviceSubscribed = false;
    notifyListeners();
  }

  /// After sign-in: fetch the key early (so a later tap can prompt at once)
  /// and make sure this device's subscription points at this account.
  Future<void> _syncDevice() async {
    final token = _token;
    if (token == null || !push.supported) return;
    try {
      _publicKey ??= await ApiService.getPushPublicKey();
      if (push.permission != 'granted') return;
      final subscription = await push.current() ?? await push.subscribe(_publicKey!);
      if (subscription == null || token != _token) return;
      await ApiService.subscribePush(token, subscription);
      _deviceSubscribed = true;
      notifyListeners();
    } catch (_) {}
  }

  /// Signing out stops this device getting that account's notifications.
  Future<void> _forgetDevice(String? token) async {
    if (token == null || !push.supported) return;
    try {
      final subscription = await push.current();
      final endpoint = subscription?['endpoint'];
      if (endpoint is String) await ApiService.unsubscribePush(token, endpoint);
    } catch (_) {}
  }

  void _onPushMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'findfood-push':
        refresh();
      case 'findfood-open':
        final url = message['url'];
        refresh();
        if (url is String && url.startsWith('/')) onOpen?.call(url);
      case 'findfood-resubscribe':
        _syncDevice();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
