import 'dart:async';

import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';

LiveChannel testChannel(
  String playlistId,
  int i, {
  String? categoryId,
  String? epgChannelId,
}) => LiveChannel(
  playlistId: playlistId,
  streamId: 1000 + i,
  number: i,
  name: 'Channel $i',
  categoryId: categoryId,
  epgChannelId: epgChannelId,
);

/// Catalog source serving a fixed catalog without network access.
class FakeLiveCatalogSource implements LiveCatalogSource {
  FakeLiveCatalogSource({
    this.categories = const [],
    this.channels = const [],
    this.programmes = const [],
    this.failure,
  });

  List<LiveCategory> categories;
  List<LiveChannel> channels;
  List<EpgProgramme> programmes;
  int guideLoads = 0;
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
  Stream<List<EpgProgramme>> fetchProgrammes(
    PlaylistAccess access, {
    required Set<String> channelKeys,
    required DateTime from,
    required DateTime to,
  }) async* {
    guideLoads++;
    yield [
      for (final programme in programmes)
        if (channelKeys.contains(programme.channelKey) &&
            programme.end.isAfter(from) &&
            programme.start.isBefore(to))
          programme,
    ];
  }

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

  /// Start positions passed to [open], in the same order as [opened].
  final starts = <Duration?>[];
  final _positions = StreamController<Duration>.broadcast();
  Duration _position = Duration.zero;

  void emitPosition(Duration position) {
    _position = position;
    _positions.add(position);
  }

  @override
  Future<void> open(String url, {Duration? start, bool live = false}) async {
    opened.add(url);
    starts.add(start);
    _position = start ?? Duration.zero;
    emit(const PlaybackState(status: PlaybackStatus.playing));
  }

  @override
  Stream<Duration> get positions => _positions.stream;

  @override
  Duration get position => _position;

  @override
  Future<void> seek(Duration position) async => emitPosition(position);

  final _tracks = StreamController<MediaTracks>.broadcast();
  MediaTracks _currentTracks = MediaTracks.none;

  /// Track selections asked for, as (type, id).
  final selections = <(MediaTrackType, String?)>[];

  void emitTracks(MediaTracks tracks) {
    _currentTracks = tracks;
    _tracks.add(tracks);
  }

  @override
  Stream<MediaTracks> get tracks => _tracks.stream;

  @override
  MediaTracks get currentTracks => _currentTracks;

  @override
  Future<void> selectTrack(MediaTrackType type, String? id) async {
    selections.add((type, id));
    final t = _currentTracks;
    emitTracks(
      MediaTracks(
        audio: t.audio,
        subtitle: t.subtitle,
        video: t.video,
        selectedAudio: type == MediaTrackType.audio ? id : t.selectedAudio,
        selectedSubtitle: type == MediaTrackType.subtitle
            ? id
            : t.selectedSubtitle,
        selectedVideo: type == MediaTrackType.video ? id : t.selectedVideo,
      ),
    );
  }

  @override
  Future<void> togglePause() async {
    switch (_state.status) {
      case PlaybackStatus.playing:
        emit(
          PlaybackState(
            status: PlaybackStatus.paused,
            frameRate: _state.frameRate,
          ),
        );
      case PlaybackStatus.paused:
        emit(
          PlaybackState(
            status: PlaybackStatus.playing,
            frameRate: _state.frameRate,
          ),
        );
      default:
        break;
    }
  }

  @override
  Future<void> stop() async {}

  int audioRefreshes = 0;

  @override
  Future<void> refreshAudioOutput() async => audioRefreshes++;

  @override
  Future<void> dispose() async {
    disposed = true;
    await _states.close();
    await _positions.close();
    await _tracks.close();
  }
}
