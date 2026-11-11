import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/app.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/core/input/tv_shortcuts.dart';
import 'package:tivibuddy/core/theme/app_theme.dart';
import 'package:tivibuddy/features/playlists/data/playlist_data_providers.dart';
import 'package:tivibuddy/l10n/app_localizations.dart';

import 'fake_credential_store.dart';

/// Logical screen size of a 1080p Fire TV.
const tvSize = Size(960, 540);
const phoneSize = Size(390, 844);

AppDatabase createTestDatabase() {
  // Stream queries are torn down asynchronously; tests must not complain
  // about multiple database instances across test cases.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}

ProviderContainer _createContainer(
  AppDatabase? database,
  List<Override> overrides, [
  FakeCredentialStore? credentials,
]) {
  final db = database ?? createTestDatabase();
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      // Platform secure storage is not available in tests.
      credentialStoreProvider.overrideWithValue(
        credentials ?? FakeCredentialStore(),
      ),
      ...overrides,
    ],
  );
  addTearDown(() async {
    container.dispose();
    await db.close();
  });
  return container;
}

void _setSize(WidgetTester tester, Size size) {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps a single widget inside a minimal app with an in-memory database.
Future<ProviderContainer> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Size size = tvSize,
  AppDatabase? database,
  List<Override> overrides = const [],
}) async {
  _setSize(tester, size);
  final container = _createContainer(database, overrides);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
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
  return container;
}

/// Pumps the complete app including router and startup logic.
Future<ProviderContainer> pumpFullApp(
  WidgetTester tester, {
  Size size = tvSize,
  AppDatabase? database,
  List<Override> overrides = const [],
  FakeCredentialStore? credentials,
}) async {
  _setSize(tester, size);
  final container = _createContainer(database, overrides, credentials);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TiviBuddyApp(),
    ),
  );
  await settle(tester);
  return container;
}

/// Lets database futures and streams complete and animations run.
///
/// [WidgetTester.pumpAndSettle] cannot be used: it does not advance real
/// asynchronous database work, and focused marquee texts animate forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The remote back key reaches Flutter as a system pop route request, not as
/// a key event.
Future<void> pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump();
}

String? focusedLabel() => FocusManager.instance.primaryFocus?.debugLabel;
