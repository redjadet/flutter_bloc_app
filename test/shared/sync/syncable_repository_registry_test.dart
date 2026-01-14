import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncableRepositoryRegistry', () {
    test('register adds repository to registry', () {
      final registry = SyncableRepositoryRegistry();
      final repository = _TestSyncableRepository('test');

      registry.register(repository);

      expect(registry.resolve('test'), equals(repository));
    });

    test('register overwrites existing repository with warning', () {
      final registry = SyncableRepositoryRegistry();
      final repo1 = _TestSyncableRepository('test');
      final repo2 = _TestSyncableRepository('test');

      registry.register(repo1);
      registry.register(repo2);

      expect(registry.resolve('test'), equals(repo2));
    });

    test('unregister removes repository from registry', () {
      final registry = SyncableRepositoryRegistry();
      final repository = _TestSyncableRepository('test');

      registry.register(repository);
      expect(registry.resolve('test'), equals(repository));

      registry.unregister('test');
      expect(registry.resolve('test'), isNull);
    });

    test('resolve returns null for unregistered entity type', () {
      final registry = SyncableRepositoryRegistry();

      expect(registry.resolve('unknown'), isNull);
    });

    test('repositories returns list of all registered repositories', () {
      final registry = SyncableRepositoryRegistry();
      final repo1 = _TestSyncableRepository('type1');
      final repo2 = _TestSyncableRepository('type2');

      registry.register(repo1);
      registry.register(repo2);

      final repositories = registry.repositories;
      expect(repositories, hasLength(2));
      expect(repositories, contains(repo1));
      expect(repositories, contains(repo2));
    });

    test('repositories returns unmodifiable list', () {
      final registry = SyncableRepositoryRegistry();
      final repository = _TestSyncableRepository('test');

      registry.register(repository);

      final repositories = registry.repositories;
      expect(
        () => repositories.add(_TestSyncableRepository('other')),
        throwsA(isA<Error>()),
      );
    });

    test('isEmpty returns true when no repositories registered', () {
      final registry = SyncableRepositoryRegistry();
      expect(registry.isEmpty, isTrue);
    });

    test('isEmpty returns false when repositories are registered', () {
      final registry = SyncableRepositoryRegistry();
      final repository = _TestSyncableRepository('test');

      registry.register(repository);
      expect(registry.isEmpty, isFalse);
    });
  });
}

class _TestSyncableRepository implements SyncableRepository {
  _TestSyncableRepository(this.entityType);

  @override
  final String entityType;

  @override
  Future<void> pullRemote() async {}

  @override
  Future<void> processOperation(final SyncOperation operation) async {}
}
