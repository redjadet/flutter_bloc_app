import 'package:hive_flutter/hive_flutter.dart';

import 'hive_schema_migration.dart';
import 'hive_service.dart';

/// Base class for Hive-backed repositories to reduce code duplication.
///
/// Provides common functionality for opening boxes and safely deleting keys.
/// Subclasses must implement [boxName] to specify which Hive box to use.
abstract class HiveRepositoryBase {
  /// Creates a new [HiveRepositoryBase] with the given [_hiveService].
  HiveRepositoryBase({required this._hiveService});

  final HiveService _hiveService;

  /// Gets the box name for this repository.
  ///
  /// This must be implemented by subclasses to specify which Hive box
  /// should be used for storage operations.
  String get boxName;

  /// Optional schema namespace declaration for this repository's box data.
  ///
  /// MVP-0: only metadata is written; payload is not mutated on mismatch.
  HiveBoxSchema? get schema => null;

  /// Runs [action] on the Hive box after schema migration when configured.
  ///
  /// Prefer this over [getBox] when reading or writing box entries so
  /// recoverable decrypt failures stay inside [HiveService.openBoxAndRun].
  Future<T> runWithBox<T>(
    final Future<T> Function(Box<dynamic> box) action,
  ) async {
    return _hiveService.openBoxAndRun<T>(
      boxName,
      action: (final box) async {
        await _ensureSchema(box);
        return action(box);
      },
    );
  }

  /// Opens and returns the Hive box for this repository.
  ///
  /// The box is opened with encryption enabled by default.
  Future<Box<dynamic>> getBox() async => runWithBox((final box) async => box);

  Future<void> _ensureSchema(final Box<dynamic> box) async {
    final HiveBoxSchema? s = schema;
    if (s == null) {
      return;
    }
    final HiveSchemaMigratorService migrator = HiveSchemaMigratorService(
      enableMigrations: HiveSchemaMigratorService.isEnabled,
    );
    await migrator.ensureSchema(
      box: box,
      schema: s,
      // Already under per-box lock.
      runWithBoxLock: (final Future<void> Function() runAction) => runAction(),
    );
  }

  /// Safely deletes a key from the box, ignoring errors.
  ///
  /// This is useful for cleanup operations where failures should not
  /// propagate to the caller.
  Future<void> safeDeleteKey(final Box<dynamic> box, final String key) async {
    try {
      await box.delete(key);
    } on Object {
      // Ignore cleanup errors - this is a best-effort operation
    }
  }
}
