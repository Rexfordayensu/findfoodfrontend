import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// What to tell a person when something fails. Technical details (status
/// codes, exception names) stay in logs; people see plain words.
enum ErrorKind { waking, offline, signedOut, forbidden, notFound, server, other }

class FriendlyError {
  final ErrorKind kind;
  final IconData icon;
  final String title;
  final String message;

  const FriendlyError(this.kind, this.icon, this.title, this.message);

  /// The free server sleeps when idle and takes up to a minute to wake.
  bool get isWaking => kind == ErrorKind.waking;
  bool get needsSignIn => kind == ErrorKind.signedOut;
}

final _statusCode = RegExp(r'\((\d{3})\)');
final _technical = RegExp(
  r'Exception|Error:|TypeError|NoSuchMethod|FormatException|XMLHttpRequest|'
  r'SocketException|ClientException|Instance of|Failed to (load|fetch|update|'
  r'create|send|delete)|is not a subtype|Null check|RangeError|\{|\[',
);

FriendlyError friendlyError(Object error) {
  final text = error.toString().replaceAll('Exception: ', '').trim();
  final lower = text.toLowerCase();

  // Also recognise our own wording, in case an error was already translated.
  if (error is ServerTimeoutException ||
      lower.contains('taking too long') ||
      lower.startsWith('waking up findfood')) {
    return const FriendlyError(
      ErrorKind.waking,
      Icons.hourglass_top_rounded,
      'Waking up FindFood…',
      'This can take up to a minute after a quiet spell. We’ll keep trying.',
    );
  }
  if (lower.contains('xmlhttprequest') ||
      lower.contains('failed host lookup') ||
      lower.contains('socketexception') ||
      lower.contains('clientexception') ||
      lower.contains('network') ||
      lower.contains('connection refused') ||
      lower.contains('connection closed') ||
      lower.contains('can’t reach findfood')) {
    return const FriendlyError(
      ErrorKind.offline,
      Icons.wifi_off_rounded,
      'You’re offline',
      'We can’t reach FindFood right now. Check your internet connection and try again.',
    );
  }

  final code = int.tryParse(_statusCode.firstMatch(text)?.group(1) ?? '');
  if (error is SessionExpiredException ||
      code == 401 ||
      lower.contains('session has expired') ||
      lower.contains('sign in again') ||
      lower.contains('your session ended')) {
    return const FriendlyError(
      ErrorKind.signedOut,
      Icons.lock_clock_outlined,
      'Please sign in again',
      'For your security, your session ended. Sign in to pick up where you left off.',
    );
  }
  if (code == 403) {
    return const FriendlyError(
      ErrorKind.forbidden,
      Icons.block_rounded,
      'Not available to you',
      'This part of FindFood isn’t available for your account.',
    );
  }
  if (code == 404) {
    return const FriendlyError(
      ErrorKind.notFound,
      Icons.search_off_rounded,
      'We couldn’t find that',
      'It may have been removed or is no longer available.',
    );
  }
  if (code != null && code >= 500) {
    return const FriendlyError(
      ErrorKind.server,
      Icons.cloud_off_rounded,
      'Something went wrong on our side',
      'It’s not you. Please try again in a moment.',
    );
  }

  // Messages written for people (e.g. "That code is not right. 1 attempt
  // left.") are worth showing as they are; anything technical is not.
  final readable = text.isNotEmpty &&
      text.length <= 160 &&
      code == null &&
      !_technical.hasMatch(text);
  return FriendlyError(
    ErrorKind.other,
    Icons.error_outline_rounded,
    'Something went wrong',
    readable ? text : 'Please try again. If it keeps happening, contact support.',
  );
}

/// One line for a snackbar.
String friendlyMessage(Object error) {
  final friendly = friendlyError(error);
  if (friendly.kind == ErrorKind.other) return friendly.message;
  final joiner = friendly.title.endsWith('…') ? ' ' : '. ';
  return '${friendly.title}$joiner${friendly.message}';
}
