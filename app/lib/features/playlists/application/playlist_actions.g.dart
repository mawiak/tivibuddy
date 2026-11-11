// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Playlists of the active profile.

@ProviderFor(activeProfilePlaylists)
final activeProfilePlaylistsProvider = ActiveProfilePlaylistsProvider._();

/// Playlists of the active profile.

final class ActiveProfilePlaylistsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Playlist>>,
          List<Playlist>,
          Stream<List<Playlist>>
        >
    with $FutureModifier<List<Playlist>>, $StreamProvider<List<Playlist>> {
  /// Playlists of the active profile.
  ActiveProfilePlaylistsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProfilePlaylistsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProfilePlaylistsHash();

  @$internal
  @override
  $StreamProviderElement<List<Playlist>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Playlist>> create(Ref ref) {
    return activeProfilePlaylists(ref);
  }
}

String _$activeProfilePlaylistsHash() =>
    r'e6b87274172e79c0d7bc84571ce898980e5ee5e6';

@ProviderFor(playlistActions)
final playlistActionsProvider = PlaylistActionsProvider._();

final class PlaylistActionsProvider
    extends
        $FunctionalProvider<PlaylistActions, PlaylistActions, PlaylistActions>
    with $Provider<PlaylistActions> {
  PlaylistActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistActionsHash();

  @$internal
  @override
  $ProviderElement<PlaylistActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaylistActions create(Ref ref) {
    return playlistActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaylistActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaylistActions>(value),
    );
  }
}

String _$playlistActionsHash() => r'84290db18b4b4c9383d5d258aef95ec99bcd4ceb';
