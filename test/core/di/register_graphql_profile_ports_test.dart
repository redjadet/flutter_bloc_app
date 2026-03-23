import 'dart:io';

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_graphql_services.dart';
import 'package:flutter_bloc_app/core/di/register_profile_services.dart';
import 'package:flutter_bloc_app/core/diagnostics/graphql_cache_clear_port.dart';
import 'package:flutter_bloc_app/core/diagnostics/profile_cache_controls_port.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    await getIt.reset(dispose: true);
    tempDir = Directory.systemTemp.createTempSync('di_ports_test_');
    Hive.init(tempDir.path);
    final HiveService hiveService = HiveService(
      keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
    );
    await hiveService.initialize();
    getIt.registerSingleton<HiveService>(hiveService);
    registerGraphqlServices();
    registerProfileServices();
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test(
    'GraphqlCacheClearPort and ProfileCacheControlsPort alias full repositories',
    () {
      final GraphqlCacheRepository fullCache = getIt<GraphqlCacheRepository>();
      final GraphqlCacheClearPort clearPort = getIt<GraphqlCacheClearPort>();
      expect(identical(fullCache, clearPort), isTrue);

      final ProfileCacheRepository fullProfile =
          getIt<ProfileCacheRepository>();
      final ProfileCacheControlsPort controlsPort =
          getIt<ProfileCacheControlsPort>();
      expect(identical(fullProfile, controlsPort), isTrue);
    },
  );
}
