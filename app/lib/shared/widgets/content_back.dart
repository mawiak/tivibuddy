import 'package:flutter/widgets.dart';

/// Lets the content of a screen handle the back key before the screen's own
/// back behaviour, for example to open a panel instead of focusing the menu.
///
/// The back key arrives as a route pop, which every `PopScope` of the route
/// receives, so nested `PopScope`s cannot decide this among themselves.
class ContentBackController {
  bool Function()? _handler;

  /// Registers [handler]; it returns true when it handled the back key.
  void register(bool Function() handler) => _handler = handler;

  void unregister(bool Function() handler) {
    if (identical(_handler, handler)) _handler = null;
  }

  /// Gives the content the back key; true when it handled it.
  bool handle() => _handler?.call() ?? false;
}

class ContentBack extends InheritedWidget {
  const ContentBack({
    super.key,
    required this.controller,
    required super.child,
  });

  final ContentBackController controller;

  static ContentBackController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ContentBack>()?.controller;

  @override
  bool updateShouldNotify(ContentBack oldWidget) =>
      controller != oldWidget.controller;
}
