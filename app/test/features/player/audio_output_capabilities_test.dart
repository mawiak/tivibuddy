import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/player/data/audio_output_capabilities.dart';
import 'package:tivibuddy/features/player/domain/player_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('io.github.mawiak.tivibuddy/audio');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('maps the encodings the output accepts', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'passthroughCapabilities');
      return {
        'formats': [5, 7, 18, 2],
        'details': {'hdmiPlugged': true},
      };
    });
    final support = await const AudioOutputCapabilities().query();
    expect(support!.formats, {
      AudioPassthrough.ac3,
      AudioPassthrough.dts,
      AudioPassthrough.eac3,
    });
    expect(support.details['hdmiPlugged'], isTrue);
  });

  test('a failed query passes nothing through', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'boom'),
    );
    final support = await const AudioOutputCapabilities().query();
    expect(support!.formats, isEmpty);
  });
}
