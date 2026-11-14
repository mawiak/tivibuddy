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

/// Readable name of a track, for example "German, 5.1 surround sound".
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
