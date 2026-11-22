// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Playback engine shared by the full screen player and the guide preview.
/// Auto-disposed when neither shows it anymore, which frees decoders and
/// buffers (RES-1). While it exists the screen stays on; platforms without
/// wake lock support simply do not get that. Changed player settings apply
/// to the next engine.

@ProviderFor(playbackEngine)
final playbackEngineProvider = PlaybackEngineProvider._();

/// Playback engine shared by the full screen player and the guide preview.
/// Auto-disposed when neither shows it anymore, which frees decoders and
/// buffers (RES-1). While it exists the screen stays on; platforms without
/// wake lock support simply do not get that. Changed player settings apply
/// to the next engine.

final class PlaybackEngineProvider
    extends $FunctionalProvider<PlaybackEngine, PlaybackEngine, PlaybackEngine>
    with $Provider<PlaybackEngine> {
  /// Playback engine shared by the full screen player and the guide preview.
  /// Auto-disposed when neither shows it anymore, which frees decoders and
  /// buffers (RES-1). While it exists the screen stays on; platforms without
  /// wake lock support simply do not get that. Changed player settings apply
  /// to the next engine.
  PlaybackEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackEngineHash();

  @$internal
  @override
  $ProviderElement<PlaybackEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaybackEngine create(Ref ref) {
    return playbackEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackEngine>(value),
    );
  }
}

String _$playbackEngineHash() => r'ac9cc5cf3d03903eb40aee38c23315d10064a95a';

@ProviderFor(audioOutputCapabilities)
final audioOutputCapabilitiesProvider = AudioOutputCapabilitiesProvider._();

final class AudioOutputCapabilitiesProvider
    extends
        $FunctionalProvider<
          AudioOutputCapabilities,
          AudioOutputCapabilities,
          AudioOutputCapabilities
        >
    with $Provider<AudioOutputCapabilities> {
  AudioOutputCapabilitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioOutputCapabilitiesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioOutputCapabilitiesHash();

  @$internal
  @override
  $ProviderElement<AudioOutputCapabilities> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AudioOutputCapabilities create(Ref ref) {
    return audioOutputCapabilities(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioOutputCapabilities value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioOutputCapabilities>(value),
    );
  }
}

String _$audioOutputCapabilitiesHash() =>
    r'6bfc72039ee7ea8cd24faae464bb0140dab4b426';
