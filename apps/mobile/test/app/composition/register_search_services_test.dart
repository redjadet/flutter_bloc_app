import 'package:flutter_bloc_app/app/composition/features/register_search_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/search/domain/search_cache_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

class _MockHiveService extends Mock implements HiveService {}

class _MockNetworkStatusService extends Mock implements NetworkStatusService {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('registerSearchServices', () {
    test('registers cache and repository contracts', () {
      getIt.registerSingleton<HiveService>(_MockHiveService());
      getIt.registerSingleton<NetworkStatusService>(
        _MockNetworkStatusService(),
      );
      getIt.registerSingleton<SyncableRepositoryRegistry>(
        _MockSyncableRepositoryRegistry(),
      );

      registerSearchServices();

      expect(getIt.isRegistered<SearchCacheRepository>(), isTrue);
      expect(getIt.isRegistered<SearchRepository>(), isTrue);

      expect(getIt<SearchCacheRepository>(), isNotNull);
      expect(getIt<SearchRepository>(), isNotNull);
    });
  });
}
