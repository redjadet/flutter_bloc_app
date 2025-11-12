import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Base class for Hive-backed repositories to reduce code duplication.
///
/// Provides common functionality for opening boxes and safely deleting keys.
/// Subclasses must implement [boxName] to specify which Hive box to use.
abstract class HiveRepositoryBase {
  /// Creates a new [HiveRepositoryBase] with the given [hiveService].
  HiveRepositoryBase({required final HiveService hiveService})
    : _hiveService = hiveService;

  final HiveService _hiveService;

  /// Gets the box name for this repository.
  ///
  /// This must be implemented by subclasses to specify which Hive box
  /// should be used for storage operations.
  String get boxName;

  /// Opens and returns the Hive box for this repository.
  ///
  /// The box is opened with encryption enabled by default.
  Future<Box<dynamic>> getBox() => _hiveService.openBox(boxName);

  /// Safely deletes a key from the box, ignoring errors.
  ///
  /// This is useful for cleanup operations where failures should not
  /// propagate to the caller.
  Future<void> safeDeleteKey(
    final Box<dynamic> box,
    final String key,
  ) async {
    try {
      await box.delete(key);
    } on Exception {
      // Ignore cleanup errors - this is a best-effort operation
    }
  }
}
