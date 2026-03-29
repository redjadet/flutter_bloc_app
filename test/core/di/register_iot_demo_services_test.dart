import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_iot_demo_services.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../test_helpers.dart' show FakeTimerService;

class _FakeSupabaseAuthRepository implements SupabaseAuthRepository {
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {}

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late _FakeSupabaseAuthRepository authRepository;

  setUp(() async {
    await getIt.reset(dispose: true);
    SupabaseBootstrapService.resetForTest();
    tempDir = Directory.systemTemp.createTempSync('di_iot_demo_test_');
    Hive.init(tempDir.path);
    hiveService = HiveService(
      keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
    );
    await hiveService.initialize();
    authRepository = _FakeSupabaseAuthRepository();

    getIt.registerSingleton<HiveService>(hiveService);
    getIt.registerSingleton<TimerService>(FakeTimerService());
    getIt.registerSingleton<PendingSyncRepository>(
      PendingSyncRepository(hiveService: hiveService),
    );
    getIt.registerSingleton<SyncableRepositoryRegistry>(
      SyncableRepositoryRegistry(),
    );
    getIt.registerSingleton<SupabaseAuthRepository>(authRepository);
  });

  tearDown(() async {
    await authRepository.dispose();
    await getIt.reset(dispose: true);
    SupabaseBootstrapService.resetForTest();
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test(
    'registers a working local-only IoT repository when Supabase is not configured',
    () async {
      registerIotDemoServices();

      final IotDemoRepository repository = getIt<IotDemoRepository>();
      const IotDevice device = IotDevice(
        id: 'local-1',
        name: 'Local Device',
        type: IotDeviceType.light,
      );

      await repository.addDevice(device);

      final List<IotDevice> devices = await repository.watchDevices().first;
      expect(devices, hasLength(1));
      expect(devices.first.id, 'local-1');
      expect(devices.first.name, 'Local Device');
    },
  );
}
