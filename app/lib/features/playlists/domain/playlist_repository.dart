import 'playlist.dart';

abstract interface class PlaylistRepository {
  /// Playlists of [profileId] that are not deleted, in display order.
  Stream<List<Playlist>> watchForProfile(String profileId);

  Future<List<Playlist>> getForProfile(String profileId);

  Future<Playlist?> findById(String id);

  Future<Playlist> create({
    required String profileId,
    required PlaylistType type,
    required String name,
    required String serverUrl,
    required String username,
  });

  Future<void> update(
    String id, {
    required String name,
    required String serverUrl,
    required String username,
  });

  Future<void> saveAccountInfo(String id, AccountInfo account);

  Future<void> delete(String id);

  /// Deletes all playlists of a profile and returns their ids.
  Future<List<String>> deleteAllForProfile(String profileId);
}
