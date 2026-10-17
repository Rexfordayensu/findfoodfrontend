import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'share_helper.dart';

Future<ShareResult> _share(web.ShareData data) async {
  final navigator = web.window.navigator;
  try {
    if (!navigator.canShare(data)) return ShareResult.unsupported;
    await navigator.share(data).toDart;
    return ShareResult.shared;
  } catch (error) {
    // The person closed the share menu.
    if (error is web.DOMException && error.name == 'AbortError') return ShareResult.cancelled;
    final text = '$error';
    if (text.contains('AbortError') || text.contains('cancel')) return ShareResult.cancelled;
    return ShareResult.unsupported;
  }
}

bool get _canShareAtAll {
  try {
    return web.window.navigator.has('share');
  } catch (_) {
    return false;
  }
}

Future<ShareResult> shareImage(Uint8List bytes, String filename, String text) async {
  if (!_canShareAtAll) return ShareResult.unsupported;
  final file = web.File(
    [bytes.toJS].toJS,
    filename,
    web.FilePropertyBag(type: 'image/jpeg'),
  );
  // The link goes in the caption: some apps drop the picture when a url is
  // shared alongside it.
  return _share(web.ShareData(files: [file].toJS, text: text));
}

Future<ShareResult> shareLink(String text, String url) async {
  if (!_canShareAtAll) return ShareResult.unsupported;
  return _share(web.ShareData(text: text, url: url));
}

bool saveImage(Uint8List bytes, String filename) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'image/jpeg'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return true;
}

extension on web.Navigator {
  bool has(String name) => (this as JSObject).hasProperty(name.toJS).toDart;
}
