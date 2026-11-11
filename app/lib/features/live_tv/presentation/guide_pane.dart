import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/data/paged_list.dart';
import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../settings/application/settings_providers.dart';
import '../application/epg_controller.dart';
import '../application/guide_providers.dart';
import '../application/live_catalog_controller.dart';
import '../application/live_tv_providers.dart';
import '../domain/live_channel.dart';
import 'channel_widgets.dart';
import 'live_player_screen.dart';

/// TV guide section (LIVE-2): programme grid of the channels of the
/// category selected in live TV.
class GuidePane extends ConsumerStatefulWidget {
  const GuidePane({super.key});

  @override
  ConsumerState<GuidePane> createState() => _GuidePaneState();
}

class _GuidePaneState extends ConsumerState<GuidePane> {
  String? _checkedPlaylistId;

  /// Loads channels and guide once per playlist when missing or outdated.
  void _ensureLoaded(String playlistId) {
    if (_checkedPlaylistId == playlistId) return;
    _checkedPlaylistId = playlistId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(liveCatalogControllerProvider(playlistId).notifier)
          .ensureFresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playlist = ref.watch(livePlaylistSelectionProvider);
    if (playlist == null) return _Message(l10n.guideNoChannels);

    _ensureLoaded(playlist.id);
    final categoryId = ref.watch(liveCategorySelectionProvider(playlist.id));
    final channels = ref
        .watch(liveChannelListProvider(playlist.id, categoryId))
        .value;
    if (channels == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (channels.length == 0) {
      final loading = ref.watch(
        liveCatalogControllerProvider(playlist.id),
      ) is LiveCatalogLoading;
      return loading
          ? const Center(child: CircularProgressIndicator())
          : _Message(l10n.guideNoChannels);
    }

    return GuideGrid(
      // A new category starts again at its first channel and now.
      key: ValueKey((playlist.id, categoryId)),
      playlistId: playlist.id,
      categoryId: categoryId,
      channels: channels,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// Length of the time slots the grid moves in where no programme is known.
const _slot = Duration(minutes: 30);

DateTime _floorSlot(DateTime time) {
  final slotMs = _slot.inMilliseconds;
  final ms = time.millisecondsSinceEpoch;
  return DateTime.fromMillisecondsSinceEpoch(ms - ms % slotMs, isUtc: true);
}

EpgEntry? _programmeAt(List<EpgEntry>? programmes, DateTime time) => programmes
    ?.where((p) => !p.start.isAfter(time) && p.end.isAfter(time))
    .firstOrNull;

/// The programme grid. Rows are channels (virtualized, fixed height), the
/// horizontal axis is time. Instead of one focus node per programme, the
/// grid is a single focus node that tracks the focused channel and a time
/// within the focused programme, which keeps thousands of programmes cheap
/// and lets up and down keep the time position like common IPTV guides.
class GuideGrid extends ConsumerStatefulWidget {
  const GuideGrid({
    super.key,
    required this.playlistId,
    required this.categoryId,
    required this.channels,
  });

  final String playlistId;
  final String? categoryId;
  final PagedList<LiveChannel> channels;

  @override
  ConsumerState<GuideGrid> createState() => _GuideGridState();
}

class _GuideGridState extends ConsumerState<GuideGrid> {
  final _focusNode = FocusNode(debugLabel: 'guide');
  final _scroll = ScrollController();
  late final Timer _ticker;

  DateTime _now = DateTime.now().toUtc();
  int _row = 0;

  /// Time inside the focused programme. Kept when moving between channels.
  late DateTime _anchor = _now;

  /// Time at the left edge of the grid.
  late DateTime _viewStart = _floorSlot(_now);

  /// Minutes visible in the grid, set by the layout.
  double _visibleMinutes = 120;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() => _now = DateTime.now().toUtc()),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Without catch-up the past is not reachable; left from the programme
  /// running now leaves the grid.
  DateTime get _minTime => _floorSlot(_now);

  DateTime get _maxTime {
    final days = ref.read(guideDaysProvider).value ?? defaultGuideDays;
    return _now.add(Duration(days: math.max(days, 1)));
  }

  DateTime get _viewEnd =>
      _viewStart.add(Duration(minutes: _visibleMinutes.floor()));

  List<EpgEntry>? _programmesOf(int row) {
    final key = widget.channels.itemAt(row)?.epgChannelId;
    if (key == null) return null;
    return ref
        .read(
          guideProgrammesProvider(
            widget.playlistId,
            key,
            guideChunkStart(_viewStart),
          ),
        )
        .value;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final page = math.max(1, _visibleRows - 1);

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.channelDown) {
      return _moveRow(1);
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.channelUp) {
      return _moveRow(-1);
    }
    if (key == LogicalKeyboardKey.pageDown) return _moveRow(page);
    if (key == LogicalKeyboardKey.pageUp) return _moveRow(-page);
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveRight();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) return _moveLeft();
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.gameButtonA) {
      if (event is KeyDownEvent) _play(_row);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  int get _visibleRows {
    if (!_scroll.hasClients) return 1;
    return (_scroll.position.viewportDimension / channelRowHeight).floor();
  }

  KeyEventResult _moveRow(int delta) {
    final row = (_row + delta).clamp(0, widget.channels.length - 1);
    if (row == _row) {
      // Up from the first channel reaches the header.
      return delta < 0 ? KeyEventResult.ignored : KeyEventResult.handled;
    }
    setState(() {
      _row = row;
      if (_anchor.isBefore(_viewStart)) _anchor = _viewStart;
    });
    _revealRow();
    return KeyEventResult.handled;
  }

  void _moveRight() {
    final current = _programmeAt(_programmesOf(_row), _anchor);
    final next = current?.end ?? _floorSlot(_anchor).add(_slot);
    if (!next.isBefore(_maxTime)) return;
    setState(() {
      _anchor = next;
      final latestStart = _viewEnd.subtract(_slot);
      if (!_anchor.isBefore(latestStart)) {
        _viewStart = _floorSlot(_anchor).subtract(_slot);
      }
    });
  }

  KeyEventResult _moveLeft() {
    final programmes = _programmesOf(_row);
    final current = _programmeAt(programmes, _anchor);
    final start = current?.start ?? _floorSlot(_anchor);
    if (!start.isAfter(_minTime)) return KeyEventResult.ignored;

    final before = start.subtract(const Duration(seconds: 1));
    final previous = _programmeAt(programmes, before);
    setState(() {
      final target = previous?.start ?? _floorSlot(before);
      _anchor = target.isBefore(_minTime) ? _minTime : target;
      if (_anchor.isBefore(_viewStart)) {
        final start = _floorSlot(_anchor);
        _viewStart = start.isBefore(_minTime) ? _minTime : start;
      }
    });
    return KeyEventResult.handled;
  }

  void _revealRow() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final top = _row * channelRowHeight;
    final bottom = top + channelRowHeight;
    if (top < position.pixels) {
      _scroll.jumpTo(top);
    } else if (bottom > position.pixels + position.viewportDimension) {
      _scroll.jumpTo(bottom - position.viewportDimension);
    }
  }

  /// Touch and mouse: dragging sideways moves the time axis.
  void _drag(DragUpdateDetails details, double pixelsPerMinute) {
    final minutes = -details.delta.dx / pixelsPerMinute;
    var start = _viewStart.add(Duration(seconds: (minutes * 60).round()));
    final latest = _maxTime.subtract(
      Duration(minutes: _visibleMinutes.floor()),
    );
    if (start.isAfter(latest)) start = latest;
    if (start.isBefore(_minTime)) start = _minTime;
    setState(() {
      _viewStart = start;
      if (_anchor.isBefore(_viewStart)) _anchor = _viewStart;
      if (!_anchor.isBefore(_viewEnd)) _anchor = _viewStart;
    });
  }

  void _play(int row) {
    if (widget.channels.itemAt(row) == null) return;
    context.push(
      AppRoutes.livePlayer,
      extra: LivePlayerArgs(
        playlistId: widget.playlistId,
        categoryId: widget.categoryId,
        index: row,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = ScreenClass.of(context).isPhone;
    final channelWidth = isPhone ? 96.0 : 200.0;
    final pixelsPerMinute = isPhone ? 4.0 : 5.0;
    final focusedChannel = widget.channels.itemAt(_row);

    return LayoutBuilder(
      builder: (context, constraints) {
        final timelineWidth = math.max(0, constraints.maxWidth - channelWidth);
        // A view must fit into one loading chunk (see guideChunk).
        _visibleMinutes = math.min(
          timelineWidth / pixelsPerMinute,
          guideChunk.inMinutes.toDouble(),
        );
        final chunkStart = guideChunkStart(_viewStart);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GuideDetails(
              playlistId: widget.playlistId,
              channel: focusedChannel,
              chunkStart: chunkStart,
              at: _anchor,
            ),
            _TimeRuler(
              viewStart: _viewStart,
              minutes: _visibleMinutes,
              pixelsPerMinute: pixelsPerMinute,
              inset: channelWidth,
            ),
            Expanded(
              // Only the rows take focus, so up from the first channel
              // finds the category button above them.
              child: Focus(
                focusNode: _focusNode,
                autofocus: true,
                onKeyEvent: _onKey,
                onFocusChange: (focused) => setState(() => _focused = focused),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _drag(details, pixelsPerMinute),
                  child: Stack(
                    children: [
                      ListenableBuilder(
                        listenable: widget.channels,
                        builder: (context, _) => ListView.builder(
                          controller: _scroll,
                          itemExtent: channelRowHeight,
                          itemCount: widget.channels.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() => _row = index);
                              _play(index);
                            },
                            child: _GuideRow(
                              playlistId: widget.playlistId,
                              channel: widget.channels.itemAt(index),
                              chunkStart: chunkStart,
                              viewStart: _viewStart,
                              minutes: _visibleMinutes,
                              pixelsPerMinute: pixelsPerMinute,
                              channelWidth: channelWidth,
                              now: _now,
                              focusedAt: _focused && index == _row
                                  ? _anchor
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      _NowLine(
                        left:
                            channelWidth +
                            _now.difference(_viewStart).inSeconds /
                                60 *
                                pixelsPerMinute,
                        visible:
                            !_now.isBefore(_viewStart) &&
                            _now.isBefore(_viewEnd),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NowLine extends StatelessWidget {
  const _NowLine({required this.left, required this.visible});

  final double left;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      left: left - 1,
      top: 0,
      bottom: 0,
      width: 2,
      child: const IgnorePointer(child: ColoredBox(color: AppColors.accent)),
    );
  }
}

/// Details of the focused programme above the grid, with the category and
/// the loading state of the guide.
class _GuideDetails extends ConsumerWidget {
  const _GuideDetails({
    required this.playlistId,
    required this.channel,
    required this.chunkStart,
    required this.at,
  });

  final String playlistId;
  final LiveChannel? channel;
  final DateTime chunkStart;
  final DateTime at;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final channel = this.channel;
    final key = channel?.epgChannelId;
    final programme = key == null
        ? null
        : _programmeAt(
            ref
                .watch(guideProgrammesProvider(playlistId, key, chunkStart))
                .value,
            at,
          );

    // Fixed height, so the grid does not jump between programmes with and
    // without description; content that does not fit is clipped.
    return SizedBox(
      height: 140,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel == null
                          ? ''
                          : '${channel.number}  ${channel.name}',
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programme?.title ??
                          AppLocalizations.of(context).liveNoProgramme,
                      style: textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (programme != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${formatTime(context, programme.start)} - '
                        '${formatTime(context, programme.end)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      if (programme.description case final description?) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CategoryButton(playlistId: playlistId),
                  const SizedBox(height: 8),
                  _GuideStatusText(playlistId: playlistId),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows and switches the category whose channels the guide lists. The
/// selection is shared with the live TV section.
class _CategoryButton extends ConsumerWidget {
  const _CategoryButton({required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final categories =
        ref.watch(liveCategoriesProvider(playlistId)).value ?? const [];
    final categoryId = ref.watch(liveCategorySelectionProvider(playlistId));
    final title =
        categories.where((c) => c.id == categoryId).firstOrNull?.name ??
        l10n.liveAllChannels;

    return TvFocusable(
      onSelect: () async {
        final chosen = await showTvChoiceDialog<String>(
          context,
          title: l10n.liveChooseCategory,
          choices: [
            TvChoice('', l10n.liveAllChannels),
            for (final c in categories) TvChoice(c.id, c.name),
          ],
        );
        if (chosen == null) return;
        ref
            .read(liveCategorySelectionProvider(playlistId).notifier)
            .select(chosen.isEmpty ? null : chosen);
      },
      builder: (context, focused) => Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: MarqueeText(
                title,
                active: focused,
                style: textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class _GuideStatusText extends ConsumerWidget {
  const _GuideStatusText({required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    final status = ref.watch(epgControllerProvider(playlistId));
    final days = ref.watch(guideDaysProvider).value;

    return switch (status) {
      GuideLoading(:final programmesLoaded) => Text(
        l10n.guideLoading(programmesLoaded),
        style: style,
      ),
      GuideFailed() => Text(
        l10n.guideFailed,
        style: style?.copyWith(color: AppColors.danger),
      ),
      GuideIdle() when days == 0 => Text(l10n.guideOff, style: style),
      GuideIdle() => const SizedBox.shrink(),
    };
  }
}

class _TimeRuler extends StatelessWidget {
  const _TimeRuler({
    required this.viewStart,
    required this.minutes,
    required this.pixelsPerMinute,
    required this.inset,
  });

  final DateTime viewStart;
  final double minutes;
  final double pixelsPerMinute;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final viewEnd = viewStart.add(Duration(minutes: minutes.floor()));
    final marks = <DateTime>[];
    for (
      var mark = _floorSlot(viewStart);
      mark.isBefore(viewEnd);
      mark = mark.add(_slot)
    ) {
      if (!mark.isBefore(viewStart)) marks.add(mark);
    }

    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: inset,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                DateFormat.MMMEd(locale).format(viewStart.toLocal()),
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: Stack(
                children: [
                  for (final mark in marks)
                    Positioned(
                      left:
                          mark.difference(viewStart).inSeconds /
                          60 *
                          pixelsPerMinute,
                      top: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          formatTime(context, mark),
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One channel of the grid with its programmes in the visible time range.
class _GuideRow extends ConsumerWidget {
  const _GuideRow({
    required this.playlistId,
    required this.channel,
    required this.chunkStart,
    required this.viewStart,
    required this.minutes,
    required this.pixelsPerMinute,
    required this.channelWidth,
    required this.now,
    required this.focusedAt,
  });

  final String playlistId;

  /// Null while the row's page of channels loads.
  final LiveChannel? channel;
  final DateTime chunkStart;
  final DateTime viewStart;
  final double minutes;
  final double pixelsPerMinute;
  final double channelWidth;
  final DateTime now;

  /// Time of the focused programme when this row has focus.
  final DateTime? focusedAt;

  double _x(DateTime time) =>
      time.difference(viewStart).inSeconds / 60 * pixelsPerMinute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final channel = this.channel;
    final key = channel?.epgChannelId;
    final programmes = key == null
        ? const <EpgEntry>[]
        : ref
                  .watch(guideProgrammesProvider(playlistId, key, chunkStart))
                  .value ??
              const <EpgEntry>[];
    final viewEnd = viewStart.add(Duration(minutes: minutes.floor()));
    final width = minutes * pixelsPerMinute;
    final focusedAt = this.focusedAt;

    Widget cell(DateTime start, DateTime end, Widget child, bool focused) {
      final left = math.max(0.0, _x(start));
      final right = math.min(width, _x(end));
      return Positioned(
        left: left,
        width: math.max(0, right - left),
        top: 2,
        bottom: 2,
        child: _Cell(
          focused: focused,
          live: !start.isAfter(now) && end.isAfter(now),
          child: child,
        ),
      );
    }

    final visible = programmes
        .where((p) => p.end.isAfter(viewStart) && p.start.isBefore(viewEnd))
        .toList();
    final focusedProgramme = focusedAt == null
        ? null
        : _programmeAt(programmes, focusedAt);

    final cells = <Widget>[
      for (final programme in visible)
        cell(
          programme.start,
          programme.end,
          _ProgrammeText(
            title: programme.title,
            time: formatTime(context, programme.start),
            active: identical(programme, focusedProgramme),
          ),
          identical(programme, focusedProgramme),
        ),
      if (visible.isEmpty)
        cell(
          viewStart,
          viewEnd,
          _ProgrammeText(title: l10n.guideNoInformation, active: false),
          focusedAt != null,
        )
      else if (focusedAt != null && focusedProgramme == null)
        cell(
          _floorSlot(focusedAt),
          _floorSlot(focusedAt).add(_slot),
          _ProgrammeText(title: l10n.guideNoInformation, active: false),
          true,
        ),
    ];

    return Row(
      children: [
        SizedBox(
          width: channelWidth,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    channel == null ? '' : '${channel.number}',
                    style: textTheme.bodySmall,
                  ),
                ),
                ChannelLogo(url: channel?.logoUrl, size: 32),
                if (channelWidth > 120) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: MarqueeText(
                      channel?.name ?? '',
                      active: focusedAt != null,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: ClipRect(child: Stack(children: cells)),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.focused, required this.live, required this.child});

  final bool focused;
  final bool live;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 2),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: focused
          ? AppColors.focusFill
          : live
          ? AppColors.surfaceRaised
          : AppColors.surface,
      borderRadius: BorderRadius.circular(4),
      border: focused
          ? Border.all(color: AppColors.focusBorder, width: 2)
          : null,
    ),
    alignment: Alignment.centerLeft,
    child: child,
  );
}

class _ProgrammeText extends StatelessWidget {
  const _ProgrammeText({required this.title, required this.active, this.time});

  final String title;
  final String? time;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final time = this.time;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarqueeText(title, active: active, style: textTheme.bodyMedium),
        if (time != null)
          Text(
            time,
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
      ],
    );
  }
}
