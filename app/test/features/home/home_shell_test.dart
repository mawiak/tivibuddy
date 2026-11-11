import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/home/presentation/home_shell.dart';
import 'package:tivibuddy/features/home/presentation/side_menu.dart';

import '../../helpers/test_app.dart';

/// The remote back key reaches Flutter as a system pop route request, not as
/// a key event.
Future<void> _pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump();
}

String? _focusedLabel() => FocusManager.instance.primaryFocus?.debugLabel;

void main() {
  testWidgets('TV layout shows the side menu and focuses the content', (
    tester,
  ) async {
    await pumpTestApp(tester, const HomeShell());

    expect(find.byType(SideMenu), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(_focusedLabel(), isNot(startsWith('menu.')));
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

    await _pressBack(tester);

    expect(_focusedLabel(), 'menu.liveTv');
  });

  testWidgets('selecting a menu item switches the section', (tester) async {
    await pumpTestApp(tester, const HomeShell());
    await _pressBack(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(_focusedLabel(), 'menu.movies');
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.widgetWithText(Column, 'Movies'), findsWidgets);
  });
}
