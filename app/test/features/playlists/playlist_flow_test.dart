import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/home/application/home_section.dart';
import 'package:tivibuddy/features/playlists/data/playlist_data_providers.dart';
import 'package:tivibuddy/features/playlists/domain/connection_test.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/playlists/presentation/playlist_edit_screen.dart';
import 'package:tivibuddy/features/playlists/presentation/playlists_screen.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';
import 'package:tivibuddy/shared/widgets/tv_text_field.dart';

import '../../helpers/test_app.dart';

class _FakeTester implements ConnectionTester {
  ConnectionResult result = ConnectionOk(
    AccountInfo(
      status: 'Active',
      checkedAt: DateTime.utc(2026, 11, 11),
      maxConnections: 2,
      activeConnections: 0,
    ),
  );
  int calls = 0;

  @override
  Future<ConnectionResult> test({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    calls++;
    return result;
  }
}

Future<void> _type(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TvTextField, label);
  await tester.tap(field);
  await tester.pump();
  await tester.enterText(
    find.descendant(of: field, matching: find.byType(TextField)),
    text,
  );
  await tester.pump();
}

void main() {
  late _FakeTester connection;

  Future<void> openPlaylists(WidgetTester tester) async {
    final db = createTestDatabase();
    await tester.runAsync(() async {
      final anna = await DriftProfileRepository(db)
          .create(name: 'Anna', avatar: const PresetAvatar(0));
      await DriftDeviceSettingsRepository(db).setDefaultProfileId(anna.id);
    });
    final container = await pumpFullApp(
      tester,
      database: db,
      overrides: [
        connectionTesterProvider(PlaylistType.xtream)
            .overrideWithValue(connection),
      ],
    );
    container
        .read(selectedHomeSectionProvider.notifier)
        .select(HomeSection.settings);
    await settle(tester);
    await tester.tap(find.text('Playlists'));
    await settle(tester);
    expect(find.byType(PlaylistsScreen), findsOneWidget);
  }

  setUp(() => connection = _FakeTester());

  testWidgets('adds a playlist from a pasted link', (tester) async {
    await openPlaylists(tester);
    expect(find.text('No playlist yet'), findsNothing);
    expect(
      find.textContaining('Add your Xtream Codes account'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add playlist'));
    await settle(tester);
    await _type(
      tester,
      'Server URL',
      'http://line.example.com:8080/get.php?username=anna&password=pw&type=m3u',
    );
    expect(find.textContaining('were taken from the link'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(connection.calls, 1);
    expect(find.byType(PlaylistEditScreen), findsNothing);
    expect(find.text('line.example.com'), findsOneWidget);
    expect(find.textContaining('Status: Active'), findsOneWidget);
  });

  testWidgets('shows validation errors', (tester) async {
    await openPlaylists(tester);
    await tester.tap(find.text('Add playlist'));
    await settle(tester);

    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(find.text('Please enter a valid http or https address.'), findsOne);
    expect(find.text('Please enter the username.'), findsOneWidget);
    expect(find.text('Please enter the password.'), findsOneWidget);
    expect(connection.calls, 0);
  });

  testWidgets('failed connection asks before saving', (tester) async {
    connection.result = const ConnectionUnauthorized();
    await openPlaylists(tester);
    await tester.tap(find.text('Add playlist'));
    await settle(tester);
    await _type(tester, 'Server URL', 'example.com');
    await _type(tester, 'Username', 'anna');
    await _type(tester, 'Password', 'wrong');

    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(find.text('Save without working connection?'), findsOneWidget);
    expect(find.textContaining('rejected the username'), findsWidgets);

    await tester.tap(find.text('Save anyway'));
    await settle(tester);

    expect(find.byType(PlaylistsScreen), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    expect(find.textContaining('Not checked yet'), findsOneWidget);
  });
}
