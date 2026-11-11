import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/home/presentation/home_shell.dart';
import 'package:tivibuddy/features/home/presentation/side_menu.dart';

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
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(focusedLabel(), 'menu.movies');
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.widgetWithText(Column, 'Movies'), findsWidgets);
  });
}
