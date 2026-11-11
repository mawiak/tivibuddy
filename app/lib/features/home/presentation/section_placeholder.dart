import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../application/home_section.dart';
import 'home_section_display.dart';

/// Temporary content for sections that are not implemented yet.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final features = section.plannedFeatures(l10n);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.label(l10n), style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l10n.comingSoon, style: textTheme.bodySmall),
          const SizedBox(height: 24),
          Text(l10n.plannedFeatures, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) =>
                  _FeatureRow(text: features[index], autofocus: index == 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, this.autofocus = false});

  final String text;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      builder: (context, focused) => Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: MarqueeText(
          text,
          active: focused,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
