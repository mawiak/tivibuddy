import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// Splits a byte stream containing one JSON array of objects into the
/// decoded objects, without ever holding the whole document (DATA-1).
///
/// Provider catalogs are single arrays of tens of thousands of objects.
/// Decoding them at once needs several times the document size in memory,
/// which a 1 GB TV stick cannot afford. This scanner tracks string and
/// nesting state byte by byte and decodes one element at a time.
///
/// Elements that are not objects (numbers, strings) are skipped. A document
/// that is not an array, for example an error object, raises a
/// [FormatException].
class JsonArraySplitter
    extends StreamTransformerBase<List<int>, Map<String, Object?>> {
  const JsonArraySplitter();

  @override
  Stream<Map<String, Object?>> bind(Stream<List<int>> stream) async* {
    final scanner = _Scanner();
    await for (final chunk in stream) {
      yield* Stream.fromIterable(scanner.add(chunk));
    }
    scanner.close();
  }
}

class _Scanner {
  static const _quote = 0x22; // "
  static const _backslash = 0x5C; // \
  static const _openBrace = 0x7B; // {
  static const _closeBrace = 0x7D; // }
  static const _openBracket = 0x5B; // [
  static const _closeBracket = 0x5D; // ]

  final _element = BytesBuilder(copy: false);
  bool _started = false;
  bool _finished = false;
  bool _inString = false;
  bool _escaped = false;

  /// Nesting depth below the top-level array. 0 means between elements.
  int _depth = 0;

  List<Map<String, Object?>> add(List<int> chunk) {
    final bytes = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
    final results = <Map<String, Object?>>[];
    var elementStart = _depth > 0 ? 0 : -1;

    for (var i = 0; i < bytes.length; i++) {
      final byte = bytes[i];

      if (!_started) {
        if (_isWhitespace(byte)) continue;
        if (byte != _openBracket) {
          throw const FormatException('Expected a JSON array');
        }
        _started = true;
        continue;
      }
      if (_finished) continue;

      if (_inString) {
        if (_escaped) {
          _escaped = false;
        } else if (byte == _backslash) {
          _escaped = true;
        } else if (byte == _quote) {
          _inString = false;
        }
        continue;
      }

      switch (byte) {
        case _quote:
          _inString = true;
        case _openBrace || _openBracket:
          if (_depth == 0) elementStart = i;
          _depth++;
        case _closeBrace || _closeBracket:
          if (_depth == 0) {
            // End of the top-level array.
            _finished = true;
            continue;
          }
          _depth--;
          if (_depth == 0) {
            _element.add(Uint8List.sublistView(bytes, elementStart, i + 1));
            elementStart = -1;
            final decoded = _decode(_element.takeBytes());
            if (decoded != null) results.add(decoded);
          }
      }
    }

    // Keep the unfinished part of an element for the next chunk.
    if (_depth > 0 && elementStart >= 0) {
      _element.add(Uint8List.sublistView(bytes, elementStart));
    }
    return results;
  }

  void close() {
    if (!_started) throw const FormatException('Empty response');
    if (!_finished) throw const FormatException('Truncated JSON array');
  }

  static Map<String, Object?>? _decode(Uint8List bytes) {
    final value = jsonDecode(utf8.decode(bytes, allowMalformed: true));
    return value is Map<String, Object?> ? value : null;
  }

  static bool _isWhitespace(int byte) =>
      byte == 0x20 ||
      byte == 0x0A ||
      byte == 0x0D ||
      byte == 0x09 ||
      byte == 0xEF ||
      byte == 0xBB ||
      byte == 0xBF; // includes UTF-8 BOM
}
