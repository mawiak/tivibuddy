import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/widgets.dart';

import '../domain/playback_engine.dart';

/// Media3 (ExoPlayer) through better_player (PLAY-3). Preferred on Android:
/// Media3 hands Dolby formats straight to a receiver where the output takes
/// them and uses the platform decoders. It cannot decode DTS or TrueHD
/// itself and has no embedded subtitle switching for plain streams; streams
/// it cannot play go to the next engine (PLAY-5).
class BetterPlayerPlaybackEngine implements PlaybackEngine {
  BetterPlayerPlaybackEngine()
    : controller = BetterPlayerController(
        const PlayerConfiguration(
          autoPlay: true,
          fit: BoxFit.contain,
          // The screens draw their own controls and handle the app lifecycle.
          controlsConfiguration: PlayerControlsConfiguration(
            showControls: false,
          ),
          handleLifecycle: false,
          autoDispose: false,
        ),
      ) {
    controller
      ..addEventsListener(_onEvent)
      ..addVideoListener(_onValue);
  }

  final BetterPlayerController controller;

  final _states = StreamController<PlaybackState>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  final _tracks = StreamController<MediaTracks>.broadcast();
  PlaybackState _state = PlaybackState.idle;
  MediaTracks _currentTracks = MediaTracks.none;
  Duration? _pendingStart;

  @override
  Stream<PlaybackState> get states => _states.stream;

  @override
  PlaybackState get state => _state;

  @override
  Stream<Duration> get positions => _positions.stream;

  @override
  Duration get position => controller.videoPlayerValue?.position ?? .zero;

  @override
  Stream<MediaTracks> get tracks => _tracks.stream;

  @override
  MediaTracks get currentTracks => _currentTracks;

  void _emit(PlaybackState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }

  @override
  Future<void> open(String url, {Duration? start}) async {
    _emit(const PlaybackState(status: PlaybackStatus.opening));
    _currentTracks = MediaTracks.none;
    _tracks.add(_currentTracks);
    _pendingStart = start != null && start > Duration.zero ? start : null;
    debugPrint('better_player open: $url${start == null ? '' : ' at $start'}');
    try {
      await controller.setupDataSource(
        PlayerDataSource.network(
          url,
          videoFormat: url.contains('.m3u8')
              ? VideoFormat.hls
              : VideoFormat.other,
        ),
      );
    } on Object catch (error) {
      _fail('$error');
    }
  }

  void _fail(String error) {
    debugPrint('better_player failed: $error');
    _emit(PlaybackState(status: PlaybackStatus.failed, error: error));
  }

  void _onEvent(PlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case PlayerEventType.initialized:
        final value = controller.videoPlayerValue;
        final start = _pendingStart;
        _pendingStart = null;
        if (start != null) unawaited(controller.seekTo(start));
        _emit(
          _state.copyWith(
            status: PlaybackStatus.playing,
            duration: value?.duration,
            videoWidth: value?.size?.width.round(),
            videoHeight: value?.size?.height.round(),
          ),
        );
        debugPrint(
          'better_player started: ${value?.size?.width.round()}x'
          '${value?.size?.height.round()}, duration ${value?.duration}',
        );
        unawaited(_loadTracks());
      case PlayerEventType.bufferingStart:
        if (_state.status == PlaybackStatus.playing) {
          debugPrint('better_player stalled');
          _emit(_state.copyWith(status: PlaybackStatus.buffering));
        }
      case PlayerEventType.bufferingEnd:
        if (_state.status == PlaybackStatus.buffering) {
          _emit(_state.copyWith(status: PlaybackStatus.playing));
        }
      case PlayerEventType.play:
        if (_state.status == PlaybackStatus.paused) {
          _emit(_state.copyWith(status: PlaybackStatus.playing));
        }
      case PlayerEventType.pause:
        if (_state.status == PlaybackStatus.playing) {
          _emit(_state.copyWith(status: PlaybackStatus.paused));
        }
      case PlayerEventType.finished:
        debugPrint('better_player ended');
        _emit(_state.copyWith(status: PlaybackStatus.ended));
      case PlayerEventType.exception:
        _fail(
          controller.videoPlayerValue?.errorDescription ??
              '${event.parameters ?? 'unknown error'}',
        );
      default:
        break;
    }
  }

  void _onValue() {
    final value = controller.videoPlayerValue;
    if (value == null || _positions.isClosed) return;
    _positions.add(value.position);
    final size = value.size;
    if (size != null && size.width > 0 && _state.videoWidth == null) {
      _emit(
        _state.copyWith(
          videoWidth: size.width.round(),
          videoHeight: size.height.round(),
        ),
      );
    }
  }

  Future<void> _loadTracks() async {
    final audio = await controller.getAudioTracks();
    final selected = controller.betterPlayerAsmsAudioTrack;
    _currentTracks = MediaTracks(
      audio: [
        for (final track in audio)
          MediaTrack(
            id: '${track.id}',
            type: MediaTrackType.audio,
            language: track.language == 'und' ? null : track.language,
            title: track.label,
            codec: _codecOf(track.mimeType),
          ),
      ],
      selectedAudio: selected?.id == null ? null : '${selected!.id}',
    );
    if (!_tracks.isClosed) _tracks.add(_currentTracks);
    debugPrint(
      'better_player audio tracks: '
      '${audio.map((t) => '${t.language}/${t.mimeType}').join(', ')}',
    );
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
  Future<void> seek(Duration position) async {
    debugPrint('better_player seek to $position');
    await controller.seekTo(position);
  }

  @override
  Future<void> selectTrack(MediaTrackType type, String? id) async {
    debugPrint('better_player select ${type.name} track ${id ?? 'off'}');
    if (type != MediaTrackType.audio || id == null) return;
    final track = controller.betterPlayerAsmsAudioTracks
        .where((t) => '${t.id}' == id)
        .firstOrNull;
    if (track == null) return;
    controller.setAudioTrack(track);
    _currentTracks = MediaTracks(
      audio: _currentTracks.audio,
      selectedAudio: id,
    );
    _tracks.add(_currentTracks);
  }

  @override
  Future<void> togglePause() async {
    if (_state.status == PlaybackStatus.paused) {
      debugPrint('better_player resume');
      await controller.play();
      _emit(_state.copyWith(status: PlaybackStatus.playing));
    } else {
      debugPrint('better_player pause');
      await controller.pause();
      _emit(_state.copyWith(status: PlaybackStatus.paused));
    }
  }

  @override
  Future<void> stop() async {
    await controller.pause();
    _emit(PlaybackState.idle);
  }

  @override
  Future<void> dispose() async {
    controller
      ..removeEventsListener(_onEvent)
      ..removeVideoListener(_onValue)
      ..dispose(forceDispose: true);
    await _states.close();
    await _positions.close();
    await _tracks.close();
  }
}
