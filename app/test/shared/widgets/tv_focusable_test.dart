import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/shared/widgets/tv_focusable.dart';

import '../../helpers/test_app.dart';

Widget _tile({required VoidCallback onSelect}) => TvFocusable(
  autofocus: true,
  onSelect: onSelect,
  builder: (context, focused) =>
      SizedBox(width: 100, height: 40, child: Text(focused ? 'on' : 'off')),
);

void main() {
  testWidgets('reports focus to the builder', (tester) async {
    await pumpTestApp(tester, _tile(onSelect: () {}));

    expect(find.text('on'), findsOneWidget);
  });

  for (final key in [
    LogicalKeyboardKey.select,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.gameButtonA,
  ]) {
    testWidgets('remote key ${key.debugName} selects', (tester) async {
      var selected = 0;
      await pumpTestApp(tester, _tile(onSelect: () => selected++));

      await tester.sendKeyEvent(key);

      expect(selected, 1);
    });
  }

  testWidgets('tap selects', (tester) async {
    var selected = 0;
    await pumpTestApp(tester, _tile(onSelect: () => selected++));

    await tester.tap(find.byType(TvFocusable));

    expect(selected, 1);
  });
}
