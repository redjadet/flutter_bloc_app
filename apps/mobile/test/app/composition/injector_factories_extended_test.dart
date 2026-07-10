import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/features/register_iot_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_realtime_market_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/app/composition/injector_factories.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_permission_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_repository_impl.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage/storage.dart';

import '../../test_helpers.dart';

class _MockHiveService extends Mock implements HiveService {}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _MockTimerService extends Mock implements TimerService {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
    getIt.registerSingleton<HiveService>(_MockHiveService());
    getIt.registerSingleton<PendingSyncRepository>(
      _MockPendingSyncRepository(),
    );
    getIt.registerSingleton<SyncableRepositoryRegistry>(
      _MockSyncableRepositoryRegistry(),
    );
    getIt.registerSingleton<TimerService>(_MockTimerService());
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('injector_factories', () {
    test('createCounterRepository returns offline-first repository', () {
      final repo = createCounterRepository();
      expect(repo, isA<OfflineFirstCounterRepository>());
    });

    test('createTodoRepository returns offline-first repository', () {
      final repo = createTodoRepository();
      expect(repo, isA<OfflineFirstTodoRepository>());
    });

    test('createScopedRealtimeMarketRepository returns impl', () {
      registerRealtimeMarketServices();
      final repo = createScopedRealtimeMarketRepository();
      expect(repo, isA<RealtimeMarketRepositoryImpl>());
      expect(repo, isA<RealtimeMarketRepository>());
    });

    test(
      'createRemoteConfigRemoteDataSource returns fake without firebase',
      () {
        final RemoteConfigRemoteDataSource dataSource =
            createRemoteConfigRemoteDataSource();
        expect(dataSource, isA<FakeRemoteConfigRemoteDataSource>());
      },
    );

    test(
      'createRemoteConfigRemoteDataSource tolerates initialized firebase',
      () async {
        await ensureFirebaseInitializedForTests(forceMockPlatform: true);
        await Firebase.initializeApp();
        final RemoteConfigRemoteDataSource dataSource =
            createRemoteConfigRemoteDataSource();
        expect(dataSource, isA<RemoteConfigRemoteDataSource>());
      },
    );
  });

  group('registerIotServices', () {
    test('registers classic bluetooth and permission gateway on test host', () {
      registerIotServices();
      expect(getIt<BlePermissionGateway>(), isA<BlePermissionGateway>());
      expect(
        getIt<ClassicBluetoothRepository>(),
        isA<ClassicBluetoothRepository>(),
      );
    });
  });
}
