// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Playback engine of the open player screen. Auto-disposed when the screen
/// closes, which frees decoders and buffers (RES-1).

@ProviderFor(playbackEngine)
final playbackEngineProvider = PlaybackEngineProvider._();

/// Playback engine of the open player screen. Auto-disposed when the screen
/// closes, which frees decoders and buffers (RES-1).

final class PlaybackEngineProvider
    extends $FunctionalProvider<PlaybackEngine, PlaybackEngine, PlaybackEngine>
    with $Provider<PlaybackEngine> {
  /// Playback engine of the open player screen. Auto-disposed when the screen
  /// closes, which frees decoders and buffers (RES-1).
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

String _$playbackEngineHash() => r'71efa06abc57dfd8603f79934eaa81c4e2917545';
