import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Switches the display refresh rate to the video (`DisplayModes.kt`).
class DisplayFrameRate {
  const DisplayFrameRate();

  static const _channel = MethodChannel('io.github.mawiak.tivibuddy/display');

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> match(double fps) => _log('matchFrameRate', {'fps': fps});

  Future<void> reset() => _log('reset');

  Future<void> _log(String method, [Map<String, Object?>? args]) async {
    try {
      debugPrint('${await _channel.invokeMethod<String>(method, args)}');
    } on Exception catch (error) {
      debugPrint('display: $method failed: $error');
    }
  }
}
