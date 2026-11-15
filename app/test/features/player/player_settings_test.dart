import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/player/application/player_settings_providers.dart';
import 'package:tivibuddy/features/player/domain/player_settings.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';

import '../../helpers/test_app.dart';

void main() {
  test('stores, loads and resets the player settings', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    ProviderContainer create() {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      container.listen(playerSettingsControllerProvider, (_, _) {});
      return container;
    }

    final first = create();
    expect(
      first.read(playerSettingsControllerProvider),
      PlayerSettings.defaults,
    );
    final controller = first.read(playerSettingsControllerProvider.notifier);
    await controller.setDecoder(VideoDecoder.hardwareCopy);
    await controller.setPassthrough({
      AudioPassthrough.dts,
      AudioPassthrough.ac3,
    });

    // A new start reads what was stored.
    final second = create();
    await pumpEventQueue();
    expect(
      second.read(playerSettingsControllerProvider),
      const PlayerSettings(
        decoder: VideoDecoder.hardwareCopy,
        passthrough: {AudioPassthrough.ac3, AudioPassthrough.dts},
      ),
    );

    await DriftDeviceSettingsRepository(db).reset();
    await pumpEventQueue();
    expect(
      second.read(playerSettingsControllerProvider),
      PlayerSettings.defaults,
    );
  });
}
