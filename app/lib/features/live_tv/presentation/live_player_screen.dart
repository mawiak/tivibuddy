import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/paged_list.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../player/data/player_providers.dart';
import '../../player/domain/playback_engine.dart';
import '../../player/presentation/delayed_busy.dart';
import '../../player/presentation/playback_surface.dart';
import '../../player/presentation/player_options.dart';
import '../application/live_tv_providers.dart';
import '../domain/live_channel.dart';
import 'channel_widgets.dart';

class LivePlayerArgs {
  const LivePlayerArgs({
    required this.playlistId,
    required this.categoryId,
    required this.index,
  });

  final String playlistId;
  final String? categoryId;

  /// Position of the channel to start with in the category list.
  final int index;
}

/// Full screen live playback with zapping, info OSD and channel list
/// overlay (LIVE-1).
class LivePlayerScreen extends ConsumerStatefulWidget {
  const LivePlayerScreen({super.key, required this.args});

  final LivePlayerArgs args;

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen> {
  /// Time without further zapping before a channel is actually opened, so
  /// pressing up several times does not start every stream in between.
  static const _zapDelay = Duration(milliseconds: 450);
  static const _osdDuration = Duration(seconds: 5);

  late final ProviderSubscription<PlaybackEngine> _engineSubscription;
  late final ProviderSubscription<AsyncValue<PagedList<LiveChannel>>>
  _listSubscription;
  StreamSubscription<PlaybackState>? _stateSubscription;

  PlaybackEngine get _engine => _engineSubscription.read();
  PagedList<LiveChannel>? _channels;
  PlaybackState _playback = PlaybackState.idle;

  late int _index = widget.args.index;
  LiveChannel? _channel;
  LiveChannel? _playingChannel;
  Timer? _zapTimer;
  Timer? _osdTimer;
  bool _osdVisible = true;
  bool _listVisible = false;
  final _keyFocus = FocusNode(debugLabel: 'livePlayer');

  @override
  void initState() {
    super.initState();
    // Listening keeps the auto-disposed engine alive while this screen is
    // open; closing the subscription releases it.
    _engineSubscription = ref.listenManual(playbackEngineProvider, (_, _) {});
    _playback = _engine.state;
    _stateSubscription = _engine.states.listen(
      (state) => setState(() => _playback = state),
    );
    _listSubscription = ref.listenManual(
      liveChannelListProvider(widget.args.playlistId, widget.args.categoryId),
      (_, next) {
        final list = next.value;
        if (list == null) return;
        final first = _channels == null;
        _channels = list;
        if (first) _tune(_index, immediately: true);
      },
      fireImmediately: true,
    );

    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
  }

  @override
  void dispose() {
    _zapTimer?.cancel();
    _osdTimer?.cancel();
    _stateSubscription?.cancel();
    _listSubscription.close();
    _engineSubscription.close();
    _keyFocus.dispose();
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  Future<void> _tune(int index, {bool immediately = false}) async {
    final channels = _channels;
    if (channels == null || channels.length == 0) return;
    final wrapped = index % channels.length;
    _index = wrapped;
    final channel = await channels.fetch(wrapped);
    if (!mounted || channel == null || _index != wrapped) return;

    setState(() => _channel = channel);
    _showOsd();
    _zapTimer?.cancel();
    _zapTimer = Timer(
      immediately ? Duration.zero : _zapDelay,
      () => _play(channel),
    );
  }

  /// Jumps back to the channel played before, like common IPTV players do
  /// with right. Only within the same channel list; otherwise, or without
  /// one, it just shows the channel info.
  void _tunePrevious() {
    final previous = ref.read(nowPlayingProvider.notifier).previous;
    final position = previous?.position;
    if (position == null ||
        position.playlistId != widget.args.playlistId ||
        position.categoryId != widget.args.categoryId ||
        position.index == _index) {
      _showOsd();
      return;
    }
    _tune(position.index, immediately: true);
  }

  Future<void> _play(LiveChannel channel, {bool retry = false}) async {
    final nowPlaying = ref.read(nowPlayingProvider.notifier);
    // Coming from the guide preview, the channel already plays.
    final status = _engine.state.status;
    if (!retry &&
        ref.read(nowPlayingProvider)?.channel == channel &&
        status != PlaybackStatus.idle &&
        !_engine.state.stopped) {
      _playingChannel = channel;
      return;
    }
    final url = await ref.read(liveStreamUrlProvider(channel).future);
    if (!mounted || _channel != channel) return;
    _playingChannel = channel;
    nowPlaying.set((
      playlistId: widget.args.playlistId,
      categoryId: widget.args.categoryId,
      index: _index,
    ), channel);
    await _engine.open(url, live: true);
  }

  void _showOsd() {
    setState(() => _osdVisible = true);
    _osdTimer?.cancel();
    _osdTimer = Timer(_osdDuration, () {
      if (mounted) setState(() => _osdVisible = false);
    });
  }

  void _toggleList(bool visible) {
    setState(() => _listVisible = visible);
    if (!visible) _keyFocus.requestFocus();
  }

  /// Additional options (tracks) are open; they handle the keys.
  bool _optionsOpen = false;
  final _optionsKey = GlobalKey<PlayerOptionsState>();

  void _closeOptions() {
    setState(() => _optionsOpen = false);
    _keyFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // The options handle their keys themselves; unhandled ones go on to the
    // app-wide shortcuts, which move focus and select.
    if (_optionsOpen) return KeyEventResult.ignored;
    // This handler sits above the channel list and sees its keys before the
    // app-wide shortcuts do, so up and down would zap instead of moving the
    // focus through the list.
    if (_listVisible) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    // Up and down switch channels, so the options open with the menu key.
    if (key == LogicalKeyboardKey.contextMenu) {
      if (event is KeyDownEvent) {
        _osdTimer?.cancel();
        setState(() {
          _optionsOpen = true;
          _osdVisible = false;
        });
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.channelUp ||
        key == LogicalKeyboardKey.pageUp) {
      _tune(_index - 1);
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.channelDown ||
        key == LogicalKeyboardKey.pageDown) {
      _tune(_index + 1);
    } else if (event is KeyRepeatEvent) {
      return KeyEventResult.ignored;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA) {
      final channel = _channel;
      // A live stream that ends was closed by the server: an error, too.
      if (_playback.stopped && channel != null) {
        _play(channel, retry: true);
      } else {
        _toggleList(true);
      }
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.mediaLast) {
      _tunePrevious();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.info) {
      _showOsd();
    } else if (key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause) {
      _engine.togglePause();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final channel = _channel;
    return PopScope(
      canPop: !_listVisible && !_optionsOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_optionsOpen) {
          _optionsKey.currentState?.back();
        } else {
          _toggleList(false);
        }
      },
      child: Scaffold(
        // The video layer of Media3 shows through (PlaybackSurface).
        backgroundColor: Colors.transparent,
        body: Focus(
          focusNode: _keyFocus,
          autofocus: true,
          onKeyEvent: _onKey,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleList(!_listVisible),
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 300) _tune(_index + (velocity < 0 ? 1 : -1));
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlaybackSurface(engine: _engine),
                Positioned(
                  top: 24,
                  right: 24,
                  child: DelayedBusy(
                    busy: _playback.isBusy,
                    child: const SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
                if (_playback.stopped && _playingChannel == channel)
                  const _PlaybackError(),
                if (channel != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _osdVisible && !_listVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: _ChannelOsd(channel: channel),
                      ),
                    ),
                  ),
                if (_optionsOpen)
                  PlayerOptions(
                    key: _optionsKey,
                    engine: _engine,
                    onClose: _closeOptions,
                  ),
                if (_listVisible && _channels != null)
                  _ChannelListOverlay(
                    channels: _channels!,
                    currentIndex: _index,
                    onSelect: (index) {
                      _toggleList(false);
                      _tune(index, immediately: true);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaybackError extends StatelessWidget {
  const _PlaybackError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(l10n.playerFailed, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.playerRetryHint, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Bottom bar with channel and programme information.
class _ChannelOsd extends ConsumerWidget {
  const _ChannelOsd({required this.channel});

  final LiveChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final nowNext = ref.watch(nowNextProvider(channel)).value;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xE6000000)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${channel.number}',
            style: textTheme.headlineSmall?.copyWith(color: AppColors.accent),
          ),
          const SizedBox(width: 20),
          ChannelLogo(url: channel.logoUrl, size: 64),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  channel.name,
                  style: textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                NowNextView(nowNext: nowNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Channel list over the video, opened with select.
class _ChannelListOverlay extends StatefulWidget {
  const _ChannelListOverlay({
    required this.channels,
    required this.currentIndex,
    required this.onSelect,
  });

  final PagedList<LiveChannel> channels;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  State<_ChannelListOverlay> createState() => _ChannelListOverlayState();
}

class _ChannelListOverlayState extends State<_ChannelListOverlay> {
  late final _scroll = ScrollController(
    initialScrollOffset:
        (widget.currentIndex - 3).clamp(0, 1 << 30) * channelRowHeight,
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 400,
      child: ColoredBox(
        color: const Color(0xE6101418),
        child: FocusScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  l10n.playerChannelList,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.channels,
                  builder: (context, _) => ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemExtent: channelRowHeight,
                    itemCount: widget.channels.length,
                    itemBuilder: (context, index) => ChannelRow(
                      key: ValueKey(index),
                      channel: widget.channels.itemAt(index),
                      autofocus: index == widget.currentIndex,
                      current: index == widget.currentIndex,
                      onSelect: () => widget.onSelect(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
