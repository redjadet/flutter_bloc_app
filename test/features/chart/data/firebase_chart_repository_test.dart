import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bloc_app/features/chart/data/firebase_chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Simulates token refresh failure after [waitForAuthUser] succeeds.
// ignore: must_be_immutable — extends firebase_auth_mocks [MockUser] (mutable test fake).
final class _MockUserFailingIdToken extends MockUser {
  _MockUserFailingIdToken() : super(uid: 'test-user');

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    throw FirebaseAuthException(
      code: 'user-token-expired',
      message: 'simulated',
    );
  }
}

/// [HttpsCallableResult] has no public constructor; this satisfies the read
/// the repository performs on [HttpsCallableResult.data].
final class _FakeHttpsCallableResult implements HttpsCallableResult<dynamic> {
  _FakeHttpsCallableResult(this._data);
  final dynamic _data;

  @override
  dynamic get data => _data;
}

final class _RecordingDirectChartRemote implements ChartRemoteRepository {
  _RecordingDirectChartRemote(this._points);
  final List<ChartPoint> _points;
  int callCount = 0;

  @override
  ChartDataSource get lastSource => ChartDataSource.remote;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    callCount += 1;
    return _points;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue('fallback');
  });

  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late MockFirebaseAuth auth;

  setUp(() {
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'test-user'),
    );
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('FirebaseChartRepository', () {
    test(
      'uses live direct before Firestore when cloud returns empty points',
      () async {
        final MockFirebaseFirestore firestore = MockFirebaseFirestore();
        final _RecordingDirectChartRemote direct = _RecordingDirectChartRemote(
          <ChartPoint>[ChartPoint(date: DateTime.utc(2025, 3, 15), value: 88)],
        );
        when(() => callable.call(any())).thenAnswer(
          (_) async => _FakeHttpsCallableResult(<String, dynamic>{
            'points': <dynamic>[],
          }),
        );

        final FirebaseChartRepository repository = FirebaseChartRepository(
          auth: auth,
          functions: functions,
          firestore: firestore,
          liveDirectFallback: direct,
        );

        final List<ChartPoint> points = await AppLogger.silenceAsync(
          () => repository.fetchTrendingCounts(),
        );

        expect(points, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 15), value: 88),
        ]);
        expect(repository.lastSource, ChartDataSource.remote);
        expect(direct.callCount, 1);
        verifyNever(() => firestore.doc(any()));
      },
    );

    test(
      'skips cloud and uses direct when getIdToken throws FirebaseAuthException',
      () async {
        final MockFirebaseFirestore firestore = MockFirebaseFirestore();
        final MockFirebaseAuth failingAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: _MockUserFailingIdToken(),
        );
        final _RecordingDirectChartRemote direct = _RecordingDirectChartRemote(
          <ChartPoint>[ChartPoint(date: DateTime.utc(2025, 6, 1), value: 77)],
        );

        final FirebaseChartRepository repository = FirebaseChartRepository(
          auth: failingAuth,
          functions: functions,
          firestore: firestore,
          liveDirectFallback: direct,
        );

        final List<ChartPoint> points = await AppLogger.silenceAsync(
          () => repository.fetchTrendingCounts(),
        );

        expect(points, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 6, 1), value: 77),
        ]);
        expect(repository.lastSource, ChartDataSource.remote);
        expect(direct.callCount, 1);
        verifyNever(() => functions.httpsCallable(any()));
        verifyNever(() => firestore.doc(any()));
      },
    );

    test(
      'falls back to Firestore when cloud and direct return no points',
      () async {
        final _RecordingDirectChartRemote direct = _RecordingDirectChartRemote(
          const <ChartPoint>[],
        );
        when(() => callable.call(any())).thenAnswer(
          (_) async => _FakeHttpsCallableResult(<String, dynamic>{
            'points': <dynamic>[],
          }),
        );

        final FirebaseChartRepository repository = FirebaseChartRepository(
          auth: auth,
          functions: functions,
          liveDirectFallback: direct,
          firestoreDocDataLoader: (final String path) async {
            expect(path, 'chart_trending/bitcoin_7d');
            return <String, dynamic>{
              'points': <dynamic>[
                <String, dynamic>{
                  'date_utc': '2025-03-01T00:00:00.000Z',
                  'value': 42.0,
                },
              ],
            };
          },
        );

        final List<ChartPoint> points = await AppLogger.silenceAsync(
          () => repository.fetchTrendingCounts(),
        );

        expect(points, <ChartPoint>[
          ChartPoint(date: DateTime.utc(2025, 3, 1), value: 42),
        ]);
        expect(repository.lastSource, ChartDataSource.firebaseFirestore);
        expect(direct.callCount, 1);
      },
    );

    test('does not call direct when cloud returns points', () async {
      final MockFirebaseFirestore firestore = MockFirebaseFirestore();
      final _RecordingDirectChartRemote direct = _RecordingDirectChartRemote(
        <ChartPoint>[ChartPoint(date: DateTime.utc(2025, 4, 1), value: 99)],
      );
      when(() => callable.call(any())).thenAnswer(
        (_) async => _FakeHttpsCallableResult(<String, dynamic>{
          'points': <dynamic>[
            <String, dynamic>{
              'date_utc': '2025-03-20T00:00:00.000Z',
              'value': 50.0,
            },
          ],
        }),
      );

      final FirebaseChartRepository repository = FirebaseChartRepository(
        auth: auth,
        functions: functions,
        firestore: firestore,
        liveDirectFallback: direct,
      );

      final List<ChartPoint> points = await AppLogger.silenceAsync(
        () => repository.fetchTrendingCounts(),
      );

      expect(points, <ChartPoint>[
        ChartPoint(date: DateTime.utc(2025, 3, 20), value: 50),
      ]);
      expect(repository.lastSource, ChartDataSource.firebaseCloud);
      expect(direct.callCount, 0);
      verifyNever(() => firestore.doc(any()));
    });
  });
}
