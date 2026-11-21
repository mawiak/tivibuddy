import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/playback_engine.dart';
import '../domain/player_settings.dart';
import 'fallback_playback_engine.dart';

/// Display modes of the device (`DisplayModes.kt`).
class DisplayModeSwitcher {
  const DisplayModeSwitcher();

  static const _channel = MethodChannel('io.github.mawiak.tivibuddy/display');

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// The mode that shows [fps], 0 when the current one fits or none does,
  /// and a message for the log.
  Future<({int modeId, String message})> find(double fps) async {
    final result = await _channel.invokeMapMethod<String, Object?>('find', {
      'fps': fps,
    });
    return (
      modeId: result?['modeId'] as int? ?? 0,
      message: '${result?['message']}',
    );
  }

  /// Switches to [modeId], 0 for the default, and completes once the TV
  /// has settled.
  Future<String> apply(int modeId) async =>
      await _channel.invokeMethod<String>('apply', {'modeId': modeId}) ?? '';

  Future<bool> isSwitched() async =>
      await _channel.invokeMethod<bool>('isSwitched') ?? false;
}

/// Lets the display follow the frame rate of what [engine] plays (PLAY-6).
///
/// Playback pauses while the TV switches: picture and sound would stall
/// anyway, and HDMI renegotiates audio, so the audio output is rebuilt
/// afterwards to keep passthrough. The display stays at the last rate when
/// the player closes, which saves a switch when the next stream fits.
class FrameRateFollower {
  FrameRateFollower(
    this.engine,
    this.matching, [
    this.display = const DisplayModeSwitcher(),
  ]);

  final FallbackPlaybackEngine engine;
  final FrameRateMatching matching;
  final DisplayModeSwitcher display;

  StreamSubscription<PlaybackState>? _subscription;
  double? _matched;
  bool _busy = false;

  void start() => _subscription = engine.states.listen(_onState);

  Future<void> stop() async => _subscription?.cancel();

  Future<void> _onState(PlaybackState state) async {
    if (_busy || state.status != PlaybackStatus.playing) return;
    _busy = true;
    try {
      if (matching == FrameRateMatching.vodOnly && engine.live) {
        // TV after a film: back to the display's default rate.
        if (_matched != null || await display.isSwitched()) {
          _matched = null;
          debugPrint('display: live TV keeps the default mode');
          await _switch(0);
        }
        return;
      }
      final fps = state.frameRate;
      if (fps == null || fps == _matched) return;
      _matched = fps;
      final target = await display.find(fps);
      debugPrint(target.message);
      if (target.modeId != 0) await _switch(target.modeId);
    } on Exception catch (error) {
      debugPrint('display: switching failed: $error');
    } finally {
      _busy = false;
    }
  }

  Future<void> _switch(int modeId) async {
    // Explicit pause and resume: during the switch the engine reports
    // buffering rather than paused, so toggling would pause again.
    final wasPlaying = engine.state.status == PlaybackStatus.playing;
    if (wasPlaying) await engine.setPaused(true);
    debugPrint(await display.apply(modeId));
    await engine.refreshAudioOutput();
    if (wasPlaying) await engine.setPaused(false);
  }
}
