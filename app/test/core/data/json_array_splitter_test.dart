import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/data/json_array_splitter.dart';

Future<List<Map<String, Object?>>> split(
  String json, {
  int chunkSize = 1 << 20,
}) {
  final bytes = utf8.encode(json);
  final chunks = <List<int>>[
    for (var i = 0; i < bytes.length; i += chunkSize)
      bytes.sublist(i, (i + chunkSize).clamp(0, bytes.length)),
  ];
  return Stream.fromIterable(chunks)
      .transform(const JsonArraySplitter())
      .toList();
}

void main() {
  const document = '''
  [
    {"name": "Das Erste HD", "num": 1, "tags": ["a", "b"]},
    {"name": "Brace } and bracket ] in \\"string\\"", "nested": {"x": [1, {"y": 2}]}},
    42,
    {"name": "Ümläut ✓"}
  ]''';

  test('decodes every object of the array', () async {
    final objects = await split(document);

    expect(objects.map((o) => o['name']), [
      'Das Erste HD',
      'Brace } and bracket ] in "string"',
      'Ümläut ✓',
    ]);
    expect(objects[1]['nested'], {
      'x': [
        1,
        {'y': 2},
      ],
    });
  });

  test('handles elements split across arbitrary chunk boundaries', () async {
    for (final size in [1, 2, 3, 7, 16]) {
      expect(await split(document, chunkSize: size), await split(document));
    }
  });

  test('accepts an empty array and a byte order mark', () async {
    expect(await split('[]'), isEmpty);
    expect(await split('﻿ [ {"a": 1} ]'), [
      {'a': 1},
    ]);
  });

  test('rejects documents that are not arrays', () async {
    expect(split('{"user_info": {"auth": 0}}'), throwsFormatException);
    expect(split(''), throwsFormatException);
  });

  test('rejects truncated documents', () async {
    expect(split('[{"a": 1}, {"b":'), throwsFormatException);
  });

  test('stays fast for large catalogs', () async {
    final big = StringBuffer('[');
    for (var i = 0; i < 20000; i++) {
      if (i > 0) big.write(',');
      big.write(
        '{"num":$i,"name":"Channel $i","stream_id":$i,'
        '"stream_icon":"http://logo.example.com/$i.png","category_id":"${i % 50}"}',
      );
    }
    big.write(']');

    final watch = Stopwatch()..start();
    final objects = await split(big.toString(), chunkSize: 64 * 1024);
    watch.stop();

    expect(objects, hasLength(20000));
    expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
  });
}
