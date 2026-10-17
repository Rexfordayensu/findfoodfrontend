import 'dart:typed_data';

import 'share_helper_stub.dart' if (dart.library.js_interop) 'share_helper_web.dart' as implementation;

/// How a share went.
enum ShareResult { shared, cancelled, unsupported }

/// Opens the phone's share menu with a picture (e.g. to post on WhatsApp
/// Status) and a caption. [unsupported] where the browser can't share files.
Future<ShareResult> shareImage(Uint8List bytes,
        {required String filename, required String text}) =>
    implementation.shareImage(bytes, filename, text);

/// Opens the phone's share menu with a link.
Future<ShareResult> shareLink({required String text, required String url}) =>
    implementation.shareLink(text, url);

/// Saves a picture through the browser's download; false where unsupported.
bool saveImage(Uint8List bytes, String filename) => implementation.saveImage(bytes, filename);
