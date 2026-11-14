import 'dart:async';

import 'package:flutter/widgets.dart';

/// Shows [child] only when [busy] lasts longer than [delay], so short
/// buffering, for example when switching tracks, does not flash a spinner.
class DelayedBusy extends StatefulWidget {
  const DelayedBusy({
    super.key,
    required this.busy,
    required this.child,
    this.delay = const Duration(milliseconds: 800),
  });

  final bool busy;
  final Widget child;
  final Duration delay;

  @override
  State<DelayedBusy> createState() => _DelayedBusyState();
}

class _DelayedBusyState extends State<DelayedBusy> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  void didUpdateWidget(DelayedBusy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busy != widget.busy) _update();
  }

  void _update() {
    _timer?.cancel();
    if (!widget.busy) {
      _visible = false;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _visible ? widget.child : const SizedBox.shrink();
}
