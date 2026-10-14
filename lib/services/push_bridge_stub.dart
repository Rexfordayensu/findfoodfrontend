import 'push_bridge.dart';

PushBridge createPushBridge() => NoPushBridge();

/// Outside the browser (tests, desktop builds) there is no web push.
class NoPushBridge implements PushBridge {
  @override
  bool get supported => false;

  @override
  String get permission => 'unsupported';

  @override
  bool get needsHomeScreen => false;

  @override
  Future<Map<String, dynamic>?> subscribe(String publicKey) async => null;

  @override
  Future<Map<String, dynamic>?> current() async => null;

  @override
  Future<String?> unsubscribe() async => null;

  @override
  void setBadge(int count) {}

  @override
  void listen(void Function(Map<String, dynamic> message) onMessage) {}
}
