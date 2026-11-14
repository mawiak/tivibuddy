import 'package:flutter/widgets.dart';

/// Shows [panel] at the left edge and pushes [child] to the right by its
/// width instead of narrowing it, so a grid keeps the size of its tiles and
/// runs out of the screen on the right, like common IPTV players.
class PushAside extends StatelessWidget {
  const PushAside({
    super.key,
    required this.open,
    required this.panelWidth,
    required this.panel,
    required this.child,
  });

  final bool open;
  final double panelWidth;
  final Widget panel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: open ? panelWidth : 0,
              top: 0,
              bottom: 0,
              width: constraints.maxWidth,
              child: child,
            ),
            if (open)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: panelWidth,
                child: panel,
              ),
          ],
        ),
      ),
    );
  }
}
