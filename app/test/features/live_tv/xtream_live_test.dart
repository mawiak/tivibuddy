import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tivibuddy/features/live_tv/data/xtream/xtream_live_loader.dart';
import 'package:tivibuddy/features/live_tv/data/xtream/xtream_live_parsing.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';

const _access = PlaylistAccess(
  playlistId: 'p1',
  serverUrl: 'http://example.com:8080',
  username: 'anna',
  password: 's/cret',
);

String _b64(String text) => base64.encode(utf8.encode(text));

void main() {
  group('parseLiveStream', () {
    test('reads string and int values', () {
      final channel = parseLiveStream(
        {
          'num': '7',
          'name': ' Das Erste HD ',
          'stream_id': 1234,
          'stream_icon': 'http://logo/1.png',
          'epg_channel_id': 'daserste.de',
          'category_id': '12',
          'tv_archive': 1,
          'tv_archive_duration': '7',
        },
        playlistId: 'p1',
        position: 0,
      )!;

      expect(channel.number, 7);
      expect(channel.name, 'Das Erste HD');
      expect(channel.streamId, 1234);
      expect(channel.logoUrl, 'http://logo/1.png');
      expect(channel.epgChannelId, 'daserste.de');
      expect(channel.categoryId, '12');
      expect(channel.archiveDays, 7);
    });

    test('fills gaps and ignores entries without stream id', () {
      final channel = parseLiveStream(
        {
          'stream_id': '9',
          'stream_icon': '',
          'epg_channel_id': null,
          'category_ids': [3],
          'tv_archive': 0,
          'tv_archive_duration': 5,
        },
        playlistId: 'p1',
        position: 41,
      )!;

      expect(channel.number, 42);
      expect(channel.name, '#9');
      expect(channel.logoUrl, isNull);
      expect(channel.epgChannelId, isNull);
      expect(channel.categoryId, '3');
      expect(channel.archiveDays, 0);
      expect(
        parseLiveStream({'name': 'x'}, playlistId: 'p1', position: 0),
        isNull,
      );
    });
  });

  test('parseShortEpg decodes base64 and picks now and next', () {
    final now = DateTime.utc(2026, 11, 11, 20, 30);
    int ts(int hour, [int minute = 0]) =>
        DateTime.utc(2026, 11, 11, hour, minute).millisecondsSinceEpoch ~/ 1000;

    final result = parseShortEpg({
      'epg_listings': [
        {
          'title': _b64('Tagesschau'),
          'start_timestamp': '${ts(20)}',
          'stop_timestamp': '${ts(20, 15)}',
        },
        {
          'title': _b64('Krimi'),
          'description': _b64('Spannung'),
          'start_timestamp': '${ts(20, 15)}',
          'stop_timestamp': '${ts(21, 45)}',
        },
        {
          'title': _b64('Tagesthemen'),
          'start_timestamp': ts(21, 45),
          'stop_timestamp': ts(22, 15),
        },
      ],
    }, now: now);

    expect(result.now?.title, 'Krimi');
    expect(result.now?.description, 'Spannung');
    expect(result.next?.title, 'Tagesthemen');
    expect(result.now!.progressAt(now), closeTo(0.17, 0.01));
  });

  group('loadXtreamLiveStreams', () {
    test('streams channels in batches from a background isolate', () async {
      final body = jsonEncode([
        for (var i = 0; i < 1200; i++)
          {'num': i + 1, 'name': 'Channel $i', 'stream_id': i},
      ]);

      final batches = await loadXtreamLiveStreams(
        _access,
        // The handler runs in the loader isolate, outside the test zone, so
        // it answers with an error status instead of calling expect.
        clientFactory: () => MockClient((request) async {
          final query = request.url.queryParameters;
          final valid =
              query['action'] == 'get_live_streams' &&
              query['password'] == 's/cret';
          return http.Response(valid ? body : '', valid ? 200 : 400);
        }),
      ).toList();

      expect(batches.map((b) => b.length), [500, 500, 200]);
      expect(batches.last.last.name, 'Channel 1199');
    });

    test('reports rejected credentials', () async {
      expect(
        loadXtreamLiveStreams(
          _access,
          clientFactory: () => MockClient(
            (_) async => http.Response('{"user_info":{"auth":0}}', 200),
          ),
        ).toList(),
        throwsA(isA<CatalogLoadException>()),
      );
      expect(
        loadXtreamLiveStreams(
          _access,
          clientFactory: () => MockClient((_) async => http.Response('', 403)),
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
  });

  test('a crashing loader ends the stream with an error', () async {
    expect(
      loadXtreamLiveStreams(
        _access,
        clientFactory: () => MockClient((_) async => throw StateError('boom')),
      ).toList(),
      throwsA(isA<CatalogLoadException>()),
    );
  });
}
