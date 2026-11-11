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
    // Hardware decoding is enabled by default (PLAY-2).
    controller = VideoController(player);
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
