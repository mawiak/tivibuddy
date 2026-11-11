import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/home/presentation/home_shell.dart';
import 'package:tivibuddy/features/home/presentation/side_menu.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/profiles/presentation/profile_avatar_view.dart';
import 'package:tivibuddy/features/profiles/presentation/profile_edit_screen.dart';
import 'package:tivibuddy/features/profiles/presentation/profile_picker_screen.dart';
import 'package:tivibuddy/shared/widgets/tv_text_field.dart';

import '../../helpers/test_app.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }
  await settle(tester);
}

void main() {
  testWidgets('first start creates a profile and opens home', (tester) async {
    await pumpFullApp(tester);

    expect(find.byType(ProfileEditScreen), findsOneWidget);
    expect(find.text('Welcome to TiviBuddy'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.byType(TvTextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Anna');
    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.text('Anna'), findsNothing, reason: 'menu is collapsed');
  });

  testWidgets('saving without a name shows an error', (tester) async {
    await pumpFullApp(tester);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Please enter a name.'), findsOneWidget);
    expect(find.byType(ProfileEditScreen), findsOneWidget);
  });

  testWidgets('existing profiles show the picker, pin is required', (
    tester,
  ) async {
    final db = createTestDatabase();
    final repository = DriftProfileRepository(db);
    await tester.runAsync(() async {
      await repository.create(name: 'Anna', avatar: const PresetAvatar(0));
      await repository.create(
        name: 'Ben',
        avatar: const PresetAvatar(1),
        pin: '1234',
      );
    });

    await pumpFullApp(tester, database: db);

    expect(find.byType(ProfilePickerScreen), findsOneWidget);
    expect(find.text('Who is watching?'), findsOneWidget);

    await tester.tap(find.text('Ben'));
    await settle(tester);
    expect(find.text('Enter PIN for Ben'), findsOneWidget);

    await enterPin(tester, '9999');
    expect(find.text('Wrong PIN. Please try again.'), findsOneWidget);

    await enterPin(tester, '1234');
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('back from the picker returns to the active profile', (
    tester,
  ) async {
    final db = createTestDatabase();
    await tester.runAsync(
      () =>
          DriftProfileRepository(db)
              .create(name: 'Anna', avatar: const PresetAvatar(0)),
    );
    await pumpFullApp(tester, database: db);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);
    expect(find.byType(HomeShell), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SideMenu),
        matching: find.byType(ProfileAvatarView),
      ),
    );
    await settle(tester);
    expect(find.byType(ProfilePickerScreen), findsOneWidget);

    await pressBack(tester);
    await settle(tester);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('manage mode edits and deletes a profile', (tester) async {
    final db = createTestDatabase();
    await tester.runAsync(() async {
      final repository = DriftProfileRepository(db);
      await repository.create(name: 'Anna', avatar: const PresetAvatar(0));
      await repository.create(name: 'Ben', avatar: const PresetAvatar(1));
    });
    await pumpFullApp(tester, database: db);

    await tester.tap(find.text('Manage profiles'));
    await tester.pump();
    await tester.tap(find.text('Ben'));
    await settle(tester);
    expect(find.text('Edit profile'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await settle(tester);
    expect(find.text('Delete profile?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await settle(tester);

    expect(find.byType(ProfilePickerScreen), findsOneWidget);
    expect(find.text('Ben'), findsNothing);
    expect(find.text('Anna'), findsOneWidget);
  });
}
