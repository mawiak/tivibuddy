import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/player/data/media3_playback_engine.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('io.github.mawiak.tivibuddy/media3');
  const events = 'io.github.mawiak.tivibuddy/media3/7';
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    messenger
      ..setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return call.method == 'create' ? {'id': 7, 'textureId': 3} : null;
      })
      // The event channel's listen and cancel calls.
      ..setMockMethodCallHandler(
        const MethodChannel(events),
        (_) async => null,
      );
  });

  tearDown(() {
    messenger
      ..setMockMethodCallHandler(channel, null)
      ..setMockMethodCallHandler(const MethodChannel(events), null);
  });

  Future<void> send(Map<String, Object?> event) async {
    await messenger.handlePlatformMessage(
      events,
      const StandardMethodCodec().encodeSuccessEnvelope(event),
      (_) {},
    );
    await pumpEventQueue();
  }

  test('maps player events to playback state and tracks', () async {
    final engine = Media3PlaybackEngine();
    addTearDown(engine.dispose);
    await engine.open('http://tv/live/u/p/1.ts');
    expect(calls.last.method, 'open');
    expect(calls.last.arguments, {'id': 7, 'url': 'http://tv/live/u/p/1.ts'});
    expect(engine.textureId.value, 3);
    expect(engine.state.status, PlaybackStatus.opening);

    // Buffering before the start is still opening, not a stall.
    await send({'event': 'state', 'state': 'buffering', 'playing': false});
    expect(engine.state.status, PlaybackStatus.opening);
    await send({'event': 'state', 'state': 'ready', 'playing': true});
    expect(engine.state.status, PlaybackStatus.playing);
    await send({'event': 'state', 'state': 'buffering', 'playing': false});
    expect(engine.state.status, PlaybackStatus.buffering);

    await send({
      'event': 'tracks',
      'audio': [
        {
          'id': '1:0',
          'language': 'deu',
          'mimeType': 'audio/ac3',
          'channels': 6,
          'selected': true,
        },
        {'id': '2:0', 'language': 'eng', 'mimeType': 'audio/mp4a-latm'},
      ],
      'text': [
        {'id': '3:0', 'language': 'deu', 'mimeType': 'text/x-ssa'},
      ],
    });
    final tracks = engine.currentTracks;
    expect(tracks.audio.map((t) => t.codec), ['ac3', 'aac']);
    expect(tracks.audio.first.channels, 6);
    expect(tracks.selectedAudio, '1:0');
    expect(tracks.subtitle.single.language, 'deu');
    expect(tracks.selectedSubtitle, isNull);

    await send({
      'event': 'videoSize',
      'width': 1920,
      'height': 1080,
      'ratio': 1.78,
    });
    expect(engine.aspectRatio.value, 1.78);
    expect(engine.state.videoWidth, 1920);

    await send({'event': 'cues', 'text': 'Hallo'});
    expect(engine.subtitle.value, 'Hallo');

    await engine.selectTrack(MediaTrackType.audio, '2:0');
    expect(calls.last.method, 'selectAudio');
    expect(calls.last.arguments, {'id': 7, 'track': '2:0'});
  });

  test('a player error fails the playback', () async {
    final engine = Media3PlaybackEngine();
    addTearDown(engine.dispose);
    await engine.open(
      'http://tv/movie/u/p/2.mkv',
      start: const Duration(seconds: 90),
    );
    expect(calls.last.arguments, {
      'id': 7,
      'url': 'http://tv/movie/u/p/2.mkv',
      'startMs': 90000,
    });
    await send({
      'event': 'error',
      'code': 'ERROR_CODE_DECODER_INIT_FAILED',
      'message': 'no decoder for audio/vnd.dts',
    });
    expect(engine.state.status, PlaybackStatus.failed);
    expect(engine.state.error, contains('DECODER_INIT_FAILED'));
  });
}
