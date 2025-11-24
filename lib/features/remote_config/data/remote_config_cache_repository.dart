import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive/hive.dart';

/// Hive-backed cache for Remote Config values and metadata.
class RemoteConfigCacheRepository extends HiveRepositoryBase {
  RemoteConfigCacheRepository({required super.hiveService});

  static const String _boxName = 'remote_config_cache';
  static const String _snapshotKey = 'snapshot';
  static const String _valuesKey = 'values';
  static const String _lastFetchedKey = 'lastFetchedAt';
  static const String _templateVersionKey = 'templateVersion';

  @override
  String get boxName => _boxName;

  Future<RemoteConfigSnapshot?> loadSnapshot() => StorageGuard.run(
    logContext: 'RemoteConfigCacheRepository.loadSnapshot',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic raw = box.get(_snapshotKey);
      if (raw is! Map<dynamic, dynamic>) {
        return null;
      }
      final Map<String, dynamic> values = _mapValues(raw[_valuesKey]);
      final String? lastFetchedRaw = raw[_lastFetchedKey] as String?;
      final DateTime? lastFetchedAt = lastFetchedRaw == null
          ? null
          : DateTime.tryParse(lastFetchedRaw);
      final String? templateVersion = raw[_templateVersionKey] as String?;
      return RemoteConfigSnapshot(
        values: values,
        lastFetchedAt: lastFetchedAt,
        templateVersion: templateVersion,
      );
    },
    fallback: () => null,
  );

  Future<void> saveSnapshot(final RemoteConfigSnapshot snapshot) =>
      StorageGuard.run(
        logContext: 'RemoteConfigCacheRepository.saveSnapshot',
        action: () async {
          final Box<dynamic> box = await getBox();
          await box.put(
            _snapshotKey,
            <String, dynamic>{
              _valuesKey: Map<String, dynamic>.from(snapshot.values),
              _lastFetchedKey: snapshot.lastFetchedAt?.toIso8601String(),
              _templateVersionKey: snapshot.templateVersion,
            },
          );
        },
      );

  Future<void> clear() => StorageGuard.run(
    logContext: 'RemoteConfigCacheRepository.clear',
    action: () async {
      final Box<dynamic> box = await getBox();
      await safeDeleteKey(box, _snapshotKey);
    },
  );

  Map<String, dynamic> _mapValues(final dynamic rawValues) {
    if (rawValues is Map<dynamic, dynamic>) {
      return rawValues.map(
        (final dynamic key, final dynamic value) => MapEntry(
          key.toString(),
          value,
        ),
      );
    }
    return <String, dynamic>{};
  }
}
