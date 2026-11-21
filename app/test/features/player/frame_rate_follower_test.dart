import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/player/data/display_frame_rate.dart';
import 'package:tivibuddy/features/player/data/fallback_playback_engine.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';
import 'package:tivibuddy/features/player/domain/player_settings.dart';

import '../../helpers/live_tv_fakes.dart';

/// Offers mode 24 for 23.976 fps and mode 50 for 50 fps; the default is 0.
class _FakeDisplay implements DisplayModeSwitcher {
  _FakeDisplay([this.duringSwitch]);

  /// Runs while the TV switches, like an engine reporting a stall then.
  final void Function()? duringSwitch;
  final applied = <int>[];
  int current = 0;

  @override
  Future<({int modeId, String message})> find(double fps) async {
    final mode = switch (fps) {
      23.976 => 24,
      50 => 50,
      _ => 0,
    };
    return (modeId: mode == current ? 0 : mode, message: 'find $fps');
  }

  @override
  Future<String> apply(int modeId) async {
    duringSwitch?.call();
    applied.add(modeId);
    current = modeId;
    return 'apply $modeId';
  }

  @override
  Future<bool> isSwitched() async => current != 0;
}

void main() {
  late FakePlaybackEngine inner;
  late FallbackPlaybackEngine engine;
  late _FakeDisplay display;
  final steps = <String>[];

  setUp(() {
    steps.clear();
    display = _FakeDisplay();
    inner = FakePlaybackEngine();
    engine = FallbackPlaybackEngine([
      (name: 'fake', create: () => inner),
    ], platform: 'test');
    engine.states.listen((state) => steps.add(state.status.name));
  });

  tearDown(() => engine.dispose());

  Future<void> play({required bool live, required double fps}) async {
    await engine.open('http://stream', live: live);
    inner.emit(PlaybackState(status: PlaybackStatus.playing, frameRate: fps));
    await pumpEventQueue();
  }

  test('pauses, switches, rebuilds the audio output and resumes', () async {
    FrameRateFollower(engine, FrameRateMatching.always, display).start();
    await play(live: false, fps: 23.976);

    expect(display.applied, [24]);
    expect(inner.audioRefreshes, 1);
    expect(steps, containsAllInOrder(['playing', 'paused', 'playing']));

    // The same rate again needs no switch.
    await play(live: true, fps: 23.976);
    expect(display.applied, [24]);

    await play(live: true, fps: 50);
    expect(display.applied, [24, 50]);
  });

  test('films and series only: live TV goes back to the default', () async {
    FrameRateFollower(engine, FrameRateMatching.vodOnly, display).start();
    await play(live: false, fps: 23.976);
    expect(display.applied, [24]);

    await play(live: true, fps: 50);
    expect(display.applied, [24, 0]);

    // Live TV at the default rate stays there.
    await play(live: true, fps: 25);
    expect(display.applied, [24, 0]);
  });

  test(
    'resumes even when the engine reports a stall during the switch',
    () async {
      display = _FakeDisplay(
        () => inner.emit(const PlaybackState(status: PlaybackStatus.buffering)),
      );
      FrameRateFollower(engine, FrameRateMatching.always, display).start();
      await play(live: false, fps: 23.976);
      expect(display.applied, [24]);
      expect(engine.state.status, PlaybackStatus.playing);
    },
  );
}
