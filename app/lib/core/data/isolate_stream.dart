import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// Runs [produce] in a background isolate and forwards its events (DATA-1).
///
/// [produce] and everything it captures must be sendable to an isolate.
/// Errors thrown by [produce] arrive as they are. A crash or an unexpected
/// exit of the isolate ends the stream with an [IsolateStreamException].
/// Cancelling the subscription kills the isolate. The web has no isolates,
/// so there [produce] runs on the UI thread.
Stream<T> streamFromIsolate<T>(
  Stream<T> Function() produce, {
  required String debugName,
}) {
  if (kIsWeb) return produce();
  return _run(produce, debugName);
}

class IsolateStreamException implements Exception {
  const IsolateStreamException(this.message);

  final String message;

  @override
  String toString() => 'IsolateStreamException($message)';
}

Stream<T> _run<T>(Stream<T> Function() produce, String debugName) async* {
  final port = ReceivePort();
  // Crashes and exits arrive on the same port, so an isolate that dies does
  // not leave the caller waiting forever.
  final isolate = await Isolate.spawn(
    _main<T>,
    (port.sendPort, produce),
    debugName: debugName,
    onError: port.sendPort,
    onExit: port.sendPort,
  );
  try {
    await for (final message in port) {
      switch (message) {
        case _Event<T>(:final value):
          yield value;
        case _Failure(:final error):
          throw error;
        case _Done():
          return;
        case [final Object? error, _]:
          throw IsolateStreamException('$error');
        case null:
          throw const IsolateStreamException('Isolate stopped unexpectedly');
      }
    }
  } finally {
    port.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

Future<void> _main<T>((SendPort, Stream<T> Function()) args) async {
  final (port, produce) = args;
  try {
    await for (final value in produce()) {
      port.send(_Event<T>(value));
    }
    port.send(const _Done());
  } on Object catch (error) {
    port.send(_Failure(error));
  }
}

final class _Event<T> {
  const _Event(this.value);
  final T value;
}

final class _Failure {
  const _Failure(this.error);
  final Object error;
}

final class _Done {
  const _Done();
}
