import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
        final MediaKitPlaybackEngine mediaKit => Video(
          controller: mediaKit.controller,
          controls: _noControls,
        ),
        // Test doubles and engines without a video surface.
        _ => const SizedBox.expand(),
      },
    );
  }
}

Widget _noControls(VideoState state) => const SizedBox.shrink();
