import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/shared/widgets/marquee_text.dart';

import '../../helpers/test_app.dart';

const _longText =
    'A very long programme title that will never fit into a narrow row';

Widget _row({required String text, required bool active}) => Center(
  child: SizedBox(width: 120, child: MarqueeText(text, active: active)),
);

double _scrollOffset(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byType(MarqueeText),
      matching: find.byType(Transform),
    ),
  );
  return -transform.transform.getTranslation().x;
}

void main() {
  testWidgets('inactive overflowing text is ellipsized', (tester) async {
    await pumpTestApp(tester, _row(text: _longText, active: false));

    final text = tester.widget<Text>(find.text(_longText));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(find.byType(Transform), findsNothing);
  });

  testWidgets('active text that fits does not scroll', (tester) async {
    await pumpTestApp(tester, _row(text: 'Short', active: true));

    expect(find.text('Short'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MarqueeText),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
  });

  testWidgets('active overflowing text scrolls after the pause', (
    tester,
  ) async {
    await pumpTestApp(tester, _row(text: _longText, active: true));

    expect(_scrollOffset(tester), 0);

    await tester.pump(const Duration(milliseconds: 500));
    expect(_scrollOffset(tester), 0, reason: 'still in the initial pause');

    await tester.pump(const Duration(seconds: 1));
    expect(_scrollOffset(tester), greaterThan(0));
  });

  testWidgets('deactivating stops scrolling', (tester) async {
    await pumpTestApp(tester, _row(text: _longText, active: true));
    await tester.pump(const Duration(seconds: 2));

    await pumpTestApp(tester, _row(text: _longText, active: false));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text(_longText), findsOneWidget);
  });
}
