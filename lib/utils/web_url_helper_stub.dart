Future<void> replaceBrowserUrl(String path) async {}

/// Saving files is only supported on the web; elsewhere this reports false.
Future<bool> downloadTextFile(String filename, String content, String mimeType) async => false;
