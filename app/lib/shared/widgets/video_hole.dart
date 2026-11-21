import 'package:flutter/widgets.dart';

/// Where the native video layer below the transparent Flutter view shows
/// through, in logical pixels of the window; null when no video does.
/// Set by the playback surface of the engine that draws into that layer.
final videoHole = ValueNotifier<RRect?>(null);

/// Paints [color] behind [child] everywhere except the [videoHole], so a
/// video layer below the Flutter view stays visible there. Rounded hole
/// corners are painted over, which rounds the rectangular video layer.
class VideoHoleBackground extends StatefulWidget {
  const VideoHoleBackground({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  State<VideoHoleBackground> createState() => _VideoHoleBackgroundState();
}

class _VideoHoleBackgroundState extends State<VideoHoleBackground> {
  Offset _origin() {
    final box = context.findRenderObject() as RenderBox?;
    return box == null || !box.hasSize
        ? Offset.zero
        : box.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _HolePainter(widget.color, _origin),
    child: widget.child,
  );
}

class _HolePainter extends CustomPainter {
  _HolePainter(this.color, this.origin) : super(repaint: videoHole);

  final Color color;
  final Offset Function() origin;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRect(Offset.zero & size);
    final hole = videoHole.value;
    if (hole != null) {
      path
        ..addRRect(hole.shift(-origin()))
        ..fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.color != color;
}
