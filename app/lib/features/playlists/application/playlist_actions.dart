import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../data/playlist_data_providers.dart';
import '../domain/connection_test.dart';
import '../domain/playlist.dart';

part 'playlist_actions.g.dart';

/// Playlists of the active profile.
@riverpod
Stream<List<Playlist>> activeProfilePlaylists(Ref ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return Stream.value(const []);
  return ref.watch(playlistRepositoryProvider).watchForProfile(profileId);
}

/// Initial values for the playlist form.
class PlaylistFormData {
  const PlaylistFormData({
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.password,
    this.account,
  });

  static const empty = PlaylistFormData(
    name: '',
    serverUrl: '',
    username: '',
    password: '',
  );

  final String name;
  final String serverUrl;
  final String username;
  final String password;
  final AccountInfo? account;
}

@Riverpod(keepAlive: true)
PlaylistActions playlistActions(Ref ref) => PlaylistActions(ref);

/// Use cases around playlists (PL-1, PL-2, PL-4).
class PlaylistActions {
  PlaylistActions(this._ref);

  final Ref _ref;

  Future<PlaylistFormData> loadForm(String? id) async {
    if (id == null) return PlaylistFormData.empty;
    final playlist = await _ref.read(playlistRepositoryProvider).findById(id);
    if (playlist == null) throw StateError('Playlist $id does not exist');
    final password = await _ref.read(credentialStoreProvider).readPassword(id);
    return PlaylistFormData(
      name: playlist.name,
      serverUrl: playlist.serverUrl,
      username: playlist.username,
      password: password ?? '',
      account: playlist.account,
    );
  }

  Future<ConnectionResult> testConnection(PlaylistInput input) => _ref
      .read(connectionTesterProvider(PlaylistType.xtream))
      .test(
        serverUrl: normalizeServerUrl(input.serverUrl)!,
        username: input.username.trim(),
        password: input.password,
      );

  /// Creates a playlist for [profileId] when [id] is null, otherwise updates
  /// it. [account] comes from a preceding successful connection test.
  Future<Playlist> save({
    String? id,
    required String profileId,
    required PlaylistInput input,
    AccountInfo? account,
  }) async {
    if (validatePlaylistInput(input).isNotEmpty) {
      throw ArgumentError('Invalid playlist input');
    }
    final repository = _ref.read(playlistRepositoryProvider);
    final serverUrl = normalizeServerUrl(input.serverUrl)!;

    final String savedId;
    if (id == null) {
      final created = await repository.create(
        profileId: profileId,
        type: PlaylistType.xtream,
        name: input.name,
        serverUrl: serverUrl,
        username: input.username,
      );
      savedId = created.id;
    } else {
      await repository.update(
        id,
        name: input.name,
        serverUrl: serverUrl,
        username: input.username,
      );
      savedId = id;
    }

    await _ref
        .read(credentialStoreProvider)
        .writePassword(savedId, input.password);
    if (account != null) await repository.saveAccountInfo(savedId, account);
    return (await repository.findById(savedId))!;
  }

  Future<void> delete(String id) async {
    await _ref.read(playlistRepositoryProvider).delete(id);
    await _ref.read(credentialStoreProvider).deletePassword(id);
  }

  Future<void> deleteAllForProfile(String profileId) async {
    final ids = await _ref
        .read(playlistRepositoryProvider)
        .deleteAllForProfile(profileId);
    final credentials = _ref.read(credentialStoreProvider);
    for (final id in ids) {
      await credentials.deletePassword(id);
    }
  }
}
