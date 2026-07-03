import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:flutter_bloc_app/shared/utils/failure_to_app_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('appErrorFromFailure', () {
    test('maps PermissionFailure to UnknownError (not auth)', () {
      const failure = PermissionFailure(PermissionFailureReason.denied);

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<UnknownError>());
      expect(error.message, 'Permission denied.');
    });

    test('maps PlatformFailure to UnknownError (not storage)', () {
      const failure = PlatformFailure(PlatformFailureReason.unavailable);

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<UnknownError>());
      expect(error.message, 'Platform capability unavailable.');
    });

    test('maps StorageFailure with key to StorageError', () {
      const failure = StorageFailure(
        kind: StorageFailureKind.read,
        key: 'token',
      );

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<StorageError>());
      expect(error.message, contains('token'));
    });

    test('maps StorageFailure delete kind to StorageErrorKind.delete', () {
      const failure = StorageFailure(kind: StorageFailureKind.delete);

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<StorageError>());
      expect((error as StorageError).kind, StorageErrorKind.delete);
    });

    test('maps TimeoutFailure to NetworkError timeout', () {
      const failure = TimeoutFailure();

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<NetworkError>());
      expect((error as NetworkError).kind, NetworkErrorKind.timeout);
    });

    test('maps ValidationFailure to UnknownError', () {
      const failure = ValidationFailure('invalidCoordinates');

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<UnknownError>());
      expect(error.message, contains('invalidCoordinates'));
    });

    test('maps UnknownFailure to UnknownError', () {
      const failure = UnknownFailure(message: 'boom');

      final AppError error = appErrorFromFailure(failure);

      expect(error, isA<UnknownError>());
      expect(error.message, 'boom');
    });
  });
}
