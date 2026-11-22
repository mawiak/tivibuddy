import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../about/application/app_version_providers.dart';
import '../application/update_controller.dart';

/// Shows the state of the update controller until it is closed: the new
/// version with its notes, the download progress and the steps to install.
Future<void> showUpdateDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _UpdateDialog());

class _UpdateDialog extends ConsumerWidget {
  const _UpdateDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(updateControllerProvider.notifier);
    final state = ref.watch(updateControllerProvider);
    void close() => Navigator.of(context).pop();

    final (
      String title,
      List<Widget> body,
      List<Widget> actions,
    ) = switch (state) {
      UpdateAvailable(:final release) => (
        l10n.updateAvailableTitle(release.version),
        [
          Text(
            l10n.updateInstalledVersion(
              ref.watch(appVersionProvider).value ?? '',
            ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(_plainNotes(release.notes), style: textTheme.bodyMedium),
        ],
        [
          TvButton(
            label: l10n.updateLater,
            onPressed: () {
              controller.dismiss();
              close();
            },
          ),
          TvButton(
            label: l10n.updateNow,
            icon: Icons.system_update,
            style: TvButtonStyle.primary,
            autofocus: true,
            onPressed: controller.download,
          ),
        ],
      ),
      UpdateDownloading(:final release, :final progress) => (
        l10n.updateAvailableTitle(release.version),
        [
          Text(
            l10n.updateDownloading((progress * 100).round()),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
        ],
        const <Widget>[],
      ),
      UpdateNeedsPermission(:final release) => (
        l10n.updateAvailableTitle(release.version),
        [Text(l10n.updateNeedsPermission, style: textTheme.bodyMedium)],
        [
          TvButton(
            label: l10n.updateOpenSettings,
            icon: Icons.settings,
            autofocus: true,
            onPressed: controller.openInstallPermission,
          ),
          TvButton(
            label: l10n.updateInstall,
            style: TvButtonStyle.primary,
            onPressed: controller.retryInstall,
          ),
        ],
      ),
      UpdateInstalling(:final release) => (
        l10n.updateAvailableTitle(release.version),
        [Text(l10n.updateInstalling, style: textTheme.bodyMedium)],
        [TvButton(label: l10n.commonDone, autofocus: true, onPressed: close)],
      ),
      UpdateChecking() || UpdateIdle() => (
        l10n.settingsUpdates,
        [
          Row(
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: 16),
              Text(l10n.updateChecking, style: textTheme.bodyMedium),
            ],
          ),
        ],
        const <Widget>[],
      ),
      UpdateUpToDate(:final version) => (
        l10n.settingsUpdates,
        [Text(l10n.updateUpToDate(version), style: textTheme.bodyMedium)],
        [TvButton(label: l10n.commonDone, autofocus: true, onPressed: close)],
      ),
      UpdateFailed() => (
        l10n.settingsUpdates,
        [Text(l10n.updateFailed, style: textTheme.bodyMedium)],
        [TvButton(label: l10n.commonDone, autofocus: true, onPressed: close)],
      ),
    };

    return Dialog(
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...body,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Release notes without Markdown markers, at most a few lines.
String _plainNotes(String notes) {
  final lines = [
    for (final line in notes.split('\n'))
      if (line.trim().isNotEmpty)
        line.replaceFirst(RegExp(r'^#+\s*'), '').replaceFirst('- ', '• '),
  ];
  return lines.length > 12
      ? '${lines.take(12).join('\n')}\n…'
      : lines.join('\n');
}
