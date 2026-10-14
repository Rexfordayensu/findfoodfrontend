import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

/// Sends crashes in the app to the server (POST /client-errors), where admins
/// see them grouped under App health. Network hiccups and broken images are
/// not crashes and are left out; each error is sent at most once a minute and
/// a session sends at most [maxPerSession].
class CrashReporter {
  CrashReporter._();

  static const appVersion = '1.0.0';
  static const maxPerSession = 20;

  /// Off in debug runs and tests, where errors are shown on screen instead.
  static bool enabled = !kDebugMode;

  static String? Function() _token = () => null;
  static String? Function() _route = () => null;
  static final _recent = <String, DateTime>{};
  static int _sent = 0;

  @visibleForTesting
  static void reset({String? Function()? token, String? Function()? route}) {
    _recent.clear();
    _sent = 0;
    _token = token ?? () => null;
    _route = route ?? () => null;
  }

  /// Catches framework errors and uncaught async errors for the whole app.
  static void install({
    required String? Function() token,
    required String? Function() route,
  }) {
    _token = token;
    _route = route;
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      if (previous != null) {
        previous(details);
      } else {
        FlutterError.presentError(details);
      }
      if (details.library == 'image resource service') return; // a missing photo
      report(details.exception, details.stack,
          context: details.context?.toDescription());
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack);
      return true;
    };
  }

  /// Whether this is a network problem rather than a bug in the app.
  static bool isNoise(Object error) {
    if (error is http.ClientException || error is TimeoutException) return true;
    final text = '$error';
    return text.contains('Failed to fetch') ||
        text.contains('XMLHttpRequest error') ||
        text.contains('Connection closed') ||
        text.contains('SocketException');
  }

  /// A readable type even in release builds, where class names are shortened.
  static String typeOf(Object error) {
    if (error is TypeError) return 'TypeError';
    if (error is RangeError) return 'RangeError';
    if (error is StateError) return 'StateError';
    if (error is ArgumentError) return 'ArgumentError';
    if (error is FormatException) return 'FormatException';
    if (error is NoSuchMethodError) return 'NoSuchMethodError';
    if (error is UnsupportedError) return 'UnsupportedError';
    if (error is AssertionError) return 'AssertionError';
    if (error is FlutterError) return 'FlutterError';
    if (error is Exception) return 'Exception';
    if (error is Error) return 'Error';
    return error.runtimeType.toString();
  }

  static Future<void> report(Object error, StackTrace? stack, {String? context}) async {
    if (!enabled || _sent >= maxPerSession || isNoise(error)) return;
    final type = typeOf(error);
    var message = '$error'.trim();
    if (context != null && context.isNotEmpty) message = '$message (thrown $context)';
    if (message.length > 1000) message = message.substring(0, 1000);
    final key = '$type|${message.length > 120 ? message.substring(0, 120) : message}';
    final now = DateTime.now();
    final last = _recent[key];
    if (last != null && now.difference(last) < const Duration(minutes: 1)) return;
    _recent[key] = now;
    _sent++;
    try {
      await ApiService.reportClientError(
        token: _token(),
        errorType: type,
        message: message.isEmpty ? type : message,
        stack: stack?.toString(),
        route: _route(),
        appVersion: appVersion,
      );
    } catch (_) {
      // Reporting must never cause another error.
    }
  }
}

/// Shown in place of a part of the screen that failed to build (release
/// builds), instead of a grey box.
class BrokenSection extends StatelessWidget {
  const BrokenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "Something went wrong here. We've been told about it.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8A93A3), fontSize: 13),
          ),
        ),
      ),
    );
  }
}
