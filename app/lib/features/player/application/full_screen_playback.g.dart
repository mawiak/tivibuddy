// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'full_screen_playback.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether a full screen player is open. The display only follows the
/// frame rate of the video then (PLAY-6): switching for the guide preview
/// would turn the TV black on every channel browsed.

@ProviderFor(FullScreenPlayback)
final fullScreenPlaybackProvider = FullScreenPlaybackProvider._();

/// Whether a full screen player is open. The display only follows the
/// frame rate of the video then (PLAY-6): switching for the guide preview
/// would turn the TV black on every channel browsed.
final class FullScreenPlaybackProvider
    extends $NotifierProvider<FullScreenPlayback, bool> {
  /// Whether a full screen player is open. The display only follows the
  /// frame rate of the video then (PLAY-6): switching for the guide preview
  /// would turn the TV black on every channel browsed.
  FullScreenPlaybackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fullScreenPlaybackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fullScreenPlaybackHash();

  @$internal
  @override
  FullScreenPlayback create() => FullScreenPlayback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$fullScreenPlaybackHash() =>
    r'c615a5cfda61d587ff29b66c173cdd93b93b63ff';

/// Whether a full screen player is open. The display only follows the
/// frame rate of the video then (PLAY-6): switching for the guide preview
/// would turn the TV black on every channel browsed.

abstract class _$FullScreenPlayback extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
