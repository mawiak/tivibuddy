import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../application/home_section.dart';

extension HomeSectionDisplay on HomeSection {
  IconData get icon => switch (this) {
    HomeSection.liveTv => Icons.live_tv_outlined,
    HomeSection.guide => Icons.view_timeline_outlined,
    HomeSection.movies => Icons.movie_outlined,
    HomeSection.series => Icons.video_library_outlined,
    HomeSection.search => Icons.search,
    HomeSection.settings => Icons.settings_outlined,
  };

  String label(AppLocalizations l10n) => switch (this) {
    HomeSection.liveTv => l10n.navLiveTv,
    HomeSection.guide => l10n.navGuide,
    HomeSection.movies => l10n.navMovies,
    HomeSection.series => l10n.navSeries,
    HomeSection.search => l10n.navSearch,
    HomeSection.settings => l10n.navSettings,
  };

  List<String> plannedFeatures(AppLocalizations l10n) => switch (this) {
    HomeSection.liveTv => [
      l10n.featureLiveChannels,
      l10n.featureLiveGuide,
      l10n.featureLiveCatchup,
    ],
    HomeSection.guide => [l10n.featureLiveGuide],
    HomeSection.movies => [
      l10n.featureMoviesBrowse,
      l10n.featureMoviesResume,
      l10n.featureMoviesMetadata,
    ],
    HomeSection.series => [
      l10n.featureSeriesEpisodes,
      l10n.featureSeriesContinue,
    ],
    HomeSection.search => [l10n.featureSearchGlobal],
    HomeSection.settings => [l10n.featureSettingsProfiles],
  };
}
