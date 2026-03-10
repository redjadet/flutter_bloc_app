import 'package:flutter_bloc_app/features/chart/data/auth_aware_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ChartRemoteRepository {}

void main() {
  group('AuthAwareChartRemoteRepository', () {
    late _MockRemote supabase;
    late _MockRemote direct;
    late bool signedIn;
    late AuthAwareChartRemoteRepository repo;

    setUp(() {
      supabase = _MockRemote();
      direct = _MockRemote();
      signedIn = false;
      repo = AuthAwareChartRemoteRepository(
        supabaseRemote: supabase,
        directRemote: direct,
        isSupabaseSignedIn: () => signedIn,
      );
    });

    test('delegates to direct remote when not signed in', () async {
      when(() => direct.lastSource).thenReturn(ChartDataSource.remote);
      when(
        () => direct.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);

      expect(repo.lastSource, ChartDataSource.unknown);
      await repo.fetchTrendingCounts();
      expect(repo.lastSource, ChartDataSource.remote);

      verify(() => direct.fetchTrendingCounts()).called(1);
      verifyNever(() => supabase.fetchTrendingCounts());
    });

    test('delegates to supabase remote when signed in', () async {
      signedIn = true;
      when(
        () => supabase.lastSource,
      ).thenReturn(ChartDataSource.supabaseTables);
      when(
        () => supabase.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);

      expect(repo.lastSource, ChartDataSource.unknown);
      await repo.fetchTrendingCounts();
      expect(repo.lastSource, ChartDataSource.supabaseTables);

      verify(() => supabase.fetchTrendingCounts()).called(1);
      verifyNever(() => direct.fetchTrendingCounts());
    });

    test('switches delegate dynamically across calls', () async {
      when(() => direct.lastSource).thenReturn(ChartDataSource.remote);
      when(() => supabase.lastSource).thenReturn(ChartDataSource.supabaseEdge);
      when(
        () => direct.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);
      when(
        () => supabase.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);

      signedIn = false;
      await repo.fetchTrendingCounts();
      signedIn = true;
      await repo.fetchTrendingCounts();

      verify(() => direct.fetchTrendingCounts()).called(1);
      verify(() => supabase.fetchTrendingCounts()).called(1);
    });
  });
}
