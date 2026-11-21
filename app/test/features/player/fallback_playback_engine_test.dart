import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/player/data/fallback_playback_engine.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';

import '../../helpers/live_tv_fakes.dart';

/// Never answers for streams whose URL contains `hang`.
class _HangingEngine extends FakePlaybackEngine {
  @override
  Future<void> open(String url, {Duration? start, bool live = false}) async {
    if (!url.contains('hang')) return super.open(url, start: start);
    opened.add(url);
    emit(const PlaybackState(status: PlaybackStatus.opening));
  }
}

/// Fails every stream whose URL contains `bad` before it plays.
class _PickyEngine extends FakePlaybackEngine {
  @override
  Future<void> open(String url, {Duration? start, bool live = false}) async {
    if (!url.contains('bad')) return super.open(url, start: start);
    opened.add(url);
    emit(const PlaybackState(status: PlaybackStatus.failed, error: 'codec'));
  }
}

void main() {
  late List<FakePlaybackEngine> created;
  late FallbackPlaybackEngine chain;
  final statuses = <PlaybackStatus>[];

  setUp(() {
    created = [];
    statuses.clear();
    chain = FallbackPlaybackEngine([
      (
        name: 'first',
        create: () {
          final engine = _PickyEngine();
          created.add(engine);
          return engine;
        },
      ),
      (
        name: 'second',
        create: () {
          final engine = FakePlaybackEngine();
          created.add(engine);
          return engine;
        },
      ),
    ], platform: 'test');
    chain.states.listen((state) => statuses.add(state.status));
  });

  tearDown(() => chain.dispose());

  test('plays with the first engine when it can', () async {
    await chain.open('http://good');
    await pumpEventQueue();
    expect(created, hasLength(1));
    expect(chain.active.value, same(created.single));
    expect(chain.state.status, PlaybackStatus.playing);
  });

  test('falls back to the next engine and back for the next stream', () async {
    await chain.open('http://bad', start: const Duration(seconds: 5));
    await pumpEventQueue();
    expect(created, hasLength(2));
    expect(created.first.disposed, isTrue, reason: 'one engine at a time');
    expect(created.last.opened, ['http://bad']);
    expect(created.last.starts, [const Duration(seconds: 5)]);
    expect(statuses, isNot(contains(PlaybackStatus.failed)));
    expect(chain.state.status, PlaybackStatus.playing);

    await chain.open('http://good');
    await pumpEventQueue();
    expect(created, hasLength(3));
    expect(chain.active.value, same(created.last));
    expect(created.last.opened, ['http://good']);
  });

  test('reports a failure when no engine can play the stream', () async {
    final single = FallbackPlaybackEngine([
      (name: 'only', create: _PickyEngine.new),
    ], platform: 'test');
    addTearDown(single.dispose);
    await single.open('http://bad');
    await pumpEventQueue();
    expect(single.state.status, PlaybackStatus.failed);
  });

  test('an engine that hangs is replaced after the start timeout', () async {
    final engines = <FakePlaybackEngine>[];
    final hanging = FallbackPlaybackEngine(
      [
        (
          name: 'hangs',
          create: () {
            final engine = _HangingEngine();
            engines.add(engine);
            return engine;
          },
        ),
        (
          name: 'works',
          create: () {
            final engine = FakePlaybackEngine();
            engines.add(engine);
            return engine;
          },
        ),
      ],
      platform: 'test',
      startTimeout: const Duration(milliseconds: 100),
    );
    addTearDown(hanging.dispose);
    await hanging.open('http://hang');
    expect(engines, hasLength(1));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(engines, hasLength(2));
    expect(engines.last.opened, ['http://hang']);
    expect(hanging.state.status, PlaybackStatus.playing);
  });

  test('in the background live TV stops and restarts, films pause', () async {
    await chain.open('http://good/live', live: true);
    await pumpEventQueue();
    await chain.suspend();
    expect(created.single.opened, ['http://good/live']);
    expect(chain.state.status, isNot(PlaybackStatus.playing));

    await chain.resume();
    await pumpEventQueue();
    expect(created.last.opened.last, 'http://good/live');
    expect(chain.state.status, PlaybackStatus.playing);

    await chain.open('http://good/film');
    await pumpEventQueue();
    await chain.suspend();
    expect(chain.state.status, PlaybackStatus.paused);
    final opens = created.last.opened.length;
    await chain.resume();
    expect(created.last.opened, hasLength(opens), reason: 'films stay paused');
    expect(chain.state.status, PlaybackStatus.paused);
  });
}
