import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/playback_engine.dart';

/// Media3 (ExoPlayer) on Android through our own plugin (`Media3Player.kt`,
/// PLAY-5). Preferred on Android: it passes Dolby formats to a receiver
/// where the output takes them, uses the platform decoders and plays
/// endless MPEG-TS live streams. It cannot decode DTS or TrueHD itself;
/// such streams fail here and the fallback chain moves on to media_kit.
class Media3PlaybackEngine implements PlaybackEngine {
  Media3PlaybackEngine() {
    _ready = _create();
  }

  static const _channel = MethodChannel('io.github.mawiak.tivibuddy/media3');

  late final Future<void> _ready;
  int? _id;
  StreamSubscription<Object?>? _events;

  /// Texture the video is drawn into; null until the player exists.
  final textureId = ValueNotifier<int?>(null);

  /// Width to height of the picture, including non-square pixels.
  final aspectRatio = ValueNotifier<double?>(null);

  /// Text of the subtitle shown right now.
  final subtitle = ValueNotifier<String?>(null);

  final _states = StreamController<PlaybackState>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  final _tracks = StreamController<MediaTracks>.broadcast();
  PlaybackState _state = PlaybackState.idle;
  Duration _position = Duration.zero;
  MediaTracks _currentTracks = MediaTracks.none;

  Stopwatch? _openedAt;
  bool _started = false;
  bool _pausedByUser = false;
  bool _seeking = false;

  Future<void> _create() async {
    final created = await _channel.invokeMapMethod<String, Object?>('create');
    final id = created!['id']! as int;
    _id = id;
    textureId.value = created['textureId']! as int;
    _events = EventChannel('io.github.mawiak.tivibuddy/media3/$id')
        .receiveBroadcastStream()
        .listen(_onEvent);
  }

  Future<void> _call(
    String method, [
    Map<String, Object?> args = const {},
  ]) async {
    await _ready;
    await _channel.invokeMethod<void>(method, {'id': _id, ...args});
  }

  void _emit(PlaybackState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }

  void _onEvent(Object? raw) {
    if (raw is! Map) return;
    final event = raw.cast<String, Object?>();
    switch (event['event']) {
      case 'state':
        _onPlayerState(
          event['state'] as String?,
          event['playing'] == true,
          event['bufferedMs'] as int?,
        );
      case 'error':
        final error = '${event['code']}: ${event['message']}';
        debugPrint('media3 failed: $error');
        _emit(PlaybackState(status: PlaybackStatus.failed, error: error));
      case 'duration':
        final ms = event['durationMs'] as int?;
        _emit(
          _state.copyWith(
            duration: ms == null ? Duration.zero : Duration(milliseconds: ms),
          ),
        );
      case 'videoSize':
        aspectRatio.value = (event['ratio'] as num?)?.toDouble();
        _emit(
          _state.copyWith(
            videoWidth: event['width'] as int?,
            videoHeight: event['height'] as int?,
          ),
        );
      case 'position':
        _position = Duration(milliseconds: event['positionMs']! as int);
        if (!_positions.isClosed) _positions.add(_position);
      case 'tracks':
        _onTracks(event);
      case 'cues':
        subtitle.value = event['text'] as String?;
      case 'frameRate':
        final fps = standardFrameRate((event['fps']! as num).toDouble());
        debugPrint('media3 frame rate ${fps.toStringAsFixed(3)} fps');
        _emit(_state.copyWith(frameRate: fps));
      case 'log':
        debugPrint('media3 ${event['message']}');
    }
  }

  void _onPlayerState(String? state, bool playing, int? bufferedMs) {
    switch (state) {
      case 'ready' when playing:
        _seeking = false;
        if (!_started) {
          _started = true;
          debugPrint('media3 started in ${_openedAt?.elapsedMilliseconds} ms');
        }
        _emit(_state.copyWith(status: PlaybackStatus.playing));
      case 'ready' when _pausedByUser:
        _emit(_state.copyWith(status: PlaybackStatus.paused));
      case 'buffering' when _started:
        // Seeking rebuffers on purpose; the native side also reports the
        // same state twice (state and isPlaying changes).
        if (!_seeking && _state.status != PlaybackStatus.buffering) {
          debugPrint('media3 stalled, ${bufferedMs ?? '?'} ms buffered');
        }
        _emit(_state.copyWith(status: PlaybackStatus.buffering));
      case 'ended':
        debugPrint('media3 ended');
        _emit(_state.copyWith(status: PlaybackStatus.ended));
      default:
        break;
    }
  }

  void _onTracks(Map<String, Object?> event) {
    List<Map<String, Object?>> list(String key) => [
      for (final track in event[key] as List<Object?>? ?? const [])
        (track! as Map).cast<String, Object?>(),
    ];
    MediaTrack track(Map<String, Object?> map, MediaTrackType type) =>
        MediaTrack(
          id: map['id']! as String,
          type: type,
          language: map['language'] as String?,
          title: map['label'] as String?,
          codec: _codecOf(map['mimeType'] as String?),
          channels: map['channels'] as int?,
        );
    final audio = list('audio');
    final text = list('text');
    String? selected(List<Map<String, Object?>> tracks) =>
        tracks.where((t) => t['selected'] == true).firstOrNull?['id']
            as String?;
    _currentTracks = MediaTracks(
      audio: [for (final t in audio) track(t, MediaTrackType.audio)],
      subtitle: [for (final t in text) track(t, MediaTrackType.subtitle)],
      selectedAudio: selected(audio),
      selectedSubtitle: selected(text),
    );
    if (!_tracks.isClosed) _tracks.add(_currentTracks);
  }

  /// Codec names as mpv reports them, so labels match across engines.
  static String? _codecOf(String? mimeType) => switch (mimeType) {
    'audio/ac3' => 'ac3',
    'audio/eac3' || 'audio/eac3-joc' => 'eac3',
    'audio/vnd.dts' || 'audio/vnd.dts.hd' => 'dts',
    'audio/true-hd' => 'truehd',
    'audio/mp4a-latm' => 'aac',
    'audio/mpeg' => 'mp3',
    'audio/mpeg-L2' => 'mp2',
    'audio/opus' => 'opus',
    'audio/flac' => 'flac',
    _ => null,
  };

  @override
  Future<void> open(String url, {Duration? start, bool live = false}) async {
    _emit(const PlaybackState(status: PlaybackStatus.opening));
    _openedAt = Stopwatch()..start();
    _started = false;
    _pausedByUser = false;
    subtitle.value = null;
    debugPrint('media3 open: $url${start == null ? '' : ' at $start'}');
    try {
      await _call('open', {
        'url': url,
        if (start != null && start > Duration.zero)
          'startMs': start.inMilliseconds,
      });
    } on PlatformException catch (error) {
      debugPrint('media3 failed: $error');
      _emit(PlaybackState(status: PlaybackStatus.failed, error: '$error'));
    }
  }

  @override
  Stream<PlaybackState> get states => _states.stream;

  @override
  PlaybackState get state => _state;

  @override
  Stream<Duration> get positions => _positions.stream;

  @override
  Duration get position => _position;

  @override
  Stream<MediaTracks> get tracks => _tracks.stream;

  @override
  MediaTracks get currentTracks => _currentTracks;

  @override
  Future<void> seek(Duration position) {
    debugPrint('media3 seek to $position');
    _seeking = true;
    return _call('seek', {'positionMs': position.inMilliseconds});
  }

  @override
  Future<void> selectTrack(MediaTrackType type, String? id) async {
    debugPrint('media3 select ${type.name} track ${id ?? 'off'}');
    switch (type) {
      case MediaTrackType.audio:
        await _call('selectAudio', {'track': id});
      case MediaTrackType.subtitle:
        if (id == null) subtitle.value = null;
        await _call('selectText', {'track': id});
      case MediaTrackType.video:
        break;
    }
  }

  @override
  Future<void> togglePause() async {
    if (_state.status == PlaybackStatus.paused) {
      debugPrint('media3 resume');
      _pausedByUser = false;
      await _call('play');
    } else {
      debugPrint('media3 pause');
      _pausedByUser = true;
      await _call('pause');
      _emit(_state.copyWith(status: PlaybackStatus.paused));
    }
  }

  @override
  Future<void> setPaused(bool paused) async {
    debugPrint(paused ? 'media3 pause' : 'media3 resume');
    _pausedByUser = paused;
    if (paused) {
      await _call('pause');
      _emit(_state.copyWith(status: PlaybackStatus.paused));
    } else {
      await _call('play');
    }
  }

  @override
  Future<void> refreshAudioOutput() async {
    debugPrint('media3 refresh audio output');
    await _call('refreshAudio');
  }

  @override
  Future<void> stop() async {
    await _call('stop');
    _emit(PlaybackState.idle);
  }

  @override
  Future<void> dispose() async {
    // Unsubscribe while the native side still listens on the channel.
    await _events?.cancel();
    try {
      await _call('dispose');
    } on Object catch (error) {
      debugPrint('media3 dispose failed: $error');
    }
    textureId.dispose();
    aspectRatio.dispose();
    subtitle.dispose();
    await _states.close();
    await _positions.close();
    await _tracks.close();
  }
}
