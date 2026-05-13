/// Deferred library for realtime market demo (simulated feed + chart).
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_local_data_source.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/realtime_market_repository_impl.dart';
import 'package:flutter_bloc_app/features/realtime_market/data/simulated_market_feed.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/pages/realtime_market_page.dart';

/// Builds page with a **scoped** repository so [RealtimeMarketCubit.close] can
/// dispose the repo without affecting global singletons.
Widget buildRealtimeMarketPage() => BlocProvider(
  create: (_) => RealtimeMarketCubit(
    repository: RealtimeMarketRepositoryImpl(
      localDataSource: getIt<RealtimeMarketLocalDataSource>(),
      feed: getIt<SimulatedMarketFeed>(),
    ),
    pairId: kDefaultRealtimeMarketPairId,
  ),
  child: const RealtimeMarketPage(),
);
