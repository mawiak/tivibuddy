import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/paged_list.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../playlists/data/playlist_data_providers.dart';
import '../../playlists/domain/playlist.dart';
import '../data/live_tv_data_providers.dart';
import '../domain/live_channel.dart';
import '../domain/live_tv_repository.dart';

part 'live_tv_providers.g.dart';

/// Playlist shown in the live section. Defaults to the first playlist of the
/// active profile.
@riverpod
class LivePlaylistSelection extends _$LivePlaylistSelection {
  @override
  Playlist? build() {
    final playlists = ref.watch(activeProfilePlaylistsProvider).value ?? [];
    final previous = stateOrNull;
    return playlists.where((p) => p.id == previous?.id).firstOrNull ??
        playlists.firstOrNull;
  }

  void select(Playlist playlist) => state = playlist;
}

/// Selected category of a playlist, or null for all channels.
@riverpod
class LiveCategorySelection extends _$LiveCategorySelection {
  @override
  String? build(String playlistId) => null;

  void select(String? categoryId) => state = categoryId;
}

@riverpod
Stream<List<LiveCategory>> liveCategories(Ref ref, String playlistId) =>
    ref.watch(liveTvRepositoryProvider).watchCategories(playlistId);

/// Channels of a category (or all channels) as a lazily loaded list. A new
/// list is created when the number of channels changes, for example while
/// the catalog is loading.
@riverpod
Future<PagedList<LiveChannel>> liveChannelList(
  Ref ref,
  String playlistId,
  String? categoryId,
) async {
  final repository = ref.watch(liveTvRepositoryProvider);
  final countStream = repository.watchChannelCount(
    playlistId,
    categoryId: categoryId,
  );
  final completer = Completer<int>();
  Timer? rebuild;
  final subscription = countStream.listen((count) {
    if (!completer.isCompleted) {
      completer.complete(count);
      return;
    }
    // While a catalog loads the count changes with every batch. Rebuilding
    // the list each time would reload the visible rows constantly, so the
    // list is rebuilt once the count stays stable.
    rebuild?.cancel();
    rebuild = Timer(const Duration(milliseconds: 1500), ref.invalidateSelf);
  });
  ref.onDispose(() {
    rebuild?.cancel();
    subscription.cancel();
  });

  final list = PagedList<LiveChannel>(
    length: await completer.future,
    loader: (offset, limit) => repository.getChannels(
      playlistId,
      categoryId: categoryId,
      offset: offset,
      limit: limit,
    ),
  );
  ref.onDispose(list.dispose);
  return list;
}

// The async providers below obtain all dependencies before their first
// await: an auto-disposed provider may already be disposed when an await
// returns, and using its ref then throws.

/// Playlist data plus password from secure storage.
@riverpod
Future<PlaylistAccess> playlistAccess(Ref ref, String playlistId) async {
  final playlists = ref.watch(playlistRepositoryProvider);
  final credentials = ref.watch(credentialStoreProvider);
  final playlist = await playlists.findById(playlistId);
  final password = await credentials.readPassword(playlistId);
  if (playlist == null || password == null) {
    throw const CatalogLoadException(CatalogLoadFailure.missingPassword);
  }
  return PlaylistAccess(
    playlistId: playlist.id,
    serverUrl: playlist.serverUrl,
    username: playlist.username,
    password: password,
  );
}

/// Reads the access data of a playlist from a controller. Listening keeps
/// the auto-disposed provider alive while it loads.
Future<PlaylistAccess> readPlaylistAccess(Ref ref, String playlistId) async {
  final subscription = ref.listen(
    playlistAccessProvider(playlistId),
    (_, _) {},
  );
  try {
    return await ref.read(playlistAccessProvider(playlistId).future);
  } finally {
    subscription.close();
  }
}

/// Current and next programme of a channel, from the loaded guide or, for
/// channels without guide data, from the provider. Cached for a few minutes
/// and refreshed when the current programme ends.
@riverpod
Future<NowNext> nowNext(Ref ref, LiveChannel channel) async {
  final link = ref.keepAlive();
  final expiry = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(expiry.cancel);

  final source = _sourceFor(ref);
  final epg = ref.watch(epgRepositoryProvider);
  final access = ref.watch(playlistAccessProvider(channel.playlistId).future);
  final now = DateTime.now().toUtc();
  final key = channel.epgChannelId;
  final guide = key == null
      ? const <EpgEntry>[]
      : await epg.getProgrammes(
          channel.playlistId,
          key,
          from: now,
          to: now.add(const Duration(hours: 12)),
        );
  final result = guide.isNotEmpty
      ? NowNext.at(guide, now)
      : await source.fetchNowNext(await access, channel);

  final endsAt = result.now?.end;
  if (endsAt != null) {
    final untilEnd = endsAt.difference(DateTime.now().toUtc());
    if (untilEnd > Duration.zero) {
      final refresh = Timer(untilEnd, ref.invalidateSelf);
      ref.onDispose(refresh.cancel);
    }
  }
  return result;
}

/// Playback URL of a channel.
@riverpod
Future<String> liveStreamUrl(Ref ref, LiveChannel channel) async {
  final source = _sourceFor(ref);
  final access = await ref.watch(
    playlistAccessProvider(channel.playlistId).future,
  );
  return source.streamUrl(access, channel);
}

/// Catalog source of a playlist. Xtream is the only type so far; when M3U
/// is added the type is part of [PlaylistAccess] (PL-3).
LiveCatalogSource _sourceFor(Ref ref) =>
    ref.read(liveCatalogSourceProvider(PlaylistType.xtream));
