import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/logging/app_log.dart';
import 'package:tivibuddy/core/logging/redact.dart';

void main() {
  test('removes credentials from stream paths and queries', () {
    expect(
      redactCredentials(
        'player open: http://tv.example:8080/live/anna/s3cret/1001.ts',
      ),
      'player open: http://tv.example:8080/live/***/***/1001.ts',
    );
    expect(
      redactCredentials(
        'http://x/movie/a.b/p%40ss/77.mkv and /series/u/p/5.mp4',
      ),
      'http://x/movie/***/***/77.mkv and /series/***/***/5.mp4',
    );
    expect(
      redactCredentials(
        'GET /player_api.php?username=anna&password=s3cret&action=x',
      ),
      'GET /player_api.php?username=***&password=***&action=x',
    );
    expect(redactCredentials('player buffering'), 'player buffering');
  });

  test('keeps only the most recent lines', () {
    final log = AppLog(maxLines: 3)
      ..add('one')
      ..add('two\nthree')
      ..add('four /live/u/p/1.ts');
    expect(log.lines.map((line) => line.substring(13)), [
      'two',
      'three',
      'four /live/***/***/1.ts',
    ]);
  });
}
