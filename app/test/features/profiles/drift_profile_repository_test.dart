import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';

void main() {
  late AppDatabase db;
  late DriftProfileRepository repository;
  var now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftProfileRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  test('creates profiles in display order with trimmed names', () async {
    await repository.create(name: '  Anna ', avatar: const PresetAvatar(3));
    await repository.create(name: 'Ben', avatar: const PresetAvatar(1));

    final profiles = await repository.getAll();

    expect(profiles.map((p) => p.name), ['Anna', 'Ben']);
    expect(profiles.map((p) => p.sortOrder), [0, 1]);
    expect(profiles.first.avatar, const PresetAvatar(3));
    expect(profiles.first.hasPin, isFalse);
  });

  test('rejects invalid names and pins', () async {
    expect(
      () => repository.create(name: '   ', avatar: const PresetAvatar(0)),
      throwsArgumentError,
    );
    expect(
      () => repository.create(
        name: 'Anna',
        avatar: const PresetAvatar(0),
        pin: '12a4',
      ),
      throwsArgumentError,
    );
  });

  test('updates name and avatar and bumps updatedAt', () async {
    final created = await repository.create(
      name: 'Anna',
      avatar: const PresetAvatar(0),
    );
    now = now.add(const Duration(minutes: 5));
    final image = Uint8List.fromList([1, 2, 3]);

    await repository.update(
      created.id,
      name: 'Anne',
      avatar: ImageAvatar(image),
    );

    final updated = (await repository.findById(created.id))!;
    expect(updated.name, 'Anne');
    expect((updated.avatar as ImageAvatar).pngBytes, image);
    final row = await db.select(db.profiles).getSingle();
    expect(row.updatedAt, now);
    expect(row.createdAt, isNot(now));
  });

  test('stores only a hash of the pin and verifies it', () async {
    final created = await repository.create(
      name: 'Anna',
      avatar: const PresetAvatar(0),
      pin: '1234',
    );

    final row = await db.select(db.profiles).getSingle();
    expect(row.pinHash, isNot(contains('1234')));
    expect(created.hasPin, isTrue);
    expect(await repository.verifyPin(created.id, '1234'), isTrue);
    expect(await repository.verifyPin(created.id, '4321'), isFalse);

    await repository.setPin(created.id, null);
    expect((await repository.findById(created.id))!.hasPin, isFalse);
  });

  test('delete is a soft delete hidden from queries', () async {
    final created = await repository.create(
      name: 'Anna',
      avatar: const PresetAvatar(0),
    );

    await repository.delete(created.id);

    expect(await repository.getAll(), isEmpty);
    expect(await repository.findById(created.id), isNull);
    final row = await db.select(db.profiles).getSingle();
    expect(row.deleted, isTrue);
    expect(
      () => repository.update(
        created.id,
        name: 'X',
        avatar: const PresetAvatar(0),
      ),
      throwsStateError,
    );
  });

  test('watchAll emits changes', () async {
    final emissions = repository.watchAll().map(
      (profiles) => profiles.map((p) => p.name).toList(),
    );

    final expectation = expectLater(
      emissions,
      emitsInOrder([
        <String>[],
        ['Anna'],
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    await repository.create(name: 'Anna', avatar: const PresetAvatar(0));

    await expectation;
  });
}
