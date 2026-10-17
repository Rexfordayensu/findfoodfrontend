import 'dart:typed_data';

import 'share_helper.dart';

Future<ShareResult> shareImage(Uint8List bytes, String filename, String text) async =>
    ShareResult.unsupported;

Future<ShareResult> shareLink(String text, String url) async => ShareResult.unsupported;

bool saveImage(Uint8List bytes, String filename) => false;
