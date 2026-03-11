import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_chart_services.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/chart/data/api/coingecko_api.dart';
import 'package:flutter_bloc_app/features/chart/data/auth_aware_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/direct_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/data/offline_first_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCoingeckoApi implements CoingeckoApi {
  var requestCount = 0;

  @override
  Future<String> getBitcoinMarketChart(
    final Map<String, String> query,
    final String accept,
  ) async {
    requestCount += 1;
    return '{"prices":[[1741478400000,41000.5],[1741564800000,42000.0]]}';
  }
}

class _FakeChartCacheRepository implements ChartCacheRepository {
  List<ChartPoint> cached = const <ChartPoint>[];
  List<ChartPoint>? lastWritten;

  @override
  Future<List<ChartPoint>> readTrendingCounts({final Duration? maxAge}) async =>
      cached;

  @override
  Future<void> writeTrendingCounts(final List<ChartPoint> points) async {
    lastWritten = points;
  }
}

class _FakeSupabaseAuthRepository implements SupabaseAuthRepository {
  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  bool get isConfigured => false;

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
}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
    SupabaseBootstrapService.resetForTest();
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
    SupabaseBootstrapService.resetForTest();
  });

  group('registerChartServices', () {
    test(
      'registers direct, auth-aware, and offline-first chart services',
      () async {
        final _FakeCoingeckoApi api = _FakeCoingeckoApi();
        final _FakeChartCacheRepository cache = _FakeChartCacheRepository();

        getIt
          ..registerSingleton<CoingeckoApi>(api)
          ..registerSingleton<ChartCacheRepository>(cache)
          ..registerSingleton<SupabaseAuthRepository>(
            _FakeSupabaseAuthRepository(),
          );

        registerChartServices();

        expect(
          getIt<ChartRemoteRepository>(instanceName: 'directChartRemote'),
          isA<DirectChartRemoteRepository>(),
        );
        expect(
          getIt<ChartRemoteRepository>(),
          isA<AuthAwareChartRemoteRepository>(),
        );
        expect(getIt<ChartRepository>(), isA<OfflineFirstChartRepository>());

        final List<ChartPoint> points = await getIt<ChartRepository>()
            .fetchTrendingCounts();

        expect(api.requestCount, 1);
        expect(points, hasLength(2));
        expect(cache.lastWritten, points);
      },
    );

    test('keeps existing direct remote registration stable', () {
      final ChartRemoteRepository existingDirect = DirectChartRemoteRepository(
        api: _FakeCoingeckoApi(),
      );

      getIt
        ..registerSingleton<ChartRemoteRepository>(
          existingDirect,
          instanceName: 'directChartRemote',
        )
        ..registerSingleton<ChartCacheRepository>(_FakeChartCacheRepository())
        ..registerSingleton<CoingeckoApi>(_FakeCoingeckoApi())
        ..registerSingleton<SupabaseAuthRepository>(
          _FakeSupabaseAuthRepository(),
        );

      registerChartServices();

      expect(
        identical(
          getIt<ChartRemoteRepository>(instanceName: 'directChartRemote'),
          existingDirect,
        ),
        isTrue,
      );
    });
  });
}
