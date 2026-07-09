import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

void main() {
  test('isRecoverableHiveFailure detects adapter errors', () {
    expect(
      isRecoverableHiveFailure(
        Exception('did you forget to register an adapter'),
      ),
      isTrue,
    );
    expect(isRecoverableHiveFailure(Exception('network')), isFalse);
  });
}
