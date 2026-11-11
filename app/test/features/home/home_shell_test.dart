import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/home/presentation/home_shell.dart';
import 'package:tivibuddy/features/home/presentation/section_placeholder.dart';
import 'package:tivibuddy/features/home/presentation/side_menu.dart';
import 'package:tivibuddy/shared/widgets/tv_list_tile.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('TV layout shows the side menu and focuses the content', (
    tester,
  ) async {
    await pumpTestApp(tester, const HomeShell());

    expect(find.byType(SideMenu), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(focusedLabel(), isNot(startsWith('menu.')));
  });

  testWidgets('phone layout shows a bottom navigation bar', (tester) async {
    await pumpTestApp(tester, const HomeShell(), size: phoneSize);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(SideMenu), findsNothing);
  });

  testWidgets('back from content focuses the selected menu item', (
    tester,
  ) async {
    await pumpTestApp(tester, const HomeShell());

    await pressBack(tester);

    expect(focusedLabel(), 'menu.liveTv');
  });

  testWidgets('selecting a menu item switches the section', (tester) async {
    await pumpTestApp(tester, const HomeShell());
    await pressBack(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<SectionPlaceholder>(),
      isNotNull,
      reason: 'select moves into the section',
    );
    expect(find.widgetWithText(Column, 'Search'), findsWidgets);
  });

  testWidgets('right from the menu restores the last focused content', (
    tester,
  ) async {
    await pumpTestApp(tester, const HomeShell());
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final contentFocus = focusedLabel();

    await pressBack(tester);
    expect(focusedLabel(), 'menu.liveTv');
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(focusedLabel(), contentFocus);
  });

  testWidgets('select on a menu entry focuses the first item of its section', (
    tester,
  ) async {
    await pumpTestApp(tester, const HomeShell());
    await pressBack(tester);
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    }
    // Select on a menu entry moves into the section, like right.
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);

    final focused = FocusManager.instance.primaryFocus!.context!.widget;
    expect(
      find.descendant(
        of: find.widgetWithText(TvListTile, 'Playlists'),
        matching: find.byWidget(focused),
      ),
      findsOneWidget,
    );
  });

  testWidgets('left from the content reaches the menu', (tester) async {
    await pumpTestApp(tester, const HomeShell());
    expect(focusedLabel(), isNot(startsWith('menu.')));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();

    expect(focusedLabel(), 'menu.liveTv');
  });
}
