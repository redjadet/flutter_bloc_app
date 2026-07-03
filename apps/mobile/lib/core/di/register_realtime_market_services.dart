import 'dart:math';
import 'package:core/core.dart';

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_local_data_source.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/security/certificate_pinning_policy.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/security/market_feed_remote_port.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/security/realtime_market_backend_config.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/security/trading_api_token_store.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

/// Hive cache + simulated feed + security stubs for the market demo.
void registerRealtimeMarketServices() {
  registerLazySingletonIfAbsent<RealtimeMarketLocalDataSource>(
    () => RealtimeMarketLocalDataSource(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<SimulatedMarketFeed>(
    () => SimulatedMarketFeed(
      random: Random(),
      timerService: getIt<TimerService>(),
    ),
  );
  registerLazySingletonIfAbsent<CertificatePinningPolicy>(
    () => const CertificatePinningPolicy(),
  );
  registerLazySingletonIfAbsent<TradingApiTokenStore>(TradingApiTokenStore.new);
  registerLazySingletonIfAbsent<RealtimeMarketBackendConfig>(
    () => const RealtimeMarketBackendConfig(),
  );
  registerLazySingletonIfAbsent<MarketFeedRemotePort>(
    NoopMarketFeedRemotePort.new,
  );
}
