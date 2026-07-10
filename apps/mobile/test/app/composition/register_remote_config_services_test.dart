import 'package:flutter_bloc_app/app/composition/features/register_remote_config_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/remote_config/data/offline_first_remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

class _MockHiveService extends Mock implements HiveService {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _MockNetworkStatusService extends Mock implements NetworkStatusService {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('registerRemoteConfigServices registers service and cubit', () {
    getIt.registerSingleton<HiveService>(_MockHiveService());
    getIt.registerSingleton<SyncableRepositoryRegistry>(
      _MockSyncableRepositoryRegistry(),
    );
    getIt.registerSingleton<NetworkStatusService>(_MockNetworkStatusService());

    registerRemoteConfigServices();

    expect(
      getIt<RemoteConfigService>(),
      isA<OfflineFirstRemoteConfigRepository>(),
    );
    expect(getIt<RemoteConfigCubit>(), isA<RemoteConfigCubit>());
  });
}
