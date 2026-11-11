import 'dart:convert';

import '../../../playlists/data/xtream/xtream_values.dart';
import '../../domain/live_channel.dart';

// Parsing of Xtream live responses.

LiveCategory? parseLiveCategory(Map<String, Object?> json) {
  final id = xtreamText(json['category_id']);
  final name = xtreamText(json['category_name']);
  if (id == null || name == null) return null;
  return LiveCategory(id: id, name: name, channelCount: 0);
}

/// Returns null for entries without a usable stream id.
///
/// [position] is the index in the provider list; it numbers channels the
/// provider sends without `num`.
LiveChannel? parseLiveStream(
  Map<String, Object?> json, {
  required String playlistId,
  required int position,
}) {
  final streamId = xtreamInt(json['stream_id']);
  if (streamId == null) return null;
  return LiveChannel(
    playlistId: playlistId,
    streamId: streamId,
    number: xtreamInt(json['num']) ?? position + 1,
    name: xtreamText(json['name']) ?? '#$streamId',
    logoUrl: xtreamText(json['stream_icon']),
    epgChannelId: xtreamText(json['epg_channel_id']),
    categoryId: xtreamCategoryId(json),
    archiveDays: xtreamInt(json['tv_archive']) == 1
        ? xtreamInt(json['tv_archive_duration']) ?? 0
        : 0,
  );
}

/// Parses the `get_short_epg` response. Titles and descriptions are base64
/// encoded by the Xtream API.
NowNext parseShortEpg(Object? body, {required DateTime now}) {
  if (body is! Map<String, Object?>) return NowNext.empty;
  final listings = body['epg_listings'];
  if (listings is! List) return NowNext.empty;

  final entries = <EpgEntry>[];
  for (final item in listings) {
    if (item is! Map<String, Object?>) continue;
    final start = xtreamInt(item['start_timestamp']);
    final end = xtreamInt(item['stop_timestamp']);
    final title = _decodeBase64(item['title']);
    if (start == null || end == null || title == null) continue;
    entries.add(
      EpgEntry(
        title: title,
        description: _decodeBase64(item['description']),
        start: DateTime.fromMillisecondsSinceEpoch(start * 1000, isUtc: true),
        end: DateTime.fromMillisecondsSinceEpoch(end * 1000, isUtc: true),
      ),
    );
  }
  entries.sort((a, b) => a.start.compareTo(b.start));
  return NowNext.at(entries, now);
}

String? _decodeBase64(Object? value) {
  final text = xtreamText(value);
  if (text == null) return null;
  try {
    return xtreamText(utf8.decode(base64.decode(text), allowMalformed: true));
  } on FormatException {
    // Some panels send plain text.
    return text;
  }
}
