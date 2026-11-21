import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/data/settings_data_providers.dart';
import '../data/audio_output_capabilities.dart';
import '../data/player_providers.dart';
import '../domain/player_settings.dart';

part 'player_settings_providers.g.dart';

/// Player settings of this device, kept as device settings (SET-1). Kept
/// alive and listened to from the app root, so the playback engine finds the
/// stored values when it is created.
@Riverpod(keepAlive: true)
class PlayerSettingsController extends _$PlayerSettingsController {
  static const _engineKey = 'player.engine';
  static const _frameRateKey = 'player.frameRate';
  static const _decoderKey = 'player.decoder';
  static const _passthroughKey = 'player.passthrough';

  @override
  PlayerSettings build() {
    final settings = ref.watch(deviceSettingsRepositoryProvider);
    final subscriptions = [
      settings.watchValue(_engineKey).listen((value) {
        _update(
          (current) => current.copyWith(
            engine:
                PlayerEngineChoice.values.asNameMap()[value] ??
                PlayerSettings.defaults.engine,
          ),
        );
      }),
      settings.watchValue(_frameRateKey).listen((value) {
        _update(
          (current) => current.copyWith(
            frameRateMatching: switch (value) {
              // Stored by the first version, which only knew on and off.
              'on' => FrameRateMatching.always,
              final name? =>
                FrameRateMatching.values.asNameMap()[name] ??
                    FrameRateMatching.off,
              null => FrameRateMatching.off,
            },
          ),
        );
      }),
      settings.watchValue(_decoderKey).listen((value) {
        _update(
          (current) => current.copyWith(
            decoder:
                VideoDecoder.values.asNameMap()[value] ??
                PlayerSettings.defaults.decoder,
          ),
        );
      }),
      settings.watchValue(_passthroughKey).listen((value) {
        _update(
          (current) => current.copyWith(passthrough: _parsePassthrough(value)),
        );
      }),
    ];
    ref.onDispose(() {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    });
    return PlayerSettings.defaults;
  }

  void _update(PlayerSettings Function(PlayerSettings current) change) {
    final next = change(stateOrNull ?? PlayerSettings.defaults);
    if (next != stateOrNull) state = next;
  }

  static Set<AudioPassthrough> _parsePassthrough(String? value) {
    if (value == null || value.isEmpty) return const {};
    final byName = AudioPassthrough.values.asNameMap();
    return {for (final name in value.split(',')) ?byName[name]};
  }

  /// Takes effect with the next playback, because the engines are chosen
  /// when the player is created.
  Future<void> setEngine(PlayerEngineChoice engine) async {
    _update((current) => current.copyWith(engine: engine));
    await ref
        .read(deviceSettingsRepositoryProvider)
        .setValue(_engineKey, engine.name);
  }

  /// Takes effect with the next playback.
  Future<void> setFrameRateMatching(FrameRateMatching matching) async {
    _update((current) => current.copyWith(frameRateMatching: matching));
    await ref
        .read(deviceSettingsRepositoryProvider)
        .setValue(
          _frameRateKey,
          matching == FrameRateMatching.off ? null : matching.name,
        );
  }

  /// Takes effect with the next playback, because the decoder is chosen
  /// when the player is created.
  Future<void> setDecoder(VideoDecoder decoder) async {
    _update((current) => current.copyWith(decoder: decoder));
    await ref
        .read(deviceSettingsRepositoryProvider)
        .setValue(_decoderKey, decoder.name);
  }

  Future<void> setPassthrough(Set<AudioPassthrough> formats) async {
    _update((current) => current.copyWith(passthrough: formats));
    await ref
        .read(deviceSettingsRepositoryProvider)
        .setValue(
          _passthroughKey,
          formats.isEmpty
              ? null
              // Stored in a fixed order, so equal sets give equal values.
              : [
                  for (final format in AudioPassthrough.values)
                    if (formats.contains(format)) format.name,
                ].join(','),
        );
  }
}

/// What the audio output accepts for passthrough right now; null where the
/// platform does not tell.
@riverpod
Future<PassthroughSupport?> passthroughSupport(Ref ref) =>
    ref.read(audioOutputCapabilitiesProvider).query();
