import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

typedef HiveSchemaMigrator =
    Future<void> Function(
      Box<dynamic> box, {
      required String? fromFingerprint,
    });

/// Declares a schema fingerprint for a Hive box namespace.
///
/// This repo stores Hive values as primitives/Map/JSON (not Hive TypeAdapters).
/// Fingerprints are manifest-driven; runtime fingerprints change only when the
/// manifest `spec` changes.
class HiveBoxSchema {
  const HiveBoxSchema({
    required this.boxName,
    required this.namespace,
    required this.fingerprint,
    this.migrate,
    this.cleanup,
  });

  /// Box name as passed to `HiveService.openBox`.
  final String boxName;

  /// Namespace inside the box, typically a key or key-prefix identifier.
  ///
  /// Examples:
  /// - `todos`
  /// - `query_*`
  /// - `settings:theme_mode`
  final String namespace;

  /// Deterministic fingerprint for the namespace schema.
  final String fingerprint;

  /// Optional forward migrator for payload rewrites, salvage, or quarantine.
  final HiveSchemaMigrator? migrate;

  /// Optional cleanup migrator (drop only incompatible entries).
  final HiveSchemaMigrator? cleanup;
}

/// Hive schema metadata + best-effort migration coordinator.
///
/// Contract:
/// - Writes/repairs metadata.
/// - If [HiveBoxSchema.migrate] or [HiveBoxSchema.cleanup] provided, can run
///   migration/cleanup under a per-box lock.
/// - If no migrator, mismatch is only logged and fingerprint is left unchanged.
class HiveSchemaMigratorService {
  HiveSchemaMigratorService({final bool enableMigrations = true})
    : _enableMigrations = enableMigrations;

  static const String metaKeyFingerprints = '__meta__schema_fingerprints';

  final bool _enableMigrations;

  /// Global kill switch for schema ensure/migrations.
  ///
  /// Default enabled. Disable via `--dart-define=HIVE_SCHEMA_MIGRATIONS=false`.
  static bool get isEnabled =>
      _enabledOverride ??
      const bool.fromEnvironment(
        'HIVE_SCHEMA_MIGRATIONS',
        defaultValue: true,
      );

  static bool? _enabledOverride;

  @visibleForTesting
  static bool? get enabledOverrideForTest => _enabledOverride;

  @visibleForTesting
  static set enabledOverrideForTest(final bool? enabled) {
    _enabledOverride = enabled;
  }

  Future<void> ensureSchema({
    required final Box<dynamic> box,
    required final HiveBoxSchema schema,
    required final Future<void> Function(Future<void> Function() action)
    runWithBoxLock,
  }) async {
    if (!_enableMigrations || !isEnabled) {
      return;
    }
    if (!box.isOpen) {
      return;
    }
    if (box.name != schema.boxName) {
      throw ArgumentError(
        'Schema boxName mismatch. box=${box.name} schema=${schema.boxName}',
      );
    }

    await runWithBoxLock(() async {
      final Map<String, String> fingerprints = _readFingerprints(box);
      final String? previous = fingerprints[schema.namespace];

      if (previous == null) {
        final bool migrated = await _tryMigrateOrCleanup(
          box: box,
          schema: schema,
          fromFingerprint: null,
        );
        // First adoption for this namespace. Only persist fingerprint after
        // successful migration/cleanup (or when no migrator exists).
        if (!migrated && schema.migrate == null && schema.cleanup == null) {
          fingerprints[schema.namespace] = schema.fingerprint;
          await _writeFingerprints(box, fingerprints);
          return;
        }
        if (migrated) {
          fingerprints[schema.namespace] = schema.fingerprint;
          await _writeFingerprints(box, fingerprints);
        }
        return;
      }

      if (previous == schema.fingerprint) {
        return;
      }

      final bool migrated = await _tryMigrateOrCleanup(
        box: box,
        schema: schema,
        fromFingerprint: previous,
      );
      if (migrated) {
        fingerprints[schema.namespace] = schema.fingerprint;
        await _writeFingerprints(box, fingerprints);
      }
    });
  }

  Future<bool> _tryMigrateOrCleanup({
    required final Box<dynamic> box,
    required final HiveBoxSchema schema,
    required final String? fromFingerprint,
  }) async {
    final HiveSchemaMigrator? migrator = schema.migrate ?? schema.cleanup;
    if (migrator == null) {
      AppLogger.warning(
        'Hive schema fingerprint mismatch for ${box.name}:${schema.namespace}. '
        'from=$fromFingerprint to=${schema.fingerprint}. No migrator provided.',
      );
      return false;
    }

    try {
      await migrator(box, fromFingerprint: fromFingerprint);
      return true;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Hive schema migration failed for ${box.name}:${schema.namespace}',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Map<String, String> _readFingerprints(final Box<dynamic> box) {
    dynamic raw;
    try {
      raw = box.get(metaKeyFingerprints);
    } on Exception {
      return <String, String>{};
    }
    if (raw is Map) {
      final Map<String, String> out = <String, String>{};
      raw.forEach((final dynamic k, final dynamic v) {
        if (k is String && v is String && k.isNotEmpty && v.isNotEmpty) {
          out[k] = v;
        }
      });
      return out;
    }
    return <String, String>{};
  }

  Future<void> _writeFingerprints(
    final Box<dynamic> box,
    final Map<String, String> fingerprints,
  ) async {
    // Store as Map<String, String> (Hive supports dynamic map payloads).
    await box.put(metaKeyFingerprints, Map<String, String>.from(fingerprints));
  }
}
