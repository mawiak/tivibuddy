import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/profiles/data/pin_hasher.dart';

void main() {
  final hasher = PinHasher();

  test('verifies the original pin only', () {
    final hash = hasher.hash('0815');

    expect(hasher.verify('0815', hash), isTrue);
    expect(hasher.verify('0816', hash), isFalse);
  });

  test('uses a random salt', () {
    expect(hasher.hash('0815'), isNot(hasher.hash('0815')));
  });

  test('rejects malformed hashes', () {
    expect(hasher.verify('0815', 'garbage'), isFalse);
    expect(hasher.verify('0815', 'v0:a:b'), isFalse);
  });
}
