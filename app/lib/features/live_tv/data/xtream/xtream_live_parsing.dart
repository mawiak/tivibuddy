import 'dart:convert';

import '../../domain/live_channel.dart';

// Parsing of Xtream live responses. Providers deliver numbers as strings or
// ints and empty strings for missing values; everything here tolerates that.

int? _int(Object? value) => switch (value) {
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v.trim()),
  _ => null,
};

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

LiveCategory? parseLiveCategory(Map<String, Object?> json) {
  final id = _text(json['category_id']);
  final name = _text(json['category_name']);
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
  final streamId = _int(json['stream_id']);
  if (streamId == null) return null;
  final categoryIds = json['category_ids'];
  return LiveChannel(
    playlistId: playlistId,
    streamId: streamId,
    number: _int(json['num']) ?? position + 1,
    name: _text(json['name']) ?? '#$streamId',
    logoUrl: _text(json['stream_icon']),
    epgChannelId: _text(json['epg_channel_id']),
    categoryId:
        _text(json['category_id']) ??
        (categoryIds is List && categoryIds.isNotEmpty
            ? _text(categoryIds.first)
            : null),
    archiveDays: _int(json['tv_archive']) == 1
        ? _int(json['tv_archive_duration']) ?? 0
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
    final start = _int(item['start_timestamp']);
    final end = _int(item['stop_timestamp']);
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
  final text = _text(value);
  if (text == null) return null;
  try {
    return _text(utf8.decode(base64.decode(text), allowMalformed: true));
  } on FormatException {
    // Some panels send plain text.
    return text;
  }
}
