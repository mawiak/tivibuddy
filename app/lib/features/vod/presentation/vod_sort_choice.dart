import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../application/vod_sort_providers.dart';
import '../domain/vod_filter.dart';
import '../domain/vod_sort.dart';

String vodSortLabel(AppLocalizations l10n, VodSort sort) => switch (sort) {
  VodSort.provider => l10n.vodSortProvider,
  VodSort.added => l10n.vodSortAdded,
  VodSort.nameAscending => l10n.vodSortNameAscending,
  VodSort.nameDescending => l10n.vodSortNameDescending,
  VodSort.rating => l10n.vodSortRating,
  VodSort.year => l10n.vodSortYear,
};

/// Lets the user choose the sort order of the list [filter] of [section].
Future<void> chooseVodSort(
  BuildContext context,
  WidgetRef ref,
  VodSection section,
  VodFilter filter,
) async {
  if (!filter.sortable) return;
  final l10n = AppLocalizations.of(context);
  final selection = vodSortSelectionProvider(section, filter.key);
  final current = ref.read(selection);
  final chosen = await showTvChoiceDialog<VodSort>(
    context,
    title: l10n.vodSort,
    choices: [
      for (final sort in vodSortChoices[section]!)
        TvChoice(
          sort,
          vodSortLabel(l10n, sort),
          icon: sort == current ? Icons.check : null,
        ),
    ],
  );
  if (chosen != null) await ref.read(selection.notifier).select(chosen);
}

/// Sort button of an opened list, at the top right of the grid like in
/// common IPTV players; up from the first row of posters reaches it.
class VodSortButton extends ConsumerWidget {
  const VodSortButton({super.key, required this.section, required this.filter});

  final VodSection section;
  final VodFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final sort = ref.watch(vodSortSelectionProvider(section, filter.key));
    return TvFocusable(
      onSelect: () => chooseVodSort(context, ref, section, filter),
      builder: (context, focused) => Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : const Color(0x99161B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 20),
            const SizedBox(width: 6),
            Text(vodSortLabel(l10n, sort), style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
