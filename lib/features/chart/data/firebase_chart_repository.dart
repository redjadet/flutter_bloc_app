import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_live_direct_fallback.dart';
import 'package:flutter_bloc_app/features/chart/data/chart_points_parser.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:meta/meta.dart';

class FirebaseChartRepository implements ChartRemoteRepository {
  FirebaseChartRepository({
    final FirebaseAuth? auth,
    final FirebaseFunctions? functions,
    final FirebaseFirestore? firestore,
    final ChartRemoteRepository? liveDirectFallback,

    /// When non-null, skips real [FirebaseFirestore] reads (for tests only).
    /// Do not inject this from production DI.
    @visibleForTesting
    final Future<Map<String, dynamic>?> Function(String docPath)?
    firestoreDocDataLoader,
  }) : _auth = auth,
       _functions = functions,
       _firestore = firestore,
       _liveDirectFallback = liveDirectFallback,
       _firestoreDocDataLoader = firestoreDocDataLoader;

  static const String _region = 'us-central1';
  static const String _callableName = 'syncChartTrending';
  static const String _firestoreDocPath = 'chart_trending/bitcoin_7d';

  final FirebaseAuth? _auth;
  final FirebaseFunctions? _functions;
  final FirebaseFirestore? _firestore;
  final ChartRemoteRepository? _liveDirectFallback;
  final Future<Map<String, dynamic>?> Function(String docPath)?
  _firestoreDocDataLoader;

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

  ChartDataSource _lastSource = ChartDataSource.unknown;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async {
    final existing = _inFlightFetch;
    if (existing != null) return existing;

    final auth = _safeAuth;
    if (auth == null) {
      _lastSource = ChartDataSource.unknown;
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
    late final _FirebaseChartFetchAttempt cloudAttempt;
    try {
      final user = await waitForAuthUser(auth);
      // Ensure Functions gets a fresh ID token attached to the request.
      await user.getIdToken(true);
      cloudAttempt = await _tryFetchFromCloud();
    } on FirebaseAuthException catch (e, _) {
      // Do not return [] here: that looks like success to auth-aware callers.
      // Skip cloud and still try direct HTTP + Firestore (same as empty cloud).
      AppLogger.info(
        'FirebaseChartRepository auth/token failed (${e.code}); '
        'skipping cloud, trying direct and Firestore',
      );
      _lastSource = ChartDataSource.unknown;
      cloudAttempt = const _FirebaseChartFetchAttempt(
        failure: _FirebaseChartFetchFailure(
          label: 'firebase_auth_not_ready',
          logStackTrace: false,
        ),
      );
    }
    if (cloudAttempt.points.isNotEmpty) {
      _lastSource = ChartDataSource.firebaseCloud;
      return cloudAttempt.points;
    }

    final List<ChartPoint>? liveDirect = await tryLiveDirectChartPoints(
      fallback: _liveDirectFallback,
      guardAgainstIdenticalTo: this,
      loggerTag: 'FirebaseChartRepository',
      successDebugDetail: _directFallbackDebugMessage(cloudAttempt),
    );
    if (liveDirect != null) {
      _lastSource = ChartDataSource.remote;
      return liveDirect;
    }

    final _FirebaseChartFetchAttempt firestoreAttempt =
        await _tryFetchFromFirestore();
    if (firestoreAttempt.points.isNotEmpty) {
      final _FirebaseChartFetchFailure? cloudFailure = cloudAttempt.failure;
      if (cloudFailure != null) {
        AppLogger.debug(
          'FirebaseChartRepository firestore after cloud failure '
          '(${cloudFailure.label})',
        );
      } else if (_liveDirectFallback != null) {
        AppLogger.debug(
          'FirebaseChartRepository firestore after empty cloud/direct',
        );
      }
      _lastSource = ChartDataSource.firebaseFirestore;
      return firestoreAttempt.points;
    }

    _logAttemptFailure(
      context: 'FirebaseChartRepository cloud',
      failure: cloudAttempt.failure,
    );
    _logAttemptFailure(
      context: 'FirebaseChartRepository firestore',
      failure: firestoreAttempt.failure,
    );
    _lastSource = ChartDataSource.unknown;
    throw ChartDataException('Failed to load chart data from Firebase');
  }

  static String _directFallbackDebugMessage(
    final _FirebaseChartFetchAttempt cloud,
  ) {
    final _FirebaseChartFetchFailure? failure = cloud.failure;
    return failure != null
        ? 'using direct CoinGecko after cloud failure (${failure.label})'
        : 'using direct CoinGecko after empty cloud response';
  }

  Future<_FirebaseChartFetchAttempt> _tryFetchFromCloud() async {
    try {
      final functions = _safeFunctions;
      if (functions == null) {
        return const _FirebaseChartFetchAttempt(
          failure: _FirebaseChartFetchFailure(
            label: 'functions unavailable',
          ),
        );
      }
      final callable = functions.httpsCallable(_callableName);
      final HttpsCallableResult<dynamic> result = await callable.call(
        <String, dynamic>{},
      );
      final Map<String, dynamic>? json = mapFromDynamic(result.data);
      final List<dynamic>? raw = listFromDynamic(json?['points']);
      if (raw == null || raw.isEmpty) {
        return const _FirebaseChartFetchAttempt();
      }
      return _FirebaseChartFetchAttempt(points: parseChartPointsResilient(raw));
    } on FirebaseFunctionsException catch (e, _) {
      if (e.code == 'unauthenticated') {
        final auth = _safeAuth;
        final uid = auth?.currentUser?.uid;
        AppLogger.info(
          'FirebaseChartRepository cloud skipped (unauthenticated): '
          'uid=${uid ?? '(none)'}',
        );
        return const _FirebaseChartFetchAttempt();
      }
      return _FirebaseChartFetchAttempt(
        failure: _FirebaseChartFetchFailure(
          label: e.code,
          error: e,
          logStackTrace: false,
        ),
      );
    } on Object catch (error, _) {
      return _FirebaseChartFetchAttempt(
        failure: _FirebaseChartFetchFailure(
          label: error.runtimeType.toString(),
          error: error,
          logStackTrace: false,
        ),
      );
    }
  }

  Future<_FirebaseChartFetchAttempt> _tryFetchFromFirestore() async {
    try {
      final Map<String, dynamic>? data;
      final loader = _firestoreDocDataLoader;
      if (loader != null) {
        data = await loader(_firestoreDocPath);
      } else {
        final firestore = _safeFirestore;
        if (firestore == null) {
          return const _FirebaseChartFetchAttempt(
            failure: _FirebaseChartFetchFailure(
              label: 'firestore unavailable',
            ),
          );
        }
        final DocumentSnapshot<Map<String, dynamic>> snap = await firestore
            .doc(_firestoreDocPath)
            .get();
        data = snap.data();
      }
      final List<dynamic>? raw = listFromDynamic(data?['points']);
      if (raw == null || raw.isEmpty) {
        return const _FirebaseChartFetchAttempt();
      }
      return _FirebaseChartFetchAttempt(points: parseChartPointsResilient(raw));
    } on FirebaseException catch (e, stackTrace) {
      return _FirebaseChartFetchAttempt(
        failure: _FirebaseChartFetchFailure(
          label: e.code,
          error: e,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      return _FirebaseChartFetchAttempt(
        failure: _FirebaseChartFetchFailure(
          label: error.runtimeType.toString(),
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void _logAttemptFailure({
    required final String context,
    required final _FirebaseChartFetchFailure? failure,
  }) {
    if (failure == null) {
      return;
    }
    AppLogger.warning('$context failed (${failure.label})');
    if (failure.error != null) {
      AppLogger.error(
        context,
        failure.error,
        failure.logStackTrace ? failure.stackTrace : null,
      );
    }
  }
}

final class _FirebaseChartFetchAttempt {
  const _FirebaseChartFetchAttempt({
    this.points = const <ChartPoint>[],
    this.failure,
  });

  final List<ChartPoint> points;
  final _FirebaseChartFetchFailure? failure;
}

final class _FirebaseChartFetchFailure {
  const _FirebaseChartFetchFailure({
    required this.label,
    this.error,
    this.stackTrace,
    this.logStackTrace = true,
  });

  final String label;
  final Object? error;
  final StackTrace? stackTrace;
  final bool logStackTrace;
}
