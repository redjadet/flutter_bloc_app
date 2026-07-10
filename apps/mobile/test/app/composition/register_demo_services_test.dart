import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_registrations.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

import '../../test_helpers.dart' as test_helpers;

class _MockHiveService extends Mock implements HiveService {}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _MockTimerService extends Mock implements TimerService {}

void main() {
  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

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

  test(
    'registerDemoServices registers demo utility and sync services',
    () async {
      await registerDemoServices();

      expect(getIt.isRegistered<EventBus>(), isTrue);
      expect(getIt.isRegistered<CameraGalleryRepository>(), isTrue);
      expect(getIt.isRegistered<ScapesRepository>(), isTrue);
      expect(getIt.isRegistered<PendingSyncRepository>(), isTrue);
      expect(getIt.isRegistered<SyncableRepositoryRegistry>(), isTrue);
      expect(getIt.isRegistered<BackgroundSyncCoordinator>(), isTrue);
    },
  );
}
