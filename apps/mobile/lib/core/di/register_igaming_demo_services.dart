import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/igaming_demo/data/demo_game_repository_impl.dart';
import 'package:flutter_bloc_app/features/igaming_demo/data/hive_demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_game_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

/// Registers iGaming demo (play-for-fun) services.
void registerIgamingDemoServices() {
  registerLazySingletonIfAbsent<DemoBalanceRepository>(
    () => HiveDemoBalanceRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<DemoGameRepository>(
    DemoGameRepositoryImpl.new,
  );
}
