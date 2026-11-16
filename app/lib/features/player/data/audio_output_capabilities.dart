import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/player_settings.dart';

/// What the audio output of the device accepts for passthrough right now.
class PassthroughSupport {
  const PassthroughSupport(this.formats, {this.details = const {}});

  /// Formats the output takes unchanged.
  final Set<AudioPassthrough> formats;

  /// Raw values the decision was based on, for diagnostic reports.
  final Map<String, Object?> details;
}

/// Asks Android which compressed formats the output accepts
/// (`AudioCapabilities.kt`). Passing through anything else stalls playback.
class AudioOutputCapabilities {
  const AudioOutputCapabilities();

  static const _channel = MethodChannel('io.github.mawiak.tivibuddy/audio');

  // android.media.AudioFormat encodings.
  static const _formatsByEncoding = {
    5: AudioPassthrough.ac3,
    6: AudioPassthrough.eac3,
    7: AudioPassthrough.dts,
    8: AudioPassthrough.dtsHd,
    14: AudioPassthrough.trueHd,
    // E-AC3 with Atmos (JOC) travels as E-AC3.
    18: AudioPassthrough.eac3,
  };

  /// Null where the platform does not tell; then the user's choice applies
  /// unchanged. On Android a failed query means no passthrough, because a
  /// wrong guess freezes playback.
  Future<PassthroughSupport?> query() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'passthroughCapabilities',
      );
      final encodings = (result?['formats'] as List<Object?>? ?? const [])
          .whereType<int>();
      return PassthroughSupport(
        {for (final encoding in encodings) ?_formatsByEncoding[encoding]},
        details: Map<String, Object?>.from(
          result?['details'] as Map<Object?, Object?>? ?? const {},
        ),
      );
    } on Exception catch (error) {
      return PassthroughSupport(const {}, details: {'error': '$error'});
    }
  }
}
