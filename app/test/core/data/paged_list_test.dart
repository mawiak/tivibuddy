import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/data/paged_list.dart';

void main() {
  late List<int> requestedOffsets;

  PagedList<int> create({int length = 1000, int maxPages = 3}) {
    requestedOffsets = [];
    return PagedList<int>(
      length: length,
      pageSize: 10,
      maxPages: maxPages,
      loader: (offset, limit) async {
        requestedOffsets.add(offset);
        return [for (var i = offset; i < offset + limit && i < length; i++) i];
      },
    );
  }

  test('returns null until the page is loaded, then notifies', () async {
    final list = create();
    var notified = 0;
    list.addListener(() => notified++);

    expect(list.itemAt(15), isNull);
    await Future<void>.delayed(Duration.zero);

    expect(notified, 1);
    expect(list.itemAt(15), 15);
    expect(requestedOffsets, [10]);
  });

  test('loads each page only once while it is in flight', () async {
    final list = create();
    list
      ..itemAt(1)
      ..itemAt(2)
      ..itemAt(3);
    await list.fetch(4);

    expect(requestedOffsets, [0]);
  });

  test('evicts least recently used pages', () async {
    final list = create();
    await list.fetch(0);
    await list.fetch(10);
    await list.fetch(20);
    list.itemAt(0); // page 0 becomes most recently used
    await list.fetch(30); // evicts page 1

    requestedOffsets.clear();
    expect(list.itemAt(5), 5);
    expect(list.itemAt(15), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(requestedOffsets, [10]);
  });

  test('ignores indexes outside the list', () async {
    final list = create(length: 5);

    expect(list.itemAt(-1), isNull);
    expect(await list.fetch(5), isNull);
    expect(requestedOffsets, isEmpty);
  });
}
