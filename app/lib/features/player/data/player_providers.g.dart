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
/// wake lock support simply do not get that.

@ProviderFor(playbackEngine)
final playbackEngineProvider = PlaybackEngineProvider._();

/// Playback engine shared by the full screen player and the guide preview.
/// Auto-disposed when neither shows it anymore, which frees decoders and
/// buffers (RES-1). While it exists the screen stays on; platforms without
/// wake lock support simply do not get that.

final class PlaybackEngineProvider
    extends $FunctionalProvider<PlaybackEngine, PlaybackEngine, PlaybackEngine>
    with $Provider<PlaybackEngine> {
  /// Playback engine shared by the full screen player and the guide preview.
  /// Auto-disposed when neither shows it anymore, which frees decoders and
  /// buffers (RES-1). While it exists the screen stays on; platforms without
  /// wake lock support simply do not get that.
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

String _$playbackEngineHash() => r'42e328dd94d7881e7bc7880942ccba261e5ac2ba';
