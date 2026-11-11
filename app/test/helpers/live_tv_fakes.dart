import 'dart:async';

import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';

LiveChannel testChannel(String playlistId, int i, {String? categoryId}) =>
    LiveChannel(
      playlistId: playlistId,
      streamId: 1000 + i,
      number: i,
      name: 'Channel $i',
      categoryId: categoryId,
    );

/// Catalog source serving a fixed catalog without network access.
class FakeLiveCatalogSource implements LiveCatalogSource {
  FakeLiveCatalogSource({
    this.categories = const [],
    this.channels = const [],
    this.failure,
  });

  List<LiveCategory> categories;
  List<LiveChannel> channels;
  CatalogLoadFailure? failure;
  int channelLoads = 0;

  @override
  Future<List<LiveCategory>> fetchCategories(PlaylistAccess access) async {
    if (failure case final failure?) throw CatalogLoadException(failure);
    return categories;
  }

  @override
  Stream<List<LiveChannel>> fetchChannels(PlaylistAccess access) async* {
    channelLoads++;
    for (var i = 0; i < channels.length; i += 50) {
      yield channels.sublist(i, (i + 50).clamp(0, channels.length));
    }
  }

  @override
  Future<NowNext> fetchNowNext(
    PlaylistAccess access,
    LiveChannel channel,
  ) async => NowNext(
    now: EpgEntry(
      title: 'Show on ${channel.name}',
      start: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
      end: DateTime.now().toUtc().add(const Duration(minutes: 50)),
    ),
  );

  @override
  String streamUrl(PlaylistAccess access, LiveChannel channel) =>
      'http://stream/${channel.streamId}';
}

/// Records what a screen asks the player to do.
class FakePlaybackEngine implements PlaybackEngine {
  final opened = <String>[];
  final _states = StreamController<PlaybackState>.broadcast();
  PlaybackState _state = PlaybackState.idle;
  bool disposed = false;

  void emit(PlaybackState state) {
    _state = state;
    _states.add(state);
  }

  @override
  Stream<PlaybackState> get states => _states.stream;

  @override
  PlaybackState get state => _state;

  @override
  Future<void> open(String url) async {
    opened.add(url);
    emit(const PlaybackState(status: PlaybackStatus.playing));
  }

  @override
  Future<void> togglePause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    disposed = true;
    await _states.close();
  }
}
