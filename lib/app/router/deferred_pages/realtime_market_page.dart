/// Deferred library for realtime market demo (simulated feed + chart).
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/pages/realtime_market_page.dart';

/// Builds page with a **scoped** repository so [RealtimeMarketCubit.close] can
/// dispose the repo without affecting global singletons.
Widget buildRealtimeMarketPage() => BlocProvider(
  create: (_) => RealtimeMarketCubit(
    repository: createScopedRealtimeMarketRepository(),
    pairId: kDefaultRealtimeMarketPairId,
  ),
  child: const RealtimeMarketPage(),
);
