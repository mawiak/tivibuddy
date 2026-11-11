import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Key bindings for remote controls and game pads on top of the framework
/// defaults. D-pad arrows already map to directional focus traversal.
const Map<ShortcutActivator, Intent> tvShortcuts = {
  SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
};
