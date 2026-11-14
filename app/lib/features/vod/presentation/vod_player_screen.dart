import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../player/data/player_providers.dart';
import '../../player/domain/playback_engine.dart';
import '../../player/presentation/delayed_busy.dart';
import '../../player/presentation/playback_surface.dart';
import '../../player/presentation/playback_time.dart';
import '../../player/presentation/player_options.dart';

/// What the VOD player plays and where it reports progress to, so movies
/// and series episodes share one player.
class VodPlayerArgs {
  const VodPlayerArgs({
    required this.title,
    required this.resolveUrl,
    required this.saveProgress,
    this.start,
  });

  final String title;

  /// Resolves the playback URL, which can need provider details first.
  final Future<String> Function(WidgetRef ref) resolveUrl;

  /// Stores the position; called while playing, when the player closes and
  /// at the end of the media with the full duration.
  final Future<void> Function(Duration position, Duration? duration)
  saveProgress;

  /// Resume position, or null to start from the beginning.
  final Duration? start;
}

/// Full screen VOD playback with seeking and resume (PLAY-4, DATA-4).
class VodPlayerScreen extends ConsumerStatefulWidget {
  const VodPlayerScreen({super.key, required this.args});

  final VodPlayerArgs args;

  @override
  ConsumerState<VodPlayerScreen> createState() => _VodPlayerScreenState();
}

class _VodPlayerScreenState extends ConsumerState<VodPlayerScreen> {
  static const _seekStep = Duration(seconds: 10);
  static const _skipStep = Duration(seconds: 30);
  static const _osdDuration = Duration(seconds: 4);
  static const _saveEvery = Duration(seconds: 15);

  late final ProviderSubscription<PlaybackEngine> _engineSubscription;
  final _subscriptions = <StreamSubscription<Object?>>[];

  PlaybackEngine get _engine => _engineSubscription.read();
  VodPlayerArgs get _args => widget.args;

  PlaybackState _playback = PlaybackState.idle;
  Duration _position = Duration.zero;
  Timer? _osdTimer;
  Timer? _saveTimer;
  bool _osdVisible = true;
  bool _finished = false;
  final _keyFocus = FocusNode(debugLabel: 'vodPlayer');

  @override
  void initState() {
    super.initState();
    // Listening keeps the auto-disposed engine alive while this screen is
    // open; closing the subscription releases it.
    _engineSubscription = ref.listenManual(playbackEngineProvider, (_, _) {});
    _playback = _engine.state;
    _subscriptions.addAll([
      _engine.states.listen(_onState),
      _engine.positions.listen((position) {
        if (mounted) setState(() => _position = position);
      }),
    ]);
    _saveTimer = Timer.periodic(_saveEvery, (_) => _save());
    unawaited(_open(widget.args.start));
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    _showOsd();
  }

  @override
  void dispose() {
    _osdTimer?.cancel();
    _highlightTimer?.cancel();
    _saveTimer?.cancel();
    if (!_finished) _save();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _engineSubscription.close();
    _keyFocus.dispose();
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  Future<void> _open(Duration? start) async {
    final url = await _args.resolveUrl(ref);
    if (!mounted) return;
    await _engine.open(url, start: start);
  }

  void _onState(PlaybackState state) {
    if (!mounted) return;
    setState(() => _playback = state);
    if (state.status == PlaybackStatus.ended && !_finished) {
      // The end of the movie: watched, and the next start is from the
      // beginning.
      _finished = true;
      final duration = state.duration;
      unawaited(_args.saveProgress(duration ?? _position, duration));
      Navigator.of(context).maybePop();
    }
  }

  void _save() {
    // Positions before the first frame would overwrite a resume position.
    if (_position <= Duration.zero) return;
    unawaited(_args.saveProgress(_position, _playback.duration));
  }

  void _showOsd() {
    setState(() => _osdVisible = true);
    _osdTimer?.cancel();
    _osdTimer = Timer(_osdDuration, () {
      if (mounted) setState(() => _osdVisible = false);
    });
  }

  _OsdAction? _highlight;
  Timer? _highlightTimer;

  /// Lights up the control of [action] for a moment, so the key's effect is
  /// visible.
  void _flash(_OsdAction action) {
    _highlightTimer?.cancel();
    setState(() => _highlight = action);
    _highlightTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _highlight = null);
    });
  }

  void _playPause() {
    if (_playback.status == PlaybackStatus.failed) {
      unawaited(_open(_position));
    } else {
      unawaited(_engine.togglePause());
    }
    _flash(_OsdAction.playPause);
    _showOsd();
  }

  void _restart() {
    setState(() => _position = Duration.zero);
    unawaited(_engine.seek(Duration.zero));
    _showOsd();
  }

  /// Resolution and audio channels of the stream for the info bar.
  List<String> get _facts {
    final width = _playback.videoWidth;
    final height = _playback.videoHeight;
    final audio = _engine.currentTracks.selectedTrack(MediaTrackType.audio);
    return [
      if (width != null && height != null && width > 0) '$width×$height',
      ?switch (audio?.channels) {
        6 => '5.1',
        8 => '7.1',
        2 => '2.0',
        _ => null,
      },
    ];
  }

  void _seekBy(Duration offset) {
    _flash(offset.isNegative ? _OsdAction.rewind : _OsdAction.forward);
    final duration = _playback.duration;
    var target = _position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (duration != null && duration > Duration.zero && target > duration) {
      target = duration;
    }
    setState(() => _position = target);
    unawaited(_engine.seek(target));
    _showOsd();
  }

  /// Additional options (tracks) are open; they handle the keys.
  bool _optionsOpen = false;
  final _optionsKey = GlobalKey<PlayerOptionsState>();

  void _openOptions() {
    _osdTimer?.cancel();
    setState(() {
      _optionsOpen = true;
      _osdVisible = false;
    });
  }

  void _closeOptions() {
    setState(() => _optionsOpen = false);
    _keyFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // The options handle their keys themselves; unhandled ones go on to the
    // app-wide shortcuts, which move focus and select.
    if (_optionsOpen) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    // Down shows the info bar, down again the options, like common IPTV
    // players; the menu key opens the options directly.
    if (key == LogicalKeyboardKey.contextMenu ||
        (key == LogicalKeyboardKey.arrowDown && _osdVisible)) {
      if (event is KeyDownEvent) _openOptions();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _seekBy(-_seekStep);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _seekBy(_seekStep);
    } else if (key == LogicalKeyboardKey.mediaRewind) {
      _seekBy(-_skipStep);
    } else if (key == LogicalKeyboardKey.mediaFastForward) {
      _seekBy(_skipStep);
    } else if (event is KeyRepeatEvent) {
      return KeyEventResult.ignored;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA ||
        key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause) {
      _playPause();
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.info) {
      _showOsd();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final paused = _playback.status == PlaybackStatus.paused;
    final osdVisible = (_osdVisible || paused) && !_optionsOpen;
    return PopScope(
      canPop: !_optionsOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _optionsKey.currentState?.back();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _keyFocus,
          autofocus: true,
          onKeyEvent: _onKey,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_osdVisible) {
                unawaited(_engine.togglePause());
              }
              _showOsd();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlaybackSurface(engine: _engine),
                DelayedBusy(
                  busy: _playback.isBusy,
                  child: const Center(
                    child: SizedBox.square(
                      dimension: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
                if (_playback.status == PlaybackStatus.failed)
                  const _PlaybackError(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !osdVisible,
                    child: AnimatedOpacity(
                      opacity: osdVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: _VodOsd(
                        title: _args.title,
                        facts: _facts,
                        position: _position,
                        duration: _playback.duration,
                        paused: paused,
                        highlighted: _highlight,
                        onRewind: () => _seekBy(-_skipStep),
                        onPlayPause: _playPause,
                        onForward: () => _seekBy(_skipStep),
                        onRestart: _restart,
                      ),
                    ),
                  ),
                ),
                if (_optionsOpen)
                  PlayerOptions(
                    key: _optionsKey,
                    engine: _engine,
                    onClose: _closeOptions,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action of the last key, highlighted on its control for a moment.
enum _OsdAction { rewind, playPause, forward }

/// Info bar while playing, laid out like common IPTV players: title and
/// stream facts, progress, and the controls. The keys trigger the controls;
/// on touch screens they can be tapped.
class _VodOsd extends StatelessWidget {
  const _VodOsd({
    required this.title,
    required this.facts,
    required this.position,
    required this.duration,
    required this.paused,
    required this.highlighted,
    required this.onRewind,
    required this.onPlayPause,
    required this.onForward,
    required this.onRestart,
  });

  final String title;

  /// Short stream facts, for example "1920×800" and "5.1".
  final List<String> facts;
  final Duration position;
  final Duration? duration;
  final bool paused;
  final _OsdAction? highlighted;
  final VoidCallback onRewind;
  final VoidCallback onPlayPause;
  final VoidCallback onForward;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final duration = this.duration;
    final total = duration?.inMilliseconds ?? 0;

    Widget control(
      IconData icon,
      _OsdAction? action,
      VoidCallback onTap, {
      bool primary = false,
    }) {
      final active = primary || (action != null && action == highlighted);
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: primary ? 56 : 44,
          height: primary ? 56 : 44,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.textPrimary : null,
          ),
          child: Icon(
            icon,
            size: primary ? 32 : 28,
            color: active ? AppColors.background : AppColors.textPrimary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xE6000000)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              for (final fact in facts)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(fact, style: textTheme.bodySmall),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: total > 0
                  ? (position.inMilliseconds / total).clamp(0, 1)
                  : null,
              minHeight: 4,
              backgroundColor: AppColors.surfaceRaised,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  duration != null && duration > Duration.zero
                      ? '${formatPlaybackTime(position)} / '
                            '${formatPlaybackTime(duration)}'
                      : formatPlaybackTime(position),
                  style: textTheme.bodyMedium,
                ),
              ),
              control(Icons.fast_rewind, _OsdAction.rewind, onRewind),
              control(
                paused ? Icons.play_arrow : Icons.pause,
                _OsdAction.playPause,
                onPlayPause,
                primary: true,
              ),
              control(Icons.fast_forward, _OsdAction.forward, onForward),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: control(Icons.replay, null, onRestart),
                ),
              ),
            ],
          ),
          // Down again opens the options.
          const Icon(Icons.expand_more, color: AppColors.textSecondary),
        ],
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
            Text(l10n.vodPlayerFailed, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.vodPlayerRetryHint, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
