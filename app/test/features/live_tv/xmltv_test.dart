import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tivibuddy/features/live_tv/data/xmltv/xmltv_loader.dart';
import 'package:tivibuddy/features/live_tv/data/xmltv/xmltv_reader.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';
import 'package:xml/xml_events.dart';

const _guide = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tv SYSTEM "xmltv.dtd">
<tv generator-info-name="test">
  <channel id="ard.de"><display-name>Das Erste</display-name></channel>
  <programme start="20261111200000 +0100" stop="20261111201500 +0100" channel="ard.de">
    <title lang="de">Tagesschau</title>
    <title lang="en">News</title>
    <desc lang="de">Nachrichten &amp; Wetter</desc>
  </programme>
  <programme start="20261111201500 +0100" stop="20261111214500 +0100" channel="ard.de">
    <title><![CDATA[Tatort: <Krimi>]]></title>
    <desc/>
  </programme>
  <programme start="20261111200000 +0100" stop="20261111210000 +0100" channel="zdf.de">
    <title>Unknown channel</title>
  </programme>
  <programme start="20261108200000 +0100" stop="20261108210000 +0100" channel="ard.de">
    <title>Too old</title>
  </programme>
  <programme start="20261111220000 +0100" stop="20261111230000 +0100" channel="ard.de">
    <title></title>
  </programme>
</tv>
''';

final _from = DateTime.utc(2026, 11, 11, 12);
final _to = DateTime.utc(2026, 11, 12);

void main() {
  group('parseXmltvTime', () {
    test('applies the offset', () {
      expect(
        parseXmltvTime('20261111201500 +0100'),
        DateTime.utc(2026, 11, 11, 19, 15),
      );
      expect(
        parseXmltvTime('20261111201500 -0230'),
        DateTime.utc(2026, 11, 11, 22, 45),
      );
      expect(
        parseXmltvTime('20261111201500+01:00'),
        DateTime.utc(2026, 11, 11, 19, 15),
      );
    });

    test('takes times without offset as utc and rejects garbage', () {
      expect(
        parseXmltvTime('202611112015'),
        DateTime.utc(2026, 11, 11, 20, 15),
      );
      expect(parseXmltvTime('2026'), isNull);
      expect(parseXmltvTime('abcdefghijklmn'), isNull);
    });
  });

  test('reader keeps known channels in range across chunk borders', () {
    final reader = XmltvReader(channelKeys: {'ard.de'}, from: _from, to: _to);
    // Splitting the document at every possible place must not matter, so
    // feed it in small pieces like a network stream.
    final events = parseEvents(_guide).toList();
    final programmes = [
      for (var i = 0; i < events.length; i += 3)
        ...reader.read(events.sublist(i, (i + 3).clamp(0, events.length))),
    ];

    expect(programmes.map((p) => p.title), ['Tagesschau', 'Tatort: <Krimi>']);
    final first = programmes.first;
    expect(first.channelKey, 'ard.de');
    expect(first.start, DateTime.utc(2026, 11, 11, 19));
    expect(first.end, DateTime.utc(2026, 11, 11, 19, 15));
    expect(first.description, 'Nachrichten & Wetter');
    expect(programmes.last.description, isNull);
  });

  test('loader streams programmes from a background isolate', () async {
    final batches = await loadXmltv(
      Uri.parse('http://example.com/xmltv.php'),
      channelKeys: {'ard.de'},
      from: _from,
      to: _to,
      batchSize: 1,
      clientFactory: () => MockClient((_) async => http.Response(_guide, 200)),
    ).toList();

    expect(batches.expand((b) => b).map((p) => p.title), [
      'Tagesschau',
      'Tatort: <Krimi>',
    ]);
  });

  test('loader reports rejected credentials', () {
    expect(
      loadXmltv(
        Uri.parse('http://example.com/xmltv.php'),
        channelKeys: const {},
        from: _from,
        to: _to,
        clientFactory: () => MockClient((_) async => http.Response('', 401)),
      ).toList(),
      throwsA(
        isA<CatalogLoadException>().having(
          (e) => e.reason,
          'reason',
          CatalogLoadFailure.unauthorized,
        ),
      ),
    );
  });
}
