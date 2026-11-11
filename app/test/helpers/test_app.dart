import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/input/tv_shortcuts.dart';
import 'package:tivibuddy/core/theme/app_theme.dart';
import 'package:tivibuddy/l10n/app_localizations.dart';

/// Logical screen size of a 1080p Fire TV.
const tvSize = Size(960, 540);
const phoneSize = Size(390, 844);

Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Size size = tvSize,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        shortcuts: {...WidgetsApp.defaultShortcuts, ...tvShortcuts},
        home: Material(child: child),
      ),
    ),
  );
  await tester.pump();
}
