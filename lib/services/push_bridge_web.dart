import 'dart:convert';
import 'dart:js_interop';

import 'push_bridge.dart';
import 'push_bridge_stub.dart';

/// window.findfoodPush, defined in web/index.html.
@JS('findfoodPush')
external _FindFoodPush? get _findfoodPush;

extension type _FindFoodPush(JSObject _) implements JSObject {
  external bool supported();
  external JSString permission();
  external bool standalone();
  external bool ios();
  external JSPromise<JSString?> subscribe(JSString key);
  external JSPromise<JSString?> current();
  external JSPromise<JSString?> unsubscribe();
  external void setBadge(JSNumber count);
  external void listen(JSFunction callback);
}

PushBridge createPushBridge() {
  final js = _findfoodPush;
  return js == null ? NoPushBridge() : _WebPushBridge(js);
}

class _WebPushBridge implements PushBridge {
  final _FindFoodPush _js;
  _WebPushBridge(this._js);

  Map<String, dynamic>? _parse(JSString? text) {
    if (text == null) return null;
    final decoded = jsonDecode(text.toDart);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  bool get supported => _js.supported();

  @override
  String get permission => _js.permission().toDart;

  @override
  bool get needsHomeScreen => _js.ios() && !_js.standalone();

  @override
  Future<Map<String, dynamic>?> subscribe(String publicKey) async =>
      _parse(await _js.subscribe(publicKey.toJS).toDart);

  @override
  Future<Map<String, dynamic>?> current() async => _parse(await _js.current().toDart);

  @override
  Future<String?> unsubscribe() async => (await _js.unsubscribe().toDart)?.toDart;

  @override
  void setBadge(int count) => _js.setBadge(count.toJS);

  @override
  void listen(void Function(Map<String, dynamic> message) onMessage) {
    _js.listen(((JSString text) {
      final message = _parse(text);
      if (message != null) onMessage(message);
    }).toJS);
  }
}
