import 'web_url_helper_stub.dart'
    if (dart.library.html) 'web_url_helper_web.dart' as implementation;

Future<void> replaceBrowserUrl(String path) async {
  await implementation.replaceBrowserUrl(path);
}

/// Reloads the page to pick up a newer version of the app. With
/// [onlyOnce], skips it (returns false) if the page was already reloaded
/// this way in the last minute, so a real outage can't cause a reload loop.
bool reloadPage({bool onlyOnce = false}) => implementation.reloadPage(onlyOnce);

/// Downloads a text file (e.g. a CSV) in the browser; false where not supported.
Future<bool> downloadTextFile(String filename, String content,
        {String mimeType = 'text/csv;charset=utf-8'}) =>
    implementation.downloadTextFile(filename, content, mimeType);
