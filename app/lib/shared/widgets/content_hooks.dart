import 'package:flutter/widgets.dart';

/// Lets the content of the home screen handle navigation events of the side
/// menu around it before the default behaviour.
///
/// - [back]: the back key, for example to open a panel instead of focusing
///   the menu. The back key arrives as a route pop, which every `PopScope`
///   of the route receives, so nested `PopScope`s cannot decide this among
///   themselves.
/// - [enter]: focus moves from the menu into the content, for example to
///   start in a category list instead of the last focused element.
///
/// Handlers return true when they handled the event.
class ContentHooksController {
  bool Function()? _back;
  bool Function()? _enter;

  void register({bool Function()? back, bool Function()? enter}) {
    _back = back;
    _enter = enter;
  }

  void unregister({bool Function()? back, bool Function()? enter}) {
    // Method tear-offs are equal, not identical, between two accesses.
    if (_back == back) _back = null;
    if (_enter == enter) _enter = null;
  }

  bool back() => _back?.call() ?? false;

  bool enter() => _enter?.call() ?? false;
}

class ContentHooks extends InheritedWidget {
  const ContentHooks({
    super.key,
    required this.controller,
    required super.child,
  });

  final ContentHooksController controller;

  static ContentHooksController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ContentHooks>()?.controller;

  @override
  bool updateShouldNotify(ContentHooks oldWidget) =>
      controller != oldWidget.controller;
}
