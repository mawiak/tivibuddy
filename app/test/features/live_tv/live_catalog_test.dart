import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/live_tv/application/live_catalog_controller.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';
import 'package:tivibuddy/features/playlists/application/playlist_actions.dart';
import 'package:tivibuddy/features/playlists/data/playlist_data_providers.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/application/profile_actions.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/live_tv_fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FakeLiveCatalogSource source;
  late LiveTvRepository repository;
  late String playlistId;

  setUp(() async {
    db = createTestDatabase();
    source = FakeLiveCatalogSource();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        credentialStoreProvider.overrideWithValue(FakeCredentialStore()),
        liveCatalogSourceProvider(PlaylistType.xtream)
            .overrideWithValue(source),
      ],
    );
    repository = container.read(liveTvRepositoryProvider);
    final profile = await container
        .read(profileActionsProvider)
        .save(
          name: 'Anna',
          avatar: const PresetAvatar(0),
          pinChange: const PinUnchanged(),
          startAutomatically: false,
        );
    playlistId =
        (await container
                .read(playlistActionsProvider)
                .save(
                  profileId: profile.id,
                  input: const PlaylistInput(
                    name: 'TV',
                    serverUrl: 'example.com',
                    username: 'anna',
                    password: 'pw',
                  ),
                ))
            .id;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  LiveCatalogController controller() =>
      container.read(liveCatalogControllerProvider(playlistId).notifier);

  List<LiveChannel> channels(int count, {String? category}) => [
    for (var i = 1; i <= count; i++)
      testChannel(playlistId, i, categoryId: category ?? '${i % 2}'),
  ];

  test('refresh loads categories and channels in order', () async {
    source
      ..categories = const [
        LiveCategory(id: '1', name: 'Odd', channelCount: 0),
        LiveCategory(id: '0', name: 'Even', channelCount: 0),
        LiveCategory(id: '9', name: 'Empty', channelCount: 0),
      ]
      ..channels = channels(120).reversed.toList();

    await controller().refresh();

    expect(
      container.read(liveCatalogControllerProvider(playlistId)),
      isA<LiveCatalogIdle>(),
    );
    final categories = await repository.watchCategories(playlistId).first;
    expect(categories.map((c) => (c.name, c.channelCount)), [
      ('Odd', 60),
      ('Even', 60),
    ]);
    final page = await repository.getChannels(
      playlistId,
      categoryId: '0',
      offset: 10,
      limit: 5,
    );
    expect(page.map((c) => c.number), [22, 24, 26, 28, 30]);
    expect(await repository.getLoadedAt(playlistId), isNotNull);
  });

  test('a new load removes channels the provider no longer has', () async {
    source.channels = channels(100);
    await controller().refresh();
    source.channels = channels(40);
    await controller().refresh();

    expect(await repository.watchChannelCount(playlistId).first, 40);
  });

  test('failures are reported and keep the previous catalog', () async {
    source.channels = channels(10);
    await controller().refresh();
    source.failure = CatalogLoadFailure.unauthorized;

    await controller().refresh();

    expect(
      container.read(liveCatalogControllerProvider(playlistId)),
      isA<LiveCatalogFailed>().having(
        (s) => s.reason,
        'reason',
        CatalogLoadFailure.unauthorized,
      ),
    );
    expect(await repository.watchChannelCount(playlistId).first, 10);
  });

  test('ensureFresh loads only missing or outdated catalogs', () async {
    source.channels = channels(10);

    await controller().ensureFresh();
    await controller().ensureFresh();

    expect(source.channelLoads, 1);
  });

  test('deleting the playlist deletes its catalog', () async {
    source.channels = channels(10);
    await controller().refresh();

    await container.read(playlistActionsProvider).delete(playlistId);

    expect(await repository.watchChannelCount(playlistId).first, 0);
    expect(await repository.getLoadedAt(playlistId), isNull);
  });
}
