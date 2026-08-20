import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_local_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_mutation_queue.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/offline_first_social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:storage/storage.dart';

void registerSocialFeedDemoServices() {
  registerLazySingletonIfAbsent<SimulatedSocialFeedScenarioController>(
    SimulatedSocialFeedScenarioController.new,
  );
  registerLazySingletonIfAbsent<SocialFeedScenarioController>(
    () => getIt<SimulatedSocialFeedScenarioController>(),
  );
  registerLazySingletonIfAbsent<SimulatedSocialFeedRemoteDataSource>(
    () => SimulatedSocialFeedRemoteDataSource(
      scenario: getIt<SimulatedSocialFeedScenarioController>(),
      clock: () => DateTime.now().toUtc(),
    ),
  );
  registerLazySingletonIfAbsent<HiveSocialFeedLocalDataSource>(
    () => HiveSocialFeedLocalDataSource(
      hiveService: getIt<HiveService>(),
      clock: () => DateTime.now().toUtc(),
    ),
  );
  registerLazySingletonIfAbsent<HiveSocialFeedMutationQueue>(
    () => HiveSocialFeedMutationQueue(
      hiveService: getIt<HiveService>(),
      clock: () => DateTime.now().toUtc(),
    ),
  );
  registerLazySingletonIfAbsent<OfflineFirstSocialFeedRepository>(
    () => OfflineFirstSocialFeedRepository(
      local: getIt<HiveSocialFeedLocalDataSource>(),
      queue: getIt<HiveSocialFeedMutationQueue>(),
      remote: getIt<SimulatedSocialFeedRemoteDataSource>(),
      scenario: getIt<SimulatedSocialFeedScenarioController>(),
      timerService: getIt<TimerService>(),
    ),
    dispose: (repo) => repo.dispose(),
  );
  registerLazySingletonIfAbsent<SocialFeedRepository>(
    () => getIt<OfflineFirstSocialFeedRepository>(),
  );
  registerLazySingletonIfAbsent<SimulatedSocialFeedRealtimeSource>(
    () => SimulatedSocialFeedRealtimeSource(
      scenario: getIt<SimulatedSocialFeedScenarioController>(),
      remote: getIt<SimulatedSocialFeedRemoteDataSource>(),
      timerService: getIt<TimerService>(),
    ),
    dispose: (source) => source.dispose(),
  );
  registerLazySingletonIfAbsent<SocialFeedRealtimeSource>(
    () => getIt<SimulatedSocialFeedRealtimeSource>(),
  );
}
