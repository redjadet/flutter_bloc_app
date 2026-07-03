import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Keeps track of syncable repositories so the coordinator can resolve them.
class SyncableRepositoryRegistry {
  final Map<String, SyncableRepository> _repositories =
      <String, SyncableRepository>{};

  void register(final SyncableRepository repository) {
    final String key = repository.entityType;
    if (_repositories.containsKey(key)) {
      AppLogger.warning(
        'SyncableRepositoryRegistry overriding repository for $key',
      );
    }
    _repositories[key] = repository;
  }

  void unregister(final String entityType) {
    _repositories.remove(entityType);
  }

  SyncableRepository? resolve(final String entityType) =>
      _repositories[entityType];

  List<SyncableRepository> get repositories =>
      List<SyncableRepository>.unmodifiable(
        _repositories.values.toList(growable: false),
      );

  bool get isEmpty => _repositories.isEmpty;
}
