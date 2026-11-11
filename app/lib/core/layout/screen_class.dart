import 'package:flutter/widgets.dart';

/// Coarse layout classes. Fire TV reports 960x540 logical pixels at 1080p,
/// so `tv` is detected by landscape orientation and a large enough width,
/// not by physical resolution.
enum ScreenClass {
  phone,
  tablet,
  tv;

  static ScreenClass of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.shortestSide < 500) return ScreenClass.phone;
    if (size.width >= 900 && size.width > size.height) return ScreenClass.tv;
    return ScreenClass.tablet;
  }

  bool get isPhone => this == ScreenClass.phone;
}
