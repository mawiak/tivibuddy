import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../application/app_version_providers.dart';

/// Version, license and legal disclaimer.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(l10n.appTitle, style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.aboutVersion(ref.watch(appVersionProvider).value ?? ''),
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                _Paragraph(
                  title: l10n.aboutLicenseTitle,
                  text: l10n.aboutLicenseText,
                ),
                _Paragraph(
                  title: l10n.aboutDisclaimerTitle,
                  text: l10n.aboutDisclaimerText,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TvButton(
                    label: l10n.aboutOpenSourceLicenses,
                    icon: Icons.description_outlined,
                    autofocus: true,
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: l10n.appTitle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Text block that can receive focus, so long texts scroll into view with
/// the D-pad.
class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      builder: (context, focused) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsetsDirectional.only(start: 12),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(
              color: focused ? AppColors.accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(text, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
