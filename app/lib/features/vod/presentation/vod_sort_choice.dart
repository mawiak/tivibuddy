import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../application/vod_sort_providers.dart';
import '../domain/vod_sort.dart';
import 'vod_browser.dart';

String vodSortLabel(AppLocalizations l10n, VodSort sort) => switch (sort) {
  VodSort.provider => l10n.vodSortProvider,
  VodSort.added => l10n.vodSortAdded,
  VodSort.nameAscending => l10n.vodSortNameAscending,
  VodSort.nameDescending => l10n.vodSortNameDescending,
  VodSort.rating => l10n.vodSortRating,
  VodSort.year => l10n.vodSortYear,
};

/// Lets the user choose the sort order of [section].
Future<void> chooseVodSort(
  BuildContext context,
  WidgetRef ref,
  VodSection section,
) async {
  final l10n = AppLocalizations.of(context);
  final chosen = await showTvChoiceDialog<VodSort>(
    context,
    title: l10n.vodSort,
    choices: [
      for (final sort in vodSortChoices[section]!)
        TvChoice(sort, vodSortLabel(l10n, sort)),
    ],
  );
  if (chosen != null) {
    await ref.read(vodSortSelectionProvider(section).notifier).select(chosen);
  }
}

/// Category entry showing and changing the sort order of [section].
VodCategoryEntry vodSortEntry(
  BuildContext context,
  WidgetRef ref,
  VodSection section,
) {
  final l10n = AppLocalizations.of(context);
  final sort = ref.watch(vodSortSelectionProvider(section));
  return VodCategoryEntry.action(
    label: l10n.vodSortEntry(vodSortLabel(l10n, sort)),
    icon: Icons.sort,
    onSelect: () => chooseVodSort(context, ref, section),
  );
}
