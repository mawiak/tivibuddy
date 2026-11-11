/// A category of live channels as defined by the provider.
class LiveCategory {
  const LiveCategory({
    required this.id,
    required this.name,
    required this.channelCount,
  });

  final String id;
  final String name;
  final int channelCount;
}

/// A live channel of a playlist. Kept small and free of Flutter types, so it
/// can be sent between isolates while loading large catalogs.
final class LiveChannel {
  const LiveChannel({
    required this.playlistId,
    required this.streamId,
    required this.number,
    required this.name,
    this.logoUrl,
    this.epgChannelId,
    this.categoryId,
    this.archiveDays = 0,
  });

  final String playlistId;

  /// Provider id of the stream, used to build the playback URL.
  final int streamId;

  /// Channel number shown to the user and used for sorting.
  final int number;
  final String name;
  final String? logoUrl;

  /// Id of the channel in the provider EPG (XMLTV).
  final String? epgChannelId;
  final String? categoryId;

  /// Days of catch-up the provider keeps, 0 when not supported.
  final int archiveDays;

  @override
  bool operator ==(Object other) =>
      other is LiveChannel &&
      other.playlistId == playlistId &&
      other.streamId == streamId;

  @override
  int get hashCode => Object.hash(playlistId, streamId);
}

/// One programme of the electronic programme guide.
class EpgEntry {
  const EpgEntry({
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;

  /// Progress between 0 and 1 at [now].
  double progressAt(DateTime now) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    return (now.difference(start).inSeconds / total).clamp(0, 1);
  }
}

/// Current and following programme of a channel.
class NowNext {
  const NowNext({this.now, this.next});

  /// Picks the programme running at [now] and the one after it from
  /// [entries] ordered by start.
  factory NowNext.at(List<EpgEntry> entries, DateTime now) => NowNext(
    now: entries
        .where((e) => !e.start.isAfter(now) && e.end.isAfter(now))
        .firstOrNull,
    next: entries.where((e) => e.start.isAfter(now)).firstOrNull,
  );

  static const empty = NowNext();

  final EpgEntry? now;
  final EpgEntry? next;
}

/// A programme of the provider guide (XMLTV) as stored locally. Kept free of
/// Flutter types, so batches can be sent between isolates.
final class EpgProgramme {
  const EpgProgramme({
    required this.channelKey,
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  /// [LiveChannel.epgChannelId] of the channels showing this programme.
  final String channelKey;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
}
