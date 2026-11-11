import 'package:flutter/widgets.dart';

/// Single-line text that scrolls horizontally while [active] is true and the
/// text does not fit. Otherwise it is shown with an ellipsis, so inactive
/// rows in long lists cost nothing beyond a plain [Text].
class MarqueeText extends StatefulWidget {
  const MarqueeText(
    this.text, {
    super.key,
    required this.active,
    this.style,
    this.velocity = 40,
    this.gap = 48,
    this.pause = const Duration(seconds: 1),
  });

  final String text;
  final bool active;
  final TextStyle? style;

  /// Scroll speed in logical pixels per second.
  final double velocity;

  /// Space between the end of the text and its repetition.
  final double gap;

  /// Time the text rests at its start position before every pass.
  final Duration pause;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  /// Scroll distance of one pass, or null when the text must not scroll.
  double? _distance;
  bool _syncScheduled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _travel => Duration(
    milliseconds: ((_distance ?? 0) / widget.velocity * 1000).round(),
  );

  /// The decision whether to scroll is made during layout, but starting or
  /// stopping the controller notifies listeners and must not happen there.
  void _requestScroll(double? distance) {
    final changed = distance != _distance;
    _distance = distance;
    if (!changed || _syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      _controller
        ..stop()
        ..reset();
      if (_distance != null) {
        _controller.repeat(period: widget.pause + _travel);
      }
    });
  }

  double _offsetFor(double t) {
    final distance = _distance;
    if (distance == null) return 0;
    final cycle = widget.pause + _travel;
    final pauseFraction = widget.pause.inMicroseconds / cycle.inMicroseconds;
    if (t <= pauseFraction) return 0;
    return (t - pauseFraction) / (1 - pauseFraction) * distance;
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final textWidth = painter.width;
        final textHeight = painter.height;
        painter.dispose();

        final overflows = textWidth > constraints.maxWidth;
        if (!overflows || !widget.active || animationsDisabled) {
          _requestScroll(null);
          return Text(
            widget.text,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          );
        }

        _requestScroll(textWidth + widget.gap);
        return ClipRect(
          child: SizedBox(
            width: constraints.maxWidth,
            height: textHeight,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(-_offsetFor(_controller.value), 0),
                child: child,
              ),
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                maxWidth: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.text, style: style, maxLines: 1),
                    SizedBox(width: widget.gap),
                    Text(widget.text, style: style, maxLines: 1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
