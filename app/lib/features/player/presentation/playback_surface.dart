import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../data/better_player_playback_engine.dart';
import '../data/fallback_playback_engine.dart';
import '../data/media_kit_playback_engine.dart';
import '../domain/playback_engine.dart';

/// Renders the video of [engine]. Controls are drawn by the screens, so the
/// engine's own controls are disabled.
class PlaybackSurface extends StatelessWidget {
  const PlaybackSurface({super.key, required this.engine});

  final PlaybackEngine engine;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: switch (engine) {
        // Shows whichever engine of the chain plays right now.
        final FallbackPlaybackEngine chain => ValueListenableBuilder(
          valueListenable: chain.active,
          builder: (context, active, _) => active == null
              ? const SizedBox.expand()
              : PlaybackSurface(engine: active),
        ),
        final MediaKitPlaybackEngine mediaKit => Video(
          controller: mediaKit.controller,
          controls: _noControls,
        ),
        final BetterPlayerPlaybackEngine betterPlayer => BetterPlayer(
          controller: betterPlayer.controller,
        ),
        // Test doubles and engines without a video surface.
        _ => const SizedBox.expand(),
      },
    );
  }
}

Widget _noControls(VideoState state) => const SizedBox.shrink();
