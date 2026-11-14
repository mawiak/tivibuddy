import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/shared/widgets/push_aside.dart';

void main() {
  Widget build({required bool open}) => Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: SizedBox(
        width: 800,
        height: 400,
        child: PushAside(
          open: open,
          panelWidth: 240,
          panel: const SizedBox(key: Key('panel')),
          child: const SizedBox(key: Key('child')),
        ),
      ),
    ),
  );

  testWidgets('opening the panel shifts the child without narrowing it', (
    tester,
  ) async {
    await tester.pumpWidget(build(open: false));
    final closed = tester.getRect(find.byKey(const Key('child')));
    expect(find.byKey(const Key('panel')), findsNothing);

    await tester.pumpWidget(build(open: true));
    final opened = tester.getRect(find.byKey(const Key('child')));
    expect(opened.size, closed.size);
    expect(opened.left, closed.left + 240);
    expect(tester.getSize(find.byKey(const Key('panel'))).width, 240);
  });
}
