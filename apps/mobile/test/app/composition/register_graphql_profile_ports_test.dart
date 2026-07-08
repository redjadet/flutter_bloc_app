import 'dart:io';

import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/features/register_graphql_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_profile_services.dart';
import 'package:flutter_bloc_app/app/diagnostics/graphql_cache_clear_port.dart';
import 'package:flutter_bloc_app/app/diagnostics/profile_cache_controls_port.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_cache_clear_port_adapter.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';
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
    'GraphqlCacheClearPort adapter and ProfileCacheControlsPort alias repositories',
    () {
      final GraphqlCacheRepository fullCache = getIt<GraphqlCacheRepository>();
      final GraphqlCacheClearPort clearPort = getIt<GraphqlCacheClearPort>();
      expect(clearPort, isA<GraphqlCacheClearPortAdapter>());
      expect(identical(fullCache, clearPort), isFalse);

      final ProfileCacheRepository fullProfile =
          getIt<ProfileCacheRepository>();
      final ProfileCacheControlsPort controlsPort =
          getIt<ProfileCacheControlsPort>();
      expect(identical(fullProfile, controlsPort), isTrue);
    },
  );
}
