import 'package:flutter_bloc_app/app/composition/features/register_profile_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/profile/data/offline_first_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
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

  test('registerProfileServices registers offline-first ProfileRepository', () {
    getIt.registerSingleton<HiveService>(_MockHiveService());
    getIt.registerSingleton<SyncableRepositoryRegistry>(
      _MockSyncableRepositoryRegistry(),
    );
    getIt.registerSingleton<NetworkStatusService>(_MockNetworkStatusService());

    registerProfileServices();

    expect(getIt<ProfileRepository>(), isA<OfflineFirstProfileRepository>());
  });
}
