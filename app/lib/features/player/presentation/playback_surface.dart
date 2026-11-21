import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../data/fallback_playback_engine.dart';
import '../data/media3_playback_engine.dart';
import '../data/media_kit_playback_engine.dart';
import '../domain/playback_engine.dart';

/// Renders the video of [engine]. Controls are drawn by the screens, so the
/// engine's own controls are disabled.
///
/// Media3 draws into its own video layer below the transparent Flutter
/// view: frames show at their exact time and HDR reaches the TV. This
/// widget then stays transparent and the screen's [VideoHoleBackground]
/// leaves its area open; [cornerRadius] rounds it there.
class PlaybackSurface extends StatelessWidget {
  const PlaybackSurface({
    super.key,
    required this.engine,
    this.cornerRadius = 0,
  });

  final PlaybackEngine engine;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) => switch (engine) {
    // Shows whichever engine of the chain plays right now.
    final FallbackPlaybackEngine chain => ValueListenableBuilder(
      valueListenable: chain.active,
      builder: (context, active, _) => active == null
          ? const ColoredBox(color: Colors.black, child: SizedBox.expand())
          : PlaybackSurface(engine: active, cornerRadius: cornerRadius),
    ),
    final MediaKitPlaybackEngine mediaKit => ColoredBox(
      color: Colors.black,
      child: Video(controller: mediaKit.controller, controls: _noControls),
    ),
    final Media3PlaybackEngine media3 => _Media3Surface(
      engine: media3,
      cornerRadius: cornerRadius,
    ),
    // Test doubles and engines without a video surface.
    _ => const ColoredBox(color: Colors.black, child: SizedBox.expand()),
  };
}

Widget _noControls(VideoState state) => const SizedBox.shrink();

class _Media3Surface extends StatefulWidget {
  const _Media3Surface({required this.engine, required this.cornerRadius});

  final Media3PlaybackEngine engine;
  final double cornerRadius;

  @override
  State<_Media3Surface> createState() => _Media3SurfaceState();
}

class _Media3SurfaceState extends State<_Media3Surface> {
  @override
  void initState() {
    super.initState();
    widget.engine.attachOutput(this);
    widget.engine.aspectRatio.addListener(_reportRect);
    _reportAfterFrames();
  }

  @override
  void dispose() {
    widget.engine.aspectRatio.removeListener(_reportRect);
    widget.engine.detachOutput(this);
    super.dispose();
  }

  /// Follows the widget on screen: the check runs after every frame Flutter
  /// draws anyway and only talks to the native side when the rectangle
  /// changed.
  void _reportAfterFrames() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reportRect();
      _reportAfterFrames();
    });
  }

  void _reportRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    final topLeft = box.localToGlobal(Offset.zero);
    final ratio = widget.engine.aspectRatio.value ?? size.aspectRatio;
    // Letterboxed like BoxFit.contain; the native layer has no fitting,
    // the black layer behind it fills the bars.
    final fitted = applyBoxFit(
      BoxFit.contain,
      Size(ratio, 1),
      size,
    ).destination;
    final origin =
        topLeft +
        Offset(
          (size.width - fitted.width) / 2,
          (size.height - fitted.height) / 2,
        );
    final scale = View.of(context).devicePixelRatio;
    widget.engine.updateOutputRect(
      this,
      Rect.fromLTWH(
        origin.dx * scale,
        origin.dy * scale,
        fitted.width * scale,
        fitted.height * scale,
      ),
      RRect.fromRectAndRadius(
        topLeft & size,
        Radius.circular(widget.cornerRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Nothing is drawn here: the video layer below shows through.
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
