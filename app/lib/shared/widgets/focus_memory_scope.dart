import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Focus scope that remembers its last focused element, so moving into it
/// with [enter] restores that element instead of the geometrically closest
/// one, as users of TV interfaces expect.
///
/// Elements inside request `autofocus` when they are built, for example the
/// first row of a new list. [allowAutofocus] prevents that from taking focus
/// away from a neighbouring area the user is currently navigating in.
class FocusMemoryScopeNode extends FocusScopeNode {
  FocusMemoryScopeNode({super.debugLabel, this.allowAutofocus});

  bool Function()? allowAutofocus;

  @override
  void autofocus(FocusNode node) {
    if (allowAutofocus?.call() ?? true) super.autofocus(node);
  }

  /// Focuses the last focused element, or the first one in reading order.
  void enter() {
    final last = focusedChild;
    if (last != null && last.canRequestFocus && last.context != null) {
      last.requestFocus();
      return;
    }
    ReadingOrderTraversalPolicy().findFirstFocus(this)?.requestFocus();
  }
}

/// Calls [onRight] when right is pressed inside [child] and stops the event,
/// so the caller decides where focus goes next.
class ExitRight extends StatelessWidget {
  const ExitRight({super.key, required this.onRight, required this.child});

  final VoidCallback onRight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          onRight();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
