import 'package:xml/xml_events.dart';

import '../../domain/live_channel.dart';

final _offsetPattern = RegExp(r'([+-])(\d{2}):?(\d{2})$');

/// Parses an XMLTV time such as `20261111201500 +0100`. Seconds and the
/// offset are optional; without an offset the time is taken as UTC.
DateTime? parseXmltvTime(String value) {
  final text = value.trim();
  if (text.length < 12) return null;
  int? part(int start, int end) =>
      end <= text.length ? int.tryParse(text.substring(start, end)) : null;

  final year = part(0, 4);
  final month = part(4, 6);
  final day = part(6, 8);
  final hour = part(8, 10);
  final minute = part(10, 12);
  if (year == null ||
      month == null ||
      day == null ||
      hour == null ||
      minute == null) {
    return null;
  }
  final second = text.length >= 14 ? part(12, 14) ?? 0 : 0;
  var time = DateTime.utc(year, month, day, hour, minute, second);

  final offset = _offsetPattern.firstMatch(text);
  if (offset != null) {
    final minutes =
        int.parse(offset.group(2)!) * 60 + int.parse(offset.group(3)!);
    time = offset.group(1) == '+'
        ? time.subtract(Duration(minutes: minutes))
        : time.add(Duration(minutes: minutes));
  }
  return time;
}

/// Turns the event stream of an XMLTV document into programmes, one chunk
/// of events at a time, so documents of any size are parsed with constant
/// memory (DATA-1).
///
/// Only programmes of [channelKeys] that overlap [from] to [to] are kept.
/// Of several titles or descriptions (one per language) the first is used.
class XmltvReader {
  XmltvReader({
    required this.channelKeys,
    required this.from,
    required this.to,
  });

  final Set<String> channelKeys;
  final DateTime from;
  final DateTime to;

  bool _inProgramme = false;
  String? _channel;
  DateTime? _start;
  DateTime? _end;
  String? _title;
  String? _description;

  /// Element whose text is collected, `title` or `desc`.
  String? _capturing;
  final _text = StringBuffer();

  /// Programmes completed by [events].
  List<EpgProgramme> read(List<XmlEvent> events) {
    final result = <EpgProgramme>[];
    for (final event in events) {
      switch (event) {
        case XmlStartElementEvent(name: 'programme', :final attributes):
          _startProgramme(attributes, isSelfClosing: event.isSelfClosing);
        case XmlStartElementEvent(:final name) when _inProgramme:
          if ((name == 'title' && _title == null) ||
              (name == 'desc' && _description == null)) {
            _capturing = event.isSelfClosing ? null : name;
            _text.clear();
          }
        case XmlTextEvent(:final value) when _capturing != null:
          _text.write(value);
        case XmlCDATAEvent(:final value) when _capturing != null:
          _text.write(value);
        case XmlEndElementEvent(name: 'programme') when _inProgramme:
          final programme = _finishProgramme();
          if (programme != null) result.add(programme);
        case XmlEndElementEvent(:final name) when name == _capturing:
          final text = _text.toString().trim();
          if (name == 'title') {
            _title = text;
          } else {
            _description = text.isEmpty ? null : text;
          }
          _capturing = null;
        default:
          break;
      }
    }
    return result;
  }

  void _startProgramme(
    List<XmlEventAttribute> attributes, {
    required bool isSelfClosing,
  }) {
    String? attribute(String name) =>
        attributes.where((a) => a.name == name).firstOrNull?.value;

    final channel = attribute('channel');
    final start = parseXmltvTime(attribute('start') ?? '');
    final end = parseXmltvTime(attribute('stop') ?? '');
    _inProgramme =
        !isSelfClosing &&
        channel != null &&
        channelKeys.contains(channel) &&
        start != null &&
        end != null &&
        end.isAfter(start) &&
        end.isAfter(from) &&
        start.isBefore(to);
    if (!_inProgramme) return;
    _channel = channel;
    _start = start;
    _end = end;
    _title = null;
    _description = null;
    _capturing = null;
  }

  EpgProgramme? _finishProgramme() {
    _inProgramme = false;
    final title = _title;
    if (title == null || title.isEmpty) return null;
    return EpgProgramme(
      channelKey: _channel!,
      title: title,
      description: _description,
      start: _start!,
      end: _end!,
    );
  }
}
