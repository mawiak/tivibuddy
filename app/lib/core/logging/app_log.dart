import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'redact.dart';

/// The most recent log lines of this run, kept in memory for a diagnostic
/// report. Bounded, so long sessions do not grow memory (RES-1).
class AppLog {
  AppLog({this.maxLines = 3000});

  final int maxLines;
  final _lines = ListQueue<String>();

  void add(String message) {
    final time = DateTime.now().toIso8601String().substring(11, 23);
    for (final line in redactCredentials(message).split('\n')) {
      _lines.add('$time $line');
      if (_lines.length > maxLines) _lines.removeFirst();
    }
  }

  List<String> get lines => List.unmodifiable(_lines);
}

/// Log of the running app. Global like [debugPrint], which feeds it.
final appLog = AppLog();

/// Routes [debugPrint], Flutter errors and uncaught errors into [appLog].
/// Credentials are removed before anything reaches the platform log, too.
void installLogCapture() {
  final platformPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message == null) return;
    appLog.add(message);
    platformPrint(redactCredentials(message), wrapWidth: wrapWidth);
  };

  final flutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    appLog.add(
      'flutter error: ${details.exceptionAsString()}\n${details.stack}',
    );
    flutterOnError?.call(details);
  };

  final platformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    appLog.add('uncaught error: $error\n$stack');
    return platformOnError?.call(error, stack) ?? false;
  };
}
