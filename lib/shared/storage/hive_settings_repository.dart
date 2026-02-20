import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Generic repository for storing simple settings in Hive.
///
/// This class consolidates common patterns used across settings repositories
/// like locale, theme, etc. It handles validation, cleanup, and error handling.
abstract class HiveSettingsRepository<T> extends HiveRepositoryBase {
  HiveSettingsRepository({
    required super.hiveService,
    required this.key,
    required this.fromString,
    required this.toStringValue,
    this.validateValue,
  });

  /// The key used to store the value in the Hive box.
  final String key;

  /// Function to convert a string value from Hive to the expected type.
  final T? Function(String value) fromString;

  /// Function to convert the value to a string for storage.
  final String Function(T value) toStringValue;

  /// Optional validation function. Return null if valid, error message if invalid.
  final String? Function(T value)? validateValue;

  @override
  String get boxName => 'settings';

  /// Loads the value from Hive with validation and error handling.
  Future<T?> load() async => StorageGuard.run<T?>(
    logContext: '$runtimeType.load',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic storedValue = box.get(key);

      // Handle null/empty values
      if (storedValue == null) {
        return null;
      }

      if (storedValue is! String) {
        AppLogger.warning(
          'Invalid value type for $key in Hive: expected String, got ${storedValue.runtimeType}',
        );
        await safeDeleteKey(box, key);
        return null;
      }

      if (storedValue.isEmpty) {
        AppLogger.warning('Empty value for $key in Hive, cleaning up');
        await safeDeleteKey(box, key);
        return null;
      }

      try {
        final T? parsedValue = fromString(storedValue);
        if (parsedValue == null) {
          throw FormatException('Could not parse value: $storedValue');
        }

        // Validate the parsed value if validator is provided
        final validator = validateValue;
        if (validator case final validate?) {
          final String? validationError = validate(parsedValue);
          if (validationError case final error?) {
            throw FormatException('Validation failed: $error');
          }
        }

        return parsedValue;
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'Invalid value for $key in Hive: $storedValue',
          error,
          stackTrace,
        );
        // Clean up invalid data
        await safeDeleteKey(box, key);
        return null;
      }
    },
    fallback: () => null,
  );

  /// Saves the value to Hive.
  Future<void> save(final T? value) async => StorageGuard.run<void>(
    logContext: '$runtimeType.save',
    action: () async {
      final Box<dynamic> box = await getBox();
      if (value == null) {
        await box.delete(key);
      } else {
        final String stringValue = toStringValue(value);
        await box.put(key, stringValue);
      }
    },
    fallback: () {},
  );
}
