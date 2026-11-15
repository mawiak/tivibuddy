import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'core/logging/app_log.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  installLogCapture();
  MediaKit.ensureInitialized();

  // Channel logos and posters are decoded at display size; this caps the
  // decoded image cache for 1 GB devices (RES-2).
  PaintingBinding.instance.imageCache
    ..maximumSize = 300
    ..maximumSizeBytes = 48 << 20;

  runApp(const ProviderScope(child: TiviBuddyApp()));
}
