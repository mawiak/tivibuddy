import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../player/data/player_providers.dart';
import '../../player/domain/playback_engine.dart';
import '../../player/presentation/playback_surface.dart';
import '../../player/presentation/playback_time.dart';

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

  void _seekBy(Duration offset) {
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

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

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
      if (_playback.status == PlaybackStatus.failed) {
        unawaited(_open(_position));
      } else {
        unawaited(_engine.togglePause());
      }
      _showOsd();
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
    return Scaffold(
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
              if (_playback.isBusy)
                const Center(
                  child: SizedBox.square(
                    dimension: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              if (_playback.status == PlaybackStatus.failed)
                const _PlaybackError(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _osdVisible || paused ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: _VodOsd(
                      title: _args.title,
                      position: _position,
                      duration: _playback.duration,
                      paused: paused,
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

class _VodOsd extends StatelessWidget {
  const _VodOsd({
    required this.title,
    required this.position,
    required this.duration,
    required this.paused,
  });

  final String title;
  final Duration position;
  final Duration? duration;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final duration = this.duration;
    final total = duration?.inMilliseconds ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xE6000000)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                paused ? Icons.pause : Icons.play_arrow,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          const SizedBox(height: 6),
          Row(
            children: [
              Text(formatPlaybackTime(position), style: textTheme.bodySmall),
              const Spacer(),
              if (duration != null && duration > Duration.zero)
                Text(formatPlaybackTime(duration), style: textTheme.bodySmall),
            ],
          ),
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
