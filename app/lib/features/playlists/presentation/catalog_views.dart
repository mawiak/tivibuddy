import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../domain/catalog_access.dart';

// Views shared by the sections that show a provider catalog (live TV,
// movies, series).

String describeCatalogFailure(
  AppLocalizations l10n,
  CatalogLoadFailure reason,
) => switch (reason) {
  CatalogLoadFailure.unauthorized => l10n.liveLoadUnauthorized,
  CatalogLoadFailure.unreachable => l10n.liveLoadUnreachable,
  CatalogLoadFailure.invalidResponse => l10n.liveLoadInvalid,
  CatalogLoadFailure.missingPassword => l10n.liveLoadMissingPassword,
};

/// The active profile has no playlist yet.
class NoPlaylistView extends StatelessWidget {
  const NoPlaylistView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.playlist_add,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(l10n.liveNoPlaylistTitle, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TvButton(
              label: l10n.playlistAdd,
              icon: Icons.add,
              style: TvButtonStyle.primary,
              autofocus: true,
              onPressed: () => context.push(AppRoutes.newPlaylist),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown while a catalog has no entries yet: loading progress, failure with
/// retry, or empty with a refresh button.
class CatalogStateView extends StatelessWidget {
  const CatalogStateView({
    super.key,
    required this.loadingTitle,
    required this.emptyText,
    required this.refreshLabel,
    required this.onRetry,
    this.loadedText,
    this.failure,
  });

  /// Non-null while loading, for example "1200 channels loaded".
  final String? loadedText;
  final CatalogLoadFailure? failure;
  final String loadingTitle;
  final String emptyText;
  final String refreshLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final loadedText = this.loadedText;
    final failure = this.failure;

    final List<Widget> content;
    if (loadedText != null) {
      content = [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(loadingTitle, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(loadedText, style: textTheme.bodySmall),
      ];
    } else if (failure != null) {
      content = [
        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
        const SizedBox(height: 16),
        Text(
          describeCatalogFailure(l10n, failure),
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TvButton(
          label: l10n.liveRetry,
          icon: Icons.refresh,
          style: TvButtonStyle.primary,
          autofocus: true,
          onPressed: onRetry,
        ),
      ];
    } else {
      content = [
        Text(emptyText, style: textTheme.titleMedium),
        const SizedBox(height: 24),
        TvButton(
          label: refreshLabel,
          icon: Icons.refresh,
          autofocus: true,
          onPressed: onRetry,
        ),
      ];
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: content),
      ),
    );
  }
}
