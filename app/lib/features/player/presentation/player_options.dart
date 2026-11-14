import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../domain/playback_engine.dart';
import 'track_labels.dart';

/// Additional options of the players (PLAY-4): a bar at the bottom with
/// audio, subtitle and video track; select on an entry opens a side panel
/// with the tracks to choose from, like common IPTV players.
///
/// The player shows this while it is open and forwards the back key to
/// [PlayerOptionsState.back].
class PlayerOptions extends StatefulWidget {
  const PlayerOptions({super.key, required this.engine, required this.onClose});

  final PlaybackEngine engine;
  final VoidCallback onClose;

  @override
  State<PlayerOptions> createState() => PlayerOptionsState();
}

class PlayerOptionsState extends State<PlayerOptions> {
  late MediaTracks _tracks = widget.engine.currentTracks;
  late final StreamSubscription<MediaTracks> _subscription;
  MediaTrackType? _panel;
  final _scope = FocusScopeNode(debugLabel: 'playerOptions');

  /// Entry of the panel that gets focus when it opens: the selected track.
  final _panelFocus = FocusNode(debugLabel: 'playerOptionsPanel');
  final _entries = {
    for (final type in MediaTrackType.values)
      type: FocusNode(debugLabel: 'playerOption.${type.name}'),
  };

  @override
  void initState() {
    super.initState();
    _subscription = widget.engine.tracks.listen(
      (tracks) => setState(() => _tracks = tracks),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_scope.hasFocus) {
        ReadingOrderTraversalPolicy().findFirstFocus(_scope)?.requestFocus();
      }
    });
  }

  void _openPanel(MediaTrackType type) {
    setState(() => _panel = type);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _panelFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    _scope.dispose();
    _panelFocus.dispose();
    for (final node in _entries.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Back closes the side panel, then the options.
  void back() {
    final panel = _panel;
    if (panel == null) {
      widget.onClose();
      return;
    }
    setState(() => _panel = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entries[panel]?.requestFocus();
    });
  }

  Future<void> _choose(MediaTrackType type, String? id) async {
    await widget.engine.selectTrack(type, id);
    back();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    // Up from the bar returns to the player; left from the panel closes it.
    if ((_panel == null && key == LogicalKeyboardKey.arrowUp) ||
        (_panel != null && key == LogicalKeyboardKey.arrowLeft)) {
      back();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String valueOf(MediaTrackType type) {
      final track = _tracks.selectedTrack(type);
      if (track == null) return l10n.playerTrackOff;
      return trackLabel(l10n, track, _tracks.of(type).indexOf(track));
    }

    final options = [
      if (_tracks.audio.isNotEmpty)
        (
          MediaTrackType.audio,
          Icons.volume_up_outlined,
          l10n.playerOptionAudio,
        ),
      (
        MediaTrackType.subtitle,
        Icons.closed_caption_outlined,
        l10n.playerOptionSubtitles,
      ),
      if (_tracks.video.isNotEmpty)
        (MediaTrackType.video, Icons.videocam_outlined, l10n.playerOptionVideo),
    ];
    final panel = _panel;

    return FocusScope(
      node: _scope,
      onKeyEvent: _onKey,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xE6000000)],
                ),
              ),
              child: Row(
                children: [
                  for (final (index, (type, icon, label)) in options.indexed)
                    _OptionEntry(
                      focusNode: _entries[type]!,
                      autofocus: index == 0,
                      icon: icon,
                      label: label,
                      value: valueOf(type),
                      onSelect: () => _openPanel(type),
                    ),
                ],
              ),
            ),
          ),
          if (panel != null)
            Positioned(
              top: 24,
              right: 24,
              bottom: 24,
              width: 360,
              child: _TrackPanel(
                type: panel,
                tracks: _tracks,
                focusNode: _panelFocus,
                onChoose: (id) => _choose(panel, id),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionEntry extends StatelessWidget {
  const _OptionEntry({
    required this.focusNode,
    required this.autofocus,
    required this.icon,
    required this.label,
    required this.value,
    required this.onSelect,
  });

  final FocusNode focusNode;
  final bool autofocus;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: TvFocusable(
        focusNode: focusNode,
        autofocus: autofocus,
        onSelect: onSelect,
        builder: (context, focused) => SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: focused ? AppColors.textPrimary : null,
                ),
                child: Icon(
                  icon,
                  color: focused ? AppColors.background : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: textTheme.bodySmall),
              MarqueeText(value, active: focused, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tracks of one type to choose from, the selected one marked.
class _TrackPanel extends StatelessWidget {
  const _TrackPanel({
    required this.type,
    required this.tracks,
    required this.focusNode,
    required this.onChoose,
  });

  final MediaTrackType type;
  final MediaTracks tracks;

  /// Given to the selected entry, or the first one without selection.
  final FocusNode focusNode;
  final ValueChanged<String?> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final list = tracks.of(type);
    final selected = tracks.selected(type);
    final entries = [
      // Video always shows a track; audio and subtitles can be off.
      if (type != MediaTrackType.video) (null, l10n.playerTrackOff),
      for (final (index, track) in list.indexed)
        (track.id, trackLabel(l10n, track, index)),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(switch (type) {
              MediaTrackType.audio => l10n.playerAudioTracks,
              MediaTrackType.subtitle => l10n.playerSubtitleTracks,
              MediaTrackType.video => l10n.playerVideoTracks,
            }, style: textTheme.titleLarge),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final (index, (id, label)) in entries.indexed)
                  TvFocusable(
                    focusNode:
                        id == selected ||
                            (index == 0 &&
                                !entries.any((e) => e.$1 == selected))
                        ? focusNode
                        : null,
                    onSelect: () => onChoose(id),
                    builder: (context, focused) => Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: focused ? AppColors.focusFill : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: focused
                              ? AppColors.focusBorder
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            id == selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: id == selected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MarqueeText(
                              label,
                              active: focused,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
