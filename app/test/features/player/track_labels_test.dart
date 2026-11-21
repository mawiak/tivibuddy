import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';
import 'package:tivibuddy/features/player/presentation/track_labels.dart';
import 'package:tivibuddy/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  MediaTrack audio({String? codec, int? channels, String? language}) =>
      MediaTrack(
        id: '1',
        type: MediaTrackType.audio,
        language: language,
        channels: channels,
        codec: codec,
      );

  test('audio tracks name the codec for passthrough', () {
    expect(
      trackLabel(l10n, audio(language: 'deu', channels: 6, codec: 'ac3'), 0),
      'German, 5.1 surround sound, Dolby Digital (AC3)',
    );
    expect(
      trackLabel(l10n, audio(language: 'eng', codec: 'dca'), 0),
      'English, DTS',
    );
    expect(
      trackLabel(l10n, audio(language: 'eng', channels: 2, codec: 'aac'), 0),
      'English, Stereo, AAC',
    );
    expect(
      trackLabel(l10n, audio(language: 'eng', codec: 'pcm_s16le'), 0),
      'English',
      reason: 'unclear decoder names are left out',
    );
  });

  test('measured frame rates snap to broadcast and film rates', () {
    expect(standardFrameRate(23.97602), 23.976);
    expect(standardFrameRate(24.02), 24);
    expect(standardFrameRate(49.95), 50);
    expect(standardFrameRate(59.94006), 59.94);
    expect(standardFrameRate(12.5), 12.5, reason: 'unusual rates stay');
  });
}
