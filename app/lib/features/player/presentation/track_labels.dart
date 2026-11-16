import '../../../l10n/app_localizations.dart';
import '../domain/playback_engine.dart';

/// Name of a track language code (ISO 639-1 or -2), or null when unknown.
String? languageName(AppLocalizations l10n, String? code) =>
    switch (code?.toLowerCase()) {
      'de' || 'deu' || 'ger' => l10n.trackLanguageDe,
      'en' || 'eng' => l10n.trackLanguageEn,
      'fr' || 'fra' || 'fre' => l10n.trackLanguageFr,
      'es' || 'spa' => l10n.trackLanguageEs,
      'it' || 'ita' => l10n.trackLanguageIt,
      'tr' || 'tur' => l10n.trackLanguageTr,
      'pl' || 'pol' => l10n.trackLanguagePl,
      'ru' || 'rus' => l10n.trackLanguageRu,
      'nl' || 'nld' || 'dut' => l10n.trackLanguageNl,
      'pt' || 'por' => l10n.trackLanguagePt,
      'ar' || 'ara' => l10n.trackLanguageAr,
      'ja' || 'jpn' => l10n.trackLanguageJa,
      _ => null,
    };

String? _channelLayout(AppLocalizations l10n, int? channels) =>
    switch (channels) {
      null || <= 0 => null,
      1 => l10n.playerChannelsMono,
      2 => l10n.playerChannelsStereo,
      6 => l10n.playerChannels51,
      8 => l10n.playerChannels71,
      final count => l10n.playerChannelsCount(count),
    };

/// Name of an audio codec as players and receivers show it, so users see
/// which tracks a receiver can take through passthrough.
String? audioCodecName(AppLocalizations l10n, String? codec) =>
    switch (codec?.toLowerCase()) {
      null || '' => null,
      'ac3' => l10n.audioFormatAc3,
      'eac3' => l10n.audioFormatEac3,
      'dts' || 'dca' => l10n.audioFormatDts,
      'truehd' || 'mlp' => l10n.audioFormatTrueHd,
      'mp2' || 'mp3' || 'aac' || 'opus' || 'flac' => codec!.toUpperCase(),
      // Raw decoder names are unclear to users.
      _ => null,
    };

/// Readable name of a track, for example "German, 5.1 surround sound,
/// Dolby Digital (AC3)".
String trackLabel(AppLocalizations l10n, MediaTrack track, int index) {
  final language =
      languageName(l10n, track.language) ?? track.language?.toUpperCase();
  final title = track.title;
  final parts = switch (track.type) {
    MediaTrackType.audio => [
      ?language,
      // Titles often repeat the language; they only help without one.
      if (language == null) ?title,
      ?_channelLayout(l10n, track.channels),
      ?audioCodecName(l10n, track.codec),
    ],
    MediaTrackType.subtitle => [?language, ?title],
    MediaTrackType.video => [
      if (track.width != null && track.height != null)
        '${track.width} × ${track.height}',
      if (track.width == null) ?title,
    ],
  };
  return parts.isEmpty ? l10n.playerTrackNumber(index + 1) : parts.join(', ');
}
