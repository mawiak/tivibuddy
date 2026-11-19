import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../data/fallback_playback_engine.dart';
import '../data/media3_playback_engine.dart';
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
        final Media3PlaybackEngine media3 => _Media3Surface(engine: media3),
        // Test doubles and engines without a video surface.
        _ => const SizedBox.expand(),
      },
    );
  }
}

Widget _noControls(VideoState state) => const SizedBox.shrink();

class _Media3Surface extends StatelessWidget {
  const _Media3Surface({required this.engine});

  final Media3PlaybackEngine engine;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([engine.textureId, engine.aspectRatio]),
          builder: (context, _) {
            final texture = engine.textureId.value;
            final ratio = engine.aspectRatio.value;
            if (texture == null || ratio == null) return const SizedBox();
            return Center(
              child: AspectRatio(
                aspectRatio: ratio,
                child: Texture(textureId: texture),
              ),
            );
          },
        ),
        // Media3 hands subtitles over as text; mpv draws its own.
        Positioned(
          left: 48,
          right: 48,
          bottom: 40,
          child: ValueListenableBuilder(
            valueListenable: engine.subtitle,
            builder: (context, text, _) => text == null
                ? const SizedBox.shrink()
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(blurRadius: 4),
                        Shadow(blurRadius: 8),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
