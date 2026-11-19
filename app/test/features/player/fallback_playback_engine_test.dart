import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/player/data/fallback_playback_engine.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';

import '../../helpers/live_tv_fakes.dart';

/// Fails every stream whose URL contains `bad` before it plays.
class _PickyEngine extends FakePlaybackEngine {
  @override
  Future<void> open(String url, {Duration? start}) async {
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
}
