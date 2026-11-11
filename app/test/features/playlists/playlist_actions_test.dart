import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/playlists/application/playlist_actions.dart';
import 'package:tivibuddy/features/playlists/data/playlist_data_providers.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/application/profile_actions.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/test_app.dart';

const _input = PlaylistInput(
  name: ' My TV ',
  serverUrl: 'example.com:8080/',
  username: ' anna ',
  password: 'secret',
);

void main() {
  late AppDatabase db;
  late FakeCredentialStore credentials;
  late ProviderContainer container;
  late PlaylistActions actions;
  late String profileId;

  setUp(() async {
    db = createTestDatabase();
    credentials = FakeCredentialStore();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        credentialStoreProvider.overrideWithValue(credentials),
      ],
    );
    actions = container.read(playlistActionsProvider);
    profileId =
        (await container
                .read(profileActionsProvider)
                .save(
                  name: 'Anna',
                  avatar: const PresetAvatar(0),
                  pinChange: const PinUnchanged(),
                  startAutomatically: false,
                ))
            .id;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'stores normalized values and keeps the password out of the database',
    () async {
      final playlist = await actions.save(profileId: profileId, input: _input);

      expect(playlist.name, 'My TV');
      expect(playlist.serverUrl, 'http://example.com:8080');
      expect(playlist.username, 'anna');
      expect(credentials.passwords[playlist.id], 'secret');

      final row = await db.select(db.playlists).getSingle();
      expect(row.toJson().values, isNot(contains('secret')));
    },
  );

  test('form round trip includes password and account', () async {
    final account = AccountInfo(
      status: 'Active',
      checkedAt: DateTime.utc(2026, 11, 11),
      maxConnections: 1,
    );
    final playlist = await actions.save(
      profileId: profileId,
      input: _input,
      account: account,
    );

    final form = await actions.loadForm(playlist.id);

    expect(form.password, 'secret');
    expect(form.account?.status, 'Active');
    expect(form.account?.maxConnections, 1);
    expect(form.account?.expiresAt, isNull);
  });

  test('update changes values and password', () async {
    final playlist = await actions.save(profileId: profileId, input: _input);

    await actions.save(
      id: playlist.id,
      profileId: profileId,
      input: const PlaylistInput(
        name: 'Renamed',
        serverUrl: 'https://other.example.com',
        username: 'ben',
        password: 'new',
      ),
    );

    final form = await actions.loadForm(playlist.id);
    expect(form.name, 'Renamed');
    expect(form.serverUrl, 'https://other.example.com');
    expect(form.password, 'new');
  });

  test('delete removes playlist and password', () async {
    final playlist = await actions.save(profileId: profileId, input: _input);

    await actions.delete(playlist.id);

    expect(await actions.loadForm(null), isA<PlaylistFormData>());
    expect(
      await container.read(playlistRepositoryProvider).findById(playlist.id),
      isNull,
    );
    expect(credentials.passwords, isEmpty);
  });

  test('deleting a profile deletes its playlists and passwords', () async {
    await actions.save(profileId: profileId, input: _input);
    await actions.save(profileId: profileId, input: _input);

    await container.read(profileActionsProvider).delete(profileId);

    expect(
      await container.read(playlistRepositoryProvider).getForProfile(profileId),
      isEmpty,
    );
    expect(credentials.passwords, isEmpty);
  });

  test('playlists are scoped to their profile', () async {
    final other = await container
        .read(profileActionsProvider)
        .save(
          name: 'Ben',
          avatar: const PresetAvatar(1),
          pinChange: const PinUnchanged(),
          startAutomatically: false,
        );
    await actions.save(profileId: profileId, input: _input);

    final repository = container.read(playlistRepositoryProvider);
    expect(await repository.getForProfile(profileId), hasLength(1));
    expect(await repository.getForProfile(other.id), isEmpty);
  });
}
