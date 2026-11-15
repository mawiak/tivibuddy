import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/paged_list.dart';
import '../../../core/layout/screen_class.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/content_hooks.dart';
import '../../../shared/widgets/focus_memory_scope.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/push_aside.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import 'poster_tile.dart';

/// An entry of the category column: a list to show ([key] set) or an
/// action such as choosing the playlist ([onSelect] only).
class VodCategoryEntry {
  const VodCategoryEntry.list({
    required Object this.key,
    required this.label,
    this.count,
  }) : icon = null,
       onSelect = null;

  const VodCategoryEntry.action({
    required this.label,
    required IconData this.icon,
    required VoidCallback this.onSelect,
  }) : key = null,
       count = null;

  /// Identifies the list, for example a filter value.
  final Object? key;
  final String label;
  final int? count;
  final IconData? icon;
  final VoidCallback? onSelect;
}

/// Builds the tile of [item] (null while its page loads) at [index].
typedef VodTileBuilder<T> = Widget Function(
  BuildContext context,
  T? item,
  int index, {
  required bool autofocus,
  void Function(bool focused, BuildContext tileContext)? onFocusChange,
});

/// Category list plus poster grid of a VOD section (VOD-1), shared by
/// movies and series.
///
/// On TV the grid uses the full width below the details of the focused
/// title, one row of posters with the next one peeking in. Left from the
/// first column or back opens the categories next to it, focused on the
/// selected one; select or right on a category closes them. Entering the
/// section from the menu starts in the categories, like common IPTV players.
class VodBrowser<T> extends StatefulWidget {
  const VodBrowser({
    super.key,
    required this.loading,
    required this.items,
    required this.listKey,
    required this.listTitle,
    required this.entries,
    required this.onListFocused,
    required this.tileBuilder,
    required this.infoBuilder,
    this.emptyView,
    this.gridKey,
    this.onMenu,
    this.headerAction,
    this.updating = false,
    this.updatingLabel,
  });

  /// The catalog is not available yet; shows progress, and an entry from
  /// the menu opens the categories once it is.
  final bool loading;

  /// Shown instead of the grid when the catalog is empty or failed.
  final Widget? emptyView;

  /// Items of the selected list; null while it opens.
  final PagedList<T>? items;

  /// Key of the selected list entry.
  final Object listKey;

  /// Changes start the grid again at its first poster, for example a new
  /// sort order; defaults to [listKey].
  final Object? gridKey;

  /// The menu key, for example to choose the sort order.
  final VoidCallback? onMenu;

  /// Shown at the top right of the grid, for example to sort the list; up
  /// from the first row of posters reaches it.
  final Widget? headerAction;
  final String listTitle;
  final List<VodCategoryEntry> entries;

  /// Lists switch as soon as their entry is focused.
  final ValueChanged<Object> onListFocused;
  final VodTileBuilder<T> tileBuilder;

  /// Details of the focused item above the grid (TV only).
  final Widget Function(BuildContext context, T? item) infoBuilder;

  /// A catalog refresh runs; shown next to the title on phones.
  final bool updating;
  final String? updatingLabel;

  @override
  State<VodBrowser<T>> createState() => _VodBrowserState<T>();
}

class _VodBrowserState<T> extends State<VodBrowser<T>> {
  bool _categoriesOpen = false;
  bool _showsGrid = false;
  bool _enterPending = false;

  /// While the categories are open, a new grid must not take focus with its
  /// first poster.
  late final _gridScope = FocusMemoryScopeNode(
    debugLabel: 'vodGrid',
    allowAutofocus: () => !_categoriesOpen,
  );
  final _categoryScope = FocusMemoryScopeNode(debugLabel: 'vodCategories');
  ContentHooksController? _hooks;

  /// Item shown in the details above the grid. Updated after focus rested
  /// briefly, so moving over posters does not load details for every item
  /// passed.
  final _infoItem = ValueNotifier<T?>(null);
  Timer? _infoDelay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hooks?.unregister(back: _onBack, enter: _onEnter);
    _hooks = ContentHooks.maybeOf(context)
      ?..register(back: _onBack, enter: _onEnter);
  }

  @override
  void dispose() {
    _hooks?.unregister(back: _onBack, enter: _onEnter);
    _infoDelay?.cancel();
    _infoItem.dispose();
    _gridScope.dispose();
    _categoryScope.dispose();
    super.dispose();
  }

  void _onItemFocused(T? item) {
    _infoDelay?.cancel();
    _infoDelay = Timer(
      const Duration(milliseconds: 300),
      () => _infoItem.value = item,
    );
  }

  bool _onEnter() {
    if (ScreenClass.of(context).isPhone) return false;
    if (!_showsGrid) {
      // Still loading: the categories open as soon as they are there, and
      // focus stays in the menu meanwhile.
      if (!widget.loading) return false;
      _enterPending = true;
      return true;
    }
    if (_categoriesOpen) {
      _categoryScope.enter();
    } else {
      _openCategories();
    }
    return true;
  }

  /// Back from the grid opens the categories; back from the categories is
  /// left to the home screen, which focuses the menu.
  bool _onBack() {
    if (_categoriesOpen || !_gridScope.hasFocus) return false;
    if (ScreenClass.of(context).isPhone) return false;
    _openCategories();
    return true;
  }

  // The category column focuses the selected entry when it opens.
  void _openCategories() => setState(() => _categoriesOpen = true);

  void _closeCategories({bool focusGrid = true}) {
    if (!_categoriesOpen) return;
    setState(() => _categoriesOpen = false);
    if (!focusGrid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gridScope.enter();
    });
  }

  @override
  Widget build(BuildContext context) {
    _showsGrid = false;
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final emptyView = widget.emptyView;
    if (emptyView != null) return emptyView;

    final isPhone = ScreenClass.of(context).isPhone;
    if (isPhone) {
      return _VodGrid<T>(
        key: ValueKey(widget.gridKey ?? widget.listKey),
        items: widget.items,
        posterWidth: 112,
        tileBuilder: widget.tileBuilder,
        header: _PhoneHeader(
          title: widget.listTitle,
          entries: widget.entries,
          onListFocused: widget.onListFocused,
          updatingLabel: widget.updating ? widget.updatingLabel : null,
          action: widget.headerAction,
        ),
      );
    }

    _showsGrid = true;
    if (_enterPending) {
      _enterPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onEnter();
      });
    }
    final grid = _VodGrid<T>(
      // A new list starts at its first poster.
      key: ValueKey(widget.gridKey ?? widget.listKey),
      items: widget.items,
      // One row of posters below the details, the next one peeking in.
      posterWidth: 150,
      onFocused: _onItemFocused,
      tileBuilder: widget.tileBuilder,
      header: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _infoItem,
            builder: (context, item, _) => widget.infoBuilder(context, item),
          ),
          if (widget.headerAction case final action?)
            Positioned(top: 12, right: 16, child: action),
        ],
      ),
    );

    final row = PushAside(
      open: _categoriesOpen,
      panelWidth: 240,
      panel: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        // Focus moving into the grid, for example by touch, closes the
        // categories. The side menu and dialogs leave them open, like
        // in common IPTV players.
        onFocusChange: (focused) {
          if (!focused && _gridScope.hasFocus) {
            _closeCategories(focusGrid: false);
          }
        },
        child: ExitRight(
          onRight: _closeCategories,
          // Left from the categories reaches the menu through the
          // LeaveLeft of the home screen.
          child: LeaveLeft(
            child: FocusScope(
              node: _categoryScope,
              child: FocusTraversalGroup(
                child: _CategoryColumn(
                  entries: widget.entries,
                  selected: widget.listKey,
                  onListFocused: widget.onListFocused,
                  onChosen: _closeCategories,
                ),
              ),
            ),
          ),
        ),
      ),
      child: LeaveLeft(
        onLeftEdge: _openCategories,
        child: FocusScope(
          node: _gridScope,
          child: FocusTraversalGroup(child: grid),
        ),
      ),
    );
    final onMenu = widget.onMenu;
    if (onMenu == null) return row;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent ||
            event.logicalKey != LogicalKeyboardKey.contextMenu) {
          return KeyEventResult.ignored;
        }
        onMenu();
        return KeyEventResult.handled;
      },
      child: row,
    );
  }
}

/// Title of the selected list on phones, which also opens the choice of
/// lists.
class _PhoneHeader extends StatelessWidget {
  const _PhoneHeader({
    required this.title,
    required this.entries,
    required this.onListFocused,
    this.updatingLabel,
    this.action,
  });

  final String title;
  final List<VodCategoryEntry> entries;
  final ValueChanged<Object> onListFocused;
  final String? updatingLabel;
  final Widget? action;

  Future<void> _choose(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showTvChoiceDialog<Object>(
      context,
      title: l10n.liveChooseCategory,
      choices: [
        for (final entry in entries)
          if (entry.key case final key?) TvChoice(key, entry.label),
      ],
    );
    if (chosen != null) onListFocused(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final updatingLabel = this.updatingLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TvFocusable(
              onSelect: () => _choose(context),
              builder: (context, focused) => Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (updatingLabel != null) ...[
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(updatingLabel, style: textTheme.bodySmall),
          ],
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}

/// Poster grid with fixed cell sizes, so it is virtualized and jumps to any
/// row without measuring (RES-3, UI-3).
class _VodGrid<T> extends StatelessWidget {
  const _VodGrid({
    super.key,
    required this.items,
    required this.header,
    required this.posterWidth,
    required this.tileBuilder,
    this.onFocused,
  });

  final PagedList<T>? items;
  final Widget header;

  /// Width posters aim for; columns fill the available width.
  final double posterWidth;
  final VodTileBuilder<T> tileBuilder;

  /// Called with the item whose tile got focus. When set, the focused row
  /// scrolls to the top, so the row below shows only partly.
  final ValueChanged<T?>? onFocused;

  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = this.items;
    final onFocused = this.onFocused;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: switch (items) {
            null => const SizedBox.shrink(),
            PagedList(length: 0) => Center(
              child: Text(
                l10n.moviesEmptyList,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _ => LayoutBuilder(
              builder: (context, constraints) {
                final columns = math.max(
                  2,
                  ((constraints.maxWidth - 32 + _spacing) /
                          (posterWidth + _spacing))
                      .floor(),
                );
                return ListenableBuilder(
                  listenable: items,
                  builder: (context, _) => GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: _spacing,
                      crossAxisSpacing: _spacing,
                      mainAxisExtent: PosterTile.extentFor(
                        (constraints.maxWidth - 32 - (columns - 1) * _spacing) /
                            columns,
                      ),
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items.itemAt(index);
                      return KeyedSubtree(
                        key: ValueKey(index),
                        child: tileBuilder(
                          context,
                          item,
                          index,
                          autofocus: index == 0,
                          onFocusChange: onFocused == null
                              ? null
                              : (focused, tileContext) {
                                  if (!focused) return;
                                  onFocused(item);
                                  Scrollable.ensureVisible(
                                    tileContext,
                                    duration: const Duration(milliseconds: 150),
                                  );
                                },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          },
        ),
      ],
    );
  }
}

class _CategoryColumn extends StatefulWidget {
  const _CategoryColumn({
    required this.entries,
    required this.selected,
    required this.onListFocused,
    required this.onChosen,
  });

  final List<VodCategoryEntry> entries;
  final Object selected;
  final ValueChanged<Object> onListFocused;

  /// Select on a list: it is chosen, the column closes.
  final VoidCallback onChosen;

  @override
  State<_CategoryColumn> createState() => _CategoryColumnState();
}

class _CategoryColumnState extends State<_CategoryColumn> {
  /// The column opens scrolled to the selected entry, so its tile is built
  /// and can take focus; lists only build the visible rows.
  late final _scroll = ScrollController(
    initialScrollOffset: math.max(0, _openedIndex - 3) * _CategoryTile.extent,
  );

  /// Focus node of the entry selected when the column opened. It stays with
  /// that tile, so moving on and changing the selection never moves a
  /// focused node between tiles.
  final _openedOn = FocusNode(debugLabel: 'openedVodCategory');
  late final Object _openedKey = widget.selected;

  int get _openedIndex =>
      math.max(0, widget.entries.indexWhere((e) => e.key == widget.selected));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openedOn.requestFocus();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _openedOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    return ColoredBox(
      color: AppColors.surface,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemExtent: _CategoryTile.extent,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final key = entry.key;
          return _CategoryTile(
            label: entry.label,
            count: entry.count,
            icon: entry.icon,
            selected: key != null && key == widget.selected,
            focusNode: key != null && key == _openedKey ? _openedOn : null,
            onFocus: key == null ? null : () => widget.onListFocused(key),
            onSelect:
                entry.onSelect ??
                () {
                  // A tap selects without focusing, so the list switches
                  // here too.
                  if (key != null) widget.onListFocused(key);
                  widget.onChosen();
                },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    this.count,
    this.icon,
    this.selected = false,
    this.focusNode,
    this.onFocus,
    this.onSelect,
  });

  /// Height of a tile including its gap, fixed for jumping to an entry.
  static const extent = 46.0;

  final String label;
  final int? count;
  final IconData? icon;
  final bool selected;
  final FocusNode? focusNode;

  /// Lists switch the grid as soon as they are focused, like the live TV
  /// categories.
  final VoidCallback? onFocus;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = this.icon;
    final count = this.count;
    return TvFocusable(
      focusNode: focusNode,
      onFocusChange: (focused) {
        if (focused) onFocus?.call();
      },
      onSelect: onSelect,
      builder: (context, focused) {
        final color = selected ? AppColors.accent : AppColors.textPrimary;
        return Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: focused ? AppColors.focusFill : null,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: focused ? AppColors.focusBorder : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: MarqueeText(
                  label,
                  active: focused,
                  style: textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
              if (count != null) Text('$count', style: textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
