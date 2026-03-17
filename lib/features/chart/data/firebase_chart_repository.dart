import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_points_parser.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

class FirebaseChartRepository implements ChartRemoteRepository {
  FirebaseChartRepository({
    final FirebaseAuth? auth,
    final FirebaseFunctions? functions,
    final FirebaseFirestore? firestore,
  }) : _auth = auth,
       _functions = functions,
       _firestore = firestore;

  static const String _region = 'us-central1';
  static const String _callableName = 'syncChartTrending';
  static const String _firestoreDocPath = 'chart_trending/bitcoin_7d';

  final FirebaseAuth? _auth;
  final FirebaseFunctions? _functions;
  final FirebaseFirestore? _firestore;

  Future<List<ChartPoint>>? _inFlightFetch;

  FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  FirebaseFunctions? get _safeFunctions {
    if (_functions != null) return _functions;
    try {
      return FirebaseFunctions.instanceFor(region: _region);
    } on Object {
      return null;
    }
  }

  FirebaseFirestore? get _safeFirestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  bool get hasSignedInUser => _safeAuth?.currentUser != null;

  @override
  ChartDataSource get lastSource => _lastSource;

  ChartDataSource _lastSource = ChartDataSource.firebaseFirestore;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final existing = _inFlightFetch;
    if (existing != null) return existing;

    final auth = _safeAuth;
    if (auth == null) {
      throw ChartDataException('Firebase user must be signed in');
    }

    final future = _fetchTrendingCountsInternal(auth);
    _inFlightFetch = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightFetch, future)) {
        _inFlightFetch = null;
      }
    }
  }

  Future<List<ChartPoint>> _fetchTrendingCountsInternal(
    final FirebaseAuth auth,
  ) async {
    // Ensure FirebaseAuth had a chance to hydrate the current user before we
    // call the authenticated Cloud Function.
    try {
      final user = await waitForAuthUser(auth);
      // Ensure Functions gets a fresh ID token attached to the request.
      await user.getIdToken(true);
    } on FirebaseAuthException {
      // If auth isn't ready, we treat Firebase as unavailable and allow the
      // overall 3-way routing to fall through (via empty result here).
      return const <ChartPoint>[];
    }

    final List<ChartPoint> fromCloud = await _tryFetchFromCloud();
    if (fromCloud.isNotEmpty) {
      _lastSource = ChartDataSource.firebaseCloud;
      return fromCloud;
    }

    final List<ChartPoint> fromFirestore = await _tryFetchFromFirestore();
    if (fromFirestore.isNotEmpty) {
      _lastSource = ChartDataSource.firebaseFirestore;
      return fromFirestore;
    }

    throw ChartDataException('Failed to load chart data from Firebase');
  }

  Future<List<ChartPoint>> _tryFetchFromCloud() async {
    try {
      final functions = _safeFunctions;
      if (functions == null) return const <ChartPoint>[];
      final callable = functions.httpsCallable(_callableName);
      final HttpsCallableResult<dynamic> result = await callable.call(
        <String, dynamic>{},
      );
      final Map<String, dynamic>? json = mapFromDynamic(result.data);
      final List<dynamic>? raw = listFromDynamic(json?['points']);
      if (raw == null || raw.isEmpty) return const <ChartPoint>[];
      return parseChartPointsResilient(raw);
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (e.code == 'unauthenticated') {
        final auth = _safeAuth;
        final uid = auth?.currentUser?.uid;
        String? tokenPreview;
        try {
          final token = await auth?.currentUser?.getIdToken();
          if (token != null && token.isNotEmpty) {
            final n = token.length < 10 ? token.length : 10;
            tokenPreview = '${token.substring(0, n)}…';
          }
        } on Object catch (_) {
          tokenPreview = null;
        }
        AppLogger.info(
          'FirebaseChartRepository cloud skipped (unauthenticated): '
          'uid=${uid ?? '(none)'}, '
          'idToken=${tokenPreview ?? '(unavailable)'}',
        );
        return const <ChartPoint>[];
      }
      AppLogger.warning('FirebaseChartRepository cloud failed (${e.code})');
      AppLogger.error(
        'FirebaseChartRepository._tryFetchFromCloud',
        e,
        stackTrace,
      );
      return const <ChartPoint>[];
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'FirebaseChartRepository cloud failed (${error.runtimeType})',
      );
      AppLogger.error(
        'FirebaseChartRepository._tryFetchFromCloud',
        error,
        stackTrace,
      );
      return const <ChartPoint>[];
    }
  }

  Future<List<ChartPoint>> _tryFetchFromFirestore() async {
    try {
      final firestore = _safeFirestore;
      if (firestore == null) return const <ChartPoint>[];
      final DocumentSnapshot<Map<String, dynamic>> snap = await firestore
          .doc(_firestoreDocPath)
          .get();
      final data = snap.data();
      final List<dynamic>? raw = listFromDynamic(data?['points']);
      if (raw == null || raw.isEmpty) return const <ChartPoint>[];
      return parseChartPointsResilient(raw);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.warning(
        'FirebaseChartRepository firestore failed (${e.code})',
      );
      AppLogger.error(
        'FirebaseChartRepository._tryFetchFromFirestore',
        e,
        stackTrace,
      );
      return const <ChartPoint>[];
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'FirebaseChartRepository firestore failed (${error.runtimeType})',
      );
      AppLogger.error(
        'FirebaseChartRepository._tryFetchFromFirestore',
        error,
        stackTrace,
      );
      return const <ChartPoint>[];
    }
  }
}
