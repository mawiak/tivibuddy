import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../domain/playback_engine.dart';

/// libmpv with FFmpeg through media_kit: plays practically every container
/// and codec, with hardware decoding where available (PLAY-1, PLAY-2).
class MediaKitPlaybackEngine implements PlaybackEngine {
  MediaKitPlaybackEngine()
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
      configuration: _isAndroid
          // The hardware decoder renders straight into the video surface.
          // Copying decoded frames back (the default) is slower and shows
          // striped green frames on MediaTek chips such as the Fire TV
          // Stick Lite, whose decoders use their own pixel layouts.
          ? const VideoControllerConfiguration(
              vo: 'mediacodec_embed',
              hwdec: 'mediacodec',
            )
          // Elsewhere media_kit picks hardware decoding itself (PLAY-2).
          : const VideoControllerConfiguration(),
    );
    _subscriptions.addAll([
      // Warnings and errors of mpv end up in the platform log (logcat on
      // Android), which is the only way to diagnose streams on devices.
      player.stream.log.listen(
        (log) => debugPrint('mpv ${log.level} ${log.prefix}: ${log.text}'),
      ),
      player.stream.buffering.listen((buffering) {
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
        if (_state.status == PlaybackStatus.failed) return;
        if (playing && !player.state.buffering) {
          _emit(_state.copyWith(status: PlaybackStatus.playing));
        } else if (!playing && _state.status == PlaybackStatus.playing) {
          _emit(_state.copyWith(status: PlaybackStatus.paused));
        }
      }),
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
          _emit(PlaybackState(status: PlaybackStatus.failed, error: error));
        }
      }),
      player.stream.completed.listen((completed) {
        // A live stream that "completes" was closed by the server.
        if (completed) {
          _emit(
            const PlaybackState(
              status: PlaybackStatus.failed,
              error: 'Stream ended',
            ),
          );
        }
      }),
    ]);
    unawaited(_configureMpv());
  }

  final Player player;
  late final VideoController controller;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  final _states = StreamController<PlaybackState>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
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
    // Reconnect on short network drops of live streams.
    await platform.setProperty(
      'stream-lavf-o',
      'reconnect=1,reconnect_streamed=1,reconnect_delay_max=5',
    );
  }

  @override
  Future<void> open(String url) async {
    _emit(const PlaybackState(status: PlaybackStatus.opening));
    await player.open(Media(url));
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
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _states.close();
    await player.dispose();
  }
}
