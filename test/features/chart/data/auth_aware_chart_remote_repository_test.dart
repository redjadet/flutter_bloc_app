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
    late _MockRemote firebase;
    late _MockRemote direct;
    late bool supabaseSignedIn;
    late bool firebaseSignedIn;
    late AuthAwareChartRemoteRepository repo;

    setUp(() {
      supabase = _MockRemote();
      firebase = _MockRemote();
      direct = _MockRemote();
      supabaseSignedIn = false;
      firebaseSignedIn = false;
      repo = AuthAwareChartRemoteRepository(
        supabaseRemote: supabase,
        firebaseRemote: firebase,
        directRemote: direct,
        isSupabaseSignedIn: () => supabaseSignedIn,
        isFirebaseSignedIn: () => firebaseSignedIn,
      );
    });

    test('delegates to direct remote when neither is signed in', () async {
      when(() => direct.lastSource).thenReturn(ChartDataSource.remote);
      when(
        () => direct.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);

      expect(repo.lastSource, ChartDataSource.unknown);
      await repo.fetchTrendingCounts();
      expect(repo.lastSource, ChartDataSource.remote);

      verify(() => direct.fetchTrendingCounts()).called(1);
      verifyNever(() => supabase.fetchTrendingCounts());
      verifyNever(() => firebase.fetchTrendingCounts());
    });

    test('delegates to supabase remote when signed in', () async {
      supabaseSignedIn = true;
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
      verifyNever(() => firebase.fetchTrendingCounts());
    });

    test(
      'delegates to firebase remote when firebase signed in (supabase not)',
      () async {
        firebaseSignedIn = true;
        when(
          () => firebase.lastSource,
        ).thenReturn(ChartDataSource.firebaseCloud);
        when(
          () => firebase.fetchTrendingCounts(),
        ).thenAnswer((_) async => const <ChartPoint>[]);

        expect(repo.lastSource, ChartDataSource.unknown);
        await repo.fetchTrendingCounts();
        expect(repo.lastSource, ChartDataSource.firebaseCloud);

        verify(() => firebase.fetchTrendingCounts()).called(1);
        verifyNever(() => supabase.fetchTrendingCounts());
        verifyNever(() => direct.fetchTrendingCounts());
      },
    );

    test('prefers supabase over firebase when both signed in', () async {
      supabaseSignedIn = true;
      firebaseSignedIn = true;
      when(() => supabase.lastSource).thenReturn(ChartDataSource.supabaseEdge);
      when(
        () => supabase.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);

      await repo.fetchTrendingCounts();
      expect(repo.lastSource, ChartDataSource.supabaseEdge);

      verify(() => supabase.fetchTrendingCounts()).called(1);
      verifyNever(() => firebase.fetchTrendingCounts());
      verifyNever(() => direct.fetchTrendingCounts());
    });

    test('switches delegate dynamically across calls', () async {
      when(() => direct.lastSource).thenReturn(ChartDataSource.remote);
      when(() => supabase.lastSource).thenReturn(ChartDataSource.supabaseEdge);
      when(
        () => firebase.lastSource,
      ).thenReturn(ChartDataSource.firebaseFirestore);
      when(
        () => direct.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);
      when(
        () => supabase.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);
      when(
        () => firebase.fetchTrendingCounts(),
      ).thenAnswer((_) async => const <ChartPoint>[]);

      supabaseSignedIn = false;
      firebaseSignedIn = false;
      await repo.fetchTrendingCounts();
      firebaseSignedIn = true;
      await repo.fetchTrendingCounts();
      supabaseSignedIn = true;
      await repo.fetchTrendingCounts();

      verify(() => direct.fetchTrendingCounts()).called(1);
      verify(() => firebase.fetchTrendingCounts()).called(1);
      verify(() => supabase.fetchTrendingCounts()).called(1);
    });
  });
}
