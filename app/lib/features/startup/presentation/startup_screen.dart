import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/app_startup.dart';

/// Shown while the database opens. The router leaves this screen as soon as
/// startup has completed.
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: startup.hasError
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.startupFailed(startup.error.toString()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              )
            : CircularProgressIndicator(semanticsLabel: l10n.commonLoading),
      ),
    );
  }
}
