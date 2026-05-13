/// Realtime market demo (simulated feed + Hive cache).
library;

export 'data/realtime_market_local_data_source.dart';
export 'data/realtime_market_repository_impl.dart';
export 'data/security/certificate_pinning_policy.dart';
export 'data/security/market_feed_remote_port.dart';
export 'data/security/realtime_market_backend_config.dart';
export 'data/security/trading_api_token_store.dart';
export 'data/simulated_market_feed.dart';
export 'domain/entities/market_connection_status.dart';
export 'domain/entities/market_feed_snapshot.dart';
export 'domain/entities/market_stats.dart';
export 'domain/entities/order_book_level.dart';
export 'domain/entities/recent_trade.dart';
export 'domain/realtime_market_repository.dart';
export 'domain/use_cases/load_cached_market_snapshot.dart';
export 'domain/use_cases/reconnect_realtime_market.dart';
export 'domain/use_cases/watch_realtime_market.dart';
export 'presentation/cubit/realtime_market_cubit.dart';
export 'presentation/cubit/realtime_market_state.dart';
export 'presentation/pages/realtime_market_page.dart';
