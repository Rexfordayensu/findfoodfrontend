// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<void> replaceBrowserUrl(String path) async {
  final uri = Uri.parse(path);
  html.window.history.replaceState(null, '', uri.path);
}

/// Saves [content] as a file through the browser's download.
Future<bool> downloadTextFile(String filename, String content, String mimeType) async {
  final blob = html.Blob([content], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}
