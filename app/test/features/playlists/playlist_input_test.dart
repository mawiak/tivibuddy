import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';

void main() {
  group('normalizeServerUrl', () {
    test('adds http and removes trailing slashes', () {
      expect(
        normalizeServerUrl('example.com:8080/'),
        'http://example.com:8080',
      );
      expect(
        normalizeServerUrl(' https://tv.example.com '),
        'https://tv.example.com',
      );
      expect(
        normalizeServerUrl('http://example.com/xc/'),
        'http://example.com/xc',
      );
    });

    test('rejects unusable input', () {
      expect(normalizeServerUrl(''), isNull);
      expect(normalizeServerUrl('ftp://example.com'), isNull);
      expect(normalizeServerUrl('http://'), isNull);
    });
  });

  group('parseXtreamLink', () {
    test('splits a full m3u link into credentials', () {
      final result = parseXtreamLink(
        'http://line.example.com:8080/get.php?username=anna&password=s3cret&type=m3u_plus&output=ts',
      );

      expect(result?.serverUrl, 'http://line.example.com:8080');
      expect(result?.username, 'anna');
      expect(result?.password, 's3cret');
    });

    test('ignores links without credentials', () {
      expect(parseXtreamLink('http://example.com:8080'), isNull);
      expect(parseXtreamLink('not a link'), isNull);
    });
  });

  test('validation reports every problem', () {
    const input = PlaylistInput(
      name: ' ',
      serverUrl: 'ftp://x',
      username: '',
      password: '',
    );

    expect(validatePlaylistInput(input), {
      PlaylistInputError.nameEmpty,
      PlaylistInputError.serverInvalid,
      PlaylistInputError.usernameEmpty,
      PlaylistInputError.passwordEmpty,
    });
  });
}
