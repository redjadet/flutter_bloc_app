import 'dart:async';

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

    test('sets lastSource to unknown when active delegate throws', () async {
      supabaseSignedIn = true;
      when(() => supabase.fetchTrendingCounts()).thenThrow(StateError('boom'));

      await expectLater(repo.fetchTrendingCounts(), throwsStateError);
      expect(repo.lastSource, ChartDataSource.unknown);
    });

    test(
      'coalesces concurrent fetchTrendingCounts for the same active delegate',
      () async {
        supabaseSignedIn = true;
        var delegateCalls = 0;
        final Completer<List<ChartPoint>> completer =
            Completer<List<ChartPoint>>();
        when(
          () => supabase.lastSource,
        ).thenReturn(ChartDataSource.supabaseEdge);
        when(() => supabase.fetchTrendingCounts()).thenAnswer((_) async {
          delegateCalls += 1;
          return completer.future;
        });

        final Future<List<ChartPoint>> a = repo.fetchTrendingCounts();
        final Future<List<ChartPoint>> b = repo.fetchTrendingCounts();

        expect(
          delegateCalls,
          1,
          reason: 'second caller should join first in-flight future',
        );

        completer.complete(<ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 1, 2), value: 5),
        ]);

        expect(await a, await b);
        expect(repo.lastSource, ChartDataSource.supabaseEdge);
        verify(() => supabase.fetchTrendingCounts()).called(1);
      },
    );

    test(
      'does not share in-flight work when active delegate changes mid-flight',
      () async {
        final Completer<List<ChartPoint>> directWait =
            Completer<List<ChartPoint>>();
        final Completer<List<ChartPoint>> supabaseWait =
            Completer<List<ChartPoint>>();

        when(() => direct.lastSource).thenReturn(ChartDataSource.remote);
        when(
          () => supabase.lastSource,
        ).thenReturn(ChartDataSource.supabaseEdge);
        when(() => direct.fetchTrendingCounts()).thenAnswer((_) {
          return directWait.future;
        });
        when(() => supabase.fetchTrendingCounts()).thenAnswer((_) {
          return supabaseWait.future;
        });

        supabaseSignedIn = false;
        final Future<List<ChartPoint>> fromDirect = repo.fetchTrendingCounts();

        await Future<void>.value();

        supabaseSignedIn = true;
        final Future<List<ChartPoint>> fromSupabase = repo
            .fetchTrendingCounts();

        verify(() => direct.fetchTrendingCounts()).called(1);
        verify(() => supabase.fetchTrendingCounts()).called(1);

        directWait.complete(<ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 1), value: 1),
        ]);
        supabaseWait.complete(<ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 2), value: 2),
        ]);

        expect(await fromDirect, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 1), value: 1),
        ]);
        expect(await fromSupabase, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 2), value: 2),
        ]);
      },
    );
  });
}
