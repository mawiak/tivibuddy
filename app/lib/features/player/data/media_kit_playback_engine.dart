import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../domain/playback_engine.dart';
import '../domain/player_settings.dart';

/// libmpv with FFmpeg through media_kit: plays practically every container
/// and codec, with hardware decoding where available (PLAY-1, PLAY-2).
class MediaKitPlaybackEngine implements PlaybackEngine {
  MediaKitPlaybackEngine([this.settings = PlayerSettings.defaults])
    : player = Player(
        configuration: const PlayerConfiguration(
          title: 'TiviBuddy',
          // The default demuxer cache of 32 MB is large enough for smooth
          // live playback and small enough for 1 GB devices (RES-1).
          logLevel: MPVLogLevel.warn,
        ),
      ) {
    controller = VideoController(
      player,
      configuration: _videoConfiguration(settings.decoder),
    );
    _subscriptions.addAll([
      // Warnings and errors of mpv end up in the platform log (logcat on
      // Android), which is the only way to diagnose streams on devices.
      player.stream.log.listen(
        (log) => debugPrint('mpv ${log.level} ${log.prefix}: ${log.text}'),
      ),
      player.stream.buffering.listen((buffering) {
        // Start-up time and stalls are what testers notice as slow zapping
        // and stutter.
        // A new player reports "not buffering" before it starts to buffer,
        // so a start needs a buffering phase that ended.
        final sinceOpen = _openedAt;
        if (buffering && !_started) {
          _bufferedSinceOpen = true;
        } else if (!buffering && _bufferedSinceOpen && !_started) {
          _started = true;
          debugPrint('player started in ${sinceOpen?.elapsedMilliseconds} ms');
        } else if (buffering && _started) {
          debugPrint('player stalled');
        }
        if (buffering) {
          _emit(_state.copyWith(status: PlaybackStatus.buffering));
        } else if (_state.status == PlaybackStatus.buffering) {
          _emit(
            _state.copyWith(
              status: player.state.playing
                  ? PlaybackStatus.playing
                  : PlaybackStatus.paused,
            ),
          );
        }
      }),
      player.stream.playing.listen((playing) {
        if (_state.stopped) return;
        if (playing && !player.state.buffering) {
          _emit(_state.copyWith(status: PlaybackStatus.playing));
        } else if (!playing && _state.status == PlaybackStatus.playing) {
          _emit(_state.copyWith(status: PlaybackStatus.paused));
        }
      }),
      player.stream.tracks.listen((_) => unawaited(_updateTracks())),
      player.stream.track.listen((_) => unawaited(_updateTracks())),
      // mpv decides on "auto" tracks once the stream plays.
      player.stream.playing.listen((_) => unawaited(_updateTracks())),
      player.stream.duration.listen(
        (duration) => _emit(_state.copyWith(duration: duration)),
      ),
      player.stream.width.listen(
        (width) => _emit(_state.copyWith(videoWidth: width)),
      ),
      player.stream.height.listen(
        (height) => _emit(_state.copyWith(videoHeight: height)),
      ),
      player.stream.error.listen((error) {
        // mpv also reports recoverable problems here; only failures to open
        // or decode stop playback.
        if (!player.state.playing) {
          debugPrint('player failed: $error');
          _emit(PlaybackState(status: PlaybackStatus.failed, error: error));
        }
      }),
      player.stream.completed.listen((completed) {
        // For live streams this means the server closed the stream.
        if (completed) {
          debugPrint('player ended');
          _emit(_state.copyWith(status: PlaybackStatus.ended));
        }
      }),
    ]);
    unawaited(_configureMpv());
    debugPrint(
      'player created: decoder ${settings.decoder.name}, passthrough '
      '${settings.passthrough.map((format) => format.mpvName).join(',')}',
    );
  }

  final Player player;
  late final VideoController controller;
  final PlayerSettings settings;

  static VideoControllerConfiguration _videoConfiguration(
    VideoDecoder decoder,
  ) {
    if (!_isAndroid) {
      // Elsewhere media_kit picks hardware decoding itself (PLAY-2).
      return switch (decoder) {
        VideoDecoder.hardware => const VideoControllerConfiguration(),
        VideoDecoder.hardwareCopy => const VideoControllerConfiguration(
          hwdec: 'auto-copy',
        ),
        VideoDecoder.software => const VideoControllerConfiguration(
          hwdec: 'no',
        ),
      };
    }
    return switch (decoder) {
      // The hardware decoder renders straight into the video surface.
      // Copying decoded frames back is slower and shows striped green
      // frames on some MediaTek chips such as the Fire TV Stick 4K Max, whose
      // decoders use their own pixel layouts. Other chips, for example in
      // the Nvidia Shield, show wrong colours this way instead.
      VideoDecoder.hardware => const VideoControllerConfiguration(
        vo: 'mediacodec_embed',
        hwdec: 'mediacodec',
      ),
      VideoDecoder.hardwareCopy => const VideoControllerConfiguration(
        vo: 'gpu',
        hwdec: 'mediacodec-copy',
      ),
      VideoDecoder.software => const VideoControllerConfiguration(
        vo: 'gpu',
        hwdec: 'no',
      ),
    };
  }

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  final _states = StreamController<PlaybackState>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _statsTimer;
  Stopwatch? _openedAt;
  bool _started = false;
  bool _bufferedSinceOpen = false;

  /// Playback details for diagnostic reports: shortly after a stream opens,
  /// again once the decoder settled (hardware decoding may only start with
  /// the video surface) and then every minute, so dropped frames and cache
  /// levels show up over time. Pausing or stalls do not restart the plan.
  void _scheduleStats() {
    _statsTimer?.cancel();
    _statsTimer = Timer(const Duration(seconds: 3), () {
      unawaited(_logStats());
      _statsTimer = Timer(const Duration(seconds: 12), () {
        unawaited(_logStats());
        _statsTimer = Timer.periodic(
          const Duration(minutes: 1),
          (_) => unawaited(_logStats()),
        );
      });
    });
  }

  static const _statsProperties = [
    'video-codec',
    'hwdec-current',
    'width',
    'height',
    'container-fps',
    'estimated-vf-fps',
    'video-bitrate',
    'audio-codec-name',
    'audio-params/channel-count',
    'current-ao',
    'audio-bitrate',
    'frame-drop-count',
    'decoder-frame-drop-count',
    'demuxer-cache-duration',
  ];

  Future<void> _logStats() async {
    final platform = player.platform;
    if (platform is! NativePlayer || _state.stopped) return;
    final values = <String>[];
    for (final property in _statsProperties) {
      try {
        final value = await platform.getProperty(property);
        if (value.isNotEmpty) values.add('$property=$value');
      } on Object {
        // Not every property exists for every stream.
      }
    }
    debugPrint('player stats: ${values.join(', ')}');
  }

  PlaybackState _state = PlaybackState.idle;

  @override
  Stream<PlaybackState> get states => _states.stream;

  @override
  PlaybackState get state => _state;

  void _emit(PlaybackState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }

  Future<void> _configureMpv() async {
    final platform = player.platform;
    if (platform is! NativePlayer) return;
    await platform.setProperty('network-timeout', '15');
    // Live streams are buffered in memory only.
    await platform.setProperty('cache-on-disk', 'no');
    // Subtitles stay off unless a stream marks them forced (for example for
    // foreign-language scenes); mpv would otherwise pick any track flagged
    // as default. Preferred languages per profile come later (SET-2).
    await platform.setProperty('subs-fallback', 'no');
    await platform.setProperty('subs-fallback-forced', 'yes');
    // Formats the receiver decodes itself; everything else becomes PCM.
    if (settings.passthrough.isNotEmpty) {
      await platform.setProperty(
        'audio-spdif',
        settings.passthrough.map((format) => format.mpvName).join(','),
      );
    }
    // Reconnect on short network drops of live streams.
    await platform.setProperty(
      'stream-lavf-o',
      'reconnect=1,reconnect_streamed=1,reconnect_delay_max=5',
    );
  }

  @override
  Future<void> open(String url, {Duration? start}) async {
    _emit(const PlaybackState(status: PlaybackStatus.opening));
    final platform = player.platform;
    if (platform is NativePlayer) {
      // mpv starts the next file at this position; `none` resets it.
      await platform.setProperty(
        'start',
        start == null || start <= Duration.zero ? 'none' : '${start.inSeconds}',
      );
    }
    debugPrint('player open: $url${start == null ? '' : ' at $start'}');
    _openedAt = Stopwatch()..start();
    _started = false;
    _bufferedSinceOpen = false;
    _scheduleStats();
    await player.open(Media(url));
  }

  @override
  Stream<Duration> get positions => player.stream.position;

  @override
  Duration get position => player.state.position;

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Stream<MediaTracks> get tracks => _tracks.stream;

  @override
  MediaTracks get currentTracks => _currentTracks;

  final _tracks = StreamController<MediaTracks>.broadcast();
  MediaTracks _currentTracks = MediaTracks.none;

  /// Id of the track mpv actually plays of a type (`audio`, `sub` or
  /// `video`). The selection reported by media_kit stays "auto" while mpv
  /// chooses itself, which would read as off.
  Future<String?> _currentTrackId(String type) async {
    final platform = player.platform;
    if (platform is! NativePlayer) return null;
    try {
      final id = await platform.getProperty('current-tracks/$type/id');
      return id.isEmpty ? null : id;
    } on Object {
      // The property does not exist while nothing of the type plays.
      return null;
    }
  }

  Future<void> _updateTracks() async {
    final available = player.state.tracks;
    final selected = player.state.track;
    // mpv lists the pseudo tracks "auto" and "no" with the real ones.
    bool real(String id) => id != 'auto' && id != 'no';
    Future<String?> selectedId(String id, String type) async =>
        id == 'auto' ? _currentTrackId(type) : (real(id) ? id : null);
    final audioId = await selectedId(selected.audio.id, 'audio');
    final subtitleId = await selectedId(selected.subtitle.id, 'sub');
    final videoId = await selectedId(selected.video.id, 'video');
    _currentTracks = MediaTracks(
      audio: [
        for (final t in available.audio)
          if (real(t.id))
            MediaTrack(
              id: t.id,
              type: MediaTrackType.audio,
              language: t.language,
              title: t.title,
              codec: t.codec,
              channels: t.channelscount ?? t.audiochannels,
            ),
      ],
      subtitle: [
        for (final t in available.subtitle)
          if (real(t.id))
            MediaTrack(
              id: t.id,
              type: MediaTrackType.subtitle,
              language: t.language,
              title: t.title,
              codec: t.codec,
            ),
      ],
      video: [
        for (final t in available.video)
          if (real(t.id))
            MediaTrack(
              id: t.id,
              type: MediaTrackType.video,
              title: t.title,
              codec: t.codec,
              width: t.w,
              height: t.h,
            ),
      ],
      selectedAudio: audioId,
      selectedSubtitle: subtitleId,
      selectedVideo: videoId,
    );
    if (!_tracks.isClosed) _tracks.add(_currentTracks);
  }

  @override
  Future<void> selectTrack(MediaTrackType type, String? id) async {
    final available = player.state.tracks;
    switch (type) {
      case MediaTrackType.audio:
        await player.setAudioTrack(
          available.audio.where((t) => t.id == id).firstOrNull ??
              AudioTrack.no(),
        );
      case MediaTrackType.subtitle:
        await player.setSubtitleTrack(
          available.subtitle.where((t) => t.id == id).firstOrNull ??
              SubtitleTrack.no(),
        );
      case MediaTrackType.video:
        await player.setVideoTrack(
          available.video.where((t) => t.id == id).firstOrNull ??
              VideoTrack.auto(),
        );
    }
  }

  @override
  Future<void> togglePause() => player.playOrPause();

  @override
  Future<void> stop() async {
    await player.stop();
    _emit(PlaybackState.idle);
  }

  @override
  Future<void> dispose() async {
    _statsTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _states.close();
    await _tracks.close();
    await player.dispose();
  }
}
