import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/input/tv_shortcuts.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/player/application/player_settings_providers.dart';
import 'features/settings/application/settings_providers.dart';
import 'l10n/app_localizations.dart';

class TiviBuddyApp extends ConsumerWidget {
  const TiviBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Loads the stored player settings before the first playback.
    ref.listen(playerSettingsControllerProvider, (_, _) {});
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: switch (ref.watch(appLanguageProvider)) {
        final tag? => Locale.fromSubtags(
          languageCode: tag.split('-').first,
          countryCode: tag.contains('-') ? tag.split('-').last : null,
        ),
        null => null,
      },
      shortcuts: {...WidgetsApp.defaultShortcuts, ...tvShortcuts},
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
