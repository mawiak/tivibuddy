import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Focus scope that remembers its last focused element, so moving into it
/// with [enter] restores that element instead of the geometrically closest
/// one, as users of TV interfaces expect.
///
/// Elements inside request `autofocus` when they are built, for example the
/// first row of a new list. [allowAutofocus] prevents that from taking focus
/// away from a neighbouring area the user is currently navigating in. The
/// suppressed element is kept as the entry point for the next [enter], so
/// screens decide with `autofocus` where focus lands. Nested memory scopes
/// also respect the [allowAutofocus] of the scopes around them.
class FocusMemoryScopeNode extends FocusScopeNode {
  FocusMemoryScopeNode({super.debugLabel, this.allowAutofocus});

  bool Function()? allowAutofocus;
  FocusNode? _deferredAutofocus;

  @override
  void autofocus(FocusNode node) {
    // Enclosing memory scopes guard their whole area, so nested scopes
    // respect their rules, too. Each refusing scope keeps the element as its
    // entry point.
    var allowed = true;
    for (final scope in [
      this,
      ...ancestors.whereType<FocusMemoryScopeNode>(),
    ]) {
      if (!(scope.allowAutofocus?.call() ?? true)) {
        scope._deferredAutofocus = node;
        allowed = false;
      }
    }
    if (allowed) super.autofocus(node);
  }

  /// Focuses the last focused element, else the element that asked for
  /// autofocus, else the first one in reading order.
  void enter() {
    final deferred = _deferredAutofocus;
    _deferredAutofocus = null;
    for (final node in [focusedChild, deferred]) {
      if (node != null && node.canRequestFocus && node.context != null) {
        node.requestFocus();
        return;
      }
    }
    // Without anything focusable inside, focus stays where it is.
    if (traversalDescendants.isEmpty) return;
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

/// Lets left leave a focus scope. Directional traversal never crosses scope
/// boundaries, so without this a list in its own scope would trap focus.
///
/// Tries normal traversal first. When nothing is to the left inside the
/// scope, calls [onLeftEdge], or lets an enclosing [LeaveLeft] handle the
/// key when [onLeftEdge] is null.
class LeaveLeft extends StatelessWidget {
  const LeaveLeft({super.key, required this.child, this.onLeftEdge});

  final Widget child;
  final VoidCallback? onLeftEdge;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent ||
            event.logicalKey != LogicalKeyboardKey.arrowLeft) {
          return KeyEventResult.ignored;
        }
        final focused = FocusManager.instance.primaryFocus;
        if (focused != null &&
            focused.focusInDirection(TraversalDirection.left)) {
          return KeyEventResult.handled;
        }
        final onLeftEdge = this.onLeftEdge;
        if (onLeftEdge == null) return KeyEventResult.ignored;
        onLeftEdge();
        return KeyEventResult.handled;
      },
      child: child,
    );
  }
}
