import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:meta/meta.dart';

/// Firebase Realtime Database backed implementation of [CounterRepository].
class RealtimeDatabaseCounterRepository implements CounterRepository {
  RealtimeDatabaseCounterRepository({
    FirebaseDatabase? database,
    DatabaseReference? counterRef,
    FirebaseAuth? auth,
    String counterPath = _defaultCounterPath,
  }) : _counterRef =
           counterRef ??
           (database ?? FirebaseDatabase.instance).ref(counterPath),
       _auth = auth ?? FirebaseAuth.instance;

  static const String _defaultCounterPath = 'counter';
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(count: 0);
  static const Duration _authWaitTimeout = Duration(seconds: 5);

  final DatabaseReference _counterRef;
  final FirebaseAuth _auth;

  @override
  Future<CounterSnapshot> load() async {
    try {
      final User user = await waitForAuthUser(_auth);
      AppLogger.debug(
        'RealtimeDatabaseCounterRepository.load requesting path: '
        '${_counterRef.path}',
      );
      AppLogger.debug(
        'RealtimeDatabaseCounterRepository.load auth payload: '
        '{uid: ${user.uid}, providerData: ${user.providerData.map((item) => item.providerId).toList()}, '
        'isAnonymous: ${user.isAnonymous}, email: ${user.email}}',
      );
      final DataSnapshot snapshot = await _counterRef.get();
      AppLogger.debug(
        'RealtimeDatabaseCounterRepository.load response exists: '
        '${snapshot.exists}',
      );
      AppLogger.debug(
        'RealtimeDatabaseCounterRepository.load raw value: '
        '${snapshot.value}',
      );
      return snapshotFromValue(snapshot.value);
    } on FirebaseAuthException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeDatabaseCounterRepository.load failed',
        error,
        stackTrace,
      );
      return _emptySnapshot;
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    try {
      final User user = await waitForAuthUser(_auth);
      AppLogger.debug(
        'RealtimeDatabaseCounterRepository.save writing to: '
        '${_counterRef.path} => ${snapshot.toJson()}',
      );
      AppLogger.debug(
        'RealtimeDatabaseCounterRepository.save auth payload: '
        '{uid: ${user.uid}, providerData: ${user.providerData.map((item) => item.providerId).toList()}, '
        'isAnonymous: ${user.isAnonymous}, email: ${user.email}}',
      );
      await _counterRef.set(<String, Object?>{
        'count': snapshot.count,
        'last_changed': snapshot.lastChanged?.millisecondsSinceEpoch,
      });
    } on FirebaseAuthException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeDatabaseCounterRepository.save failed',
        error,
        stackTrace,
      );
    }
  }

  @visibleForTesting
  static CounterSnapshot snapshotFromValue(
    Object? value, {
    bool logUnexpected = true,
  }) {
    if (value == null) {
      return _emptySnapshot;
    }

    if (value is num) {
      return CounterSnapshot(count: value.toInt());
    }

    if (value is Map) {
      final Map<Object?, Object?> data = Map<Object?, Object?>.from(value);
      final int count = (data['count'] as num?)?.toInt() ?? 0;
      final int? lastChangedMs = (data['last_changed'] as num?)?.toInt();
      final DateTime? lastChanged = lastChangedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastChangedMs)
          : null;
      return CounterSnapshot(count: count, lastChanged: lastChanged);
    }

    if (logUnexpected) {
      AppLogger.warning(
        'RealtimeDatabaseCounterRepository.load unexpected payload: $value',
      );
    }
    return _emptySnapshot;
  }
}

@visibleForTesting
Future<User> waitForAuthUser(
  FirebaseAuth auth, {
  Duration timeout = RealtimeDatabaseCounterRepository._authWaitTimeout,
}) async {
  final User? current = auth.currentUser;
  if (current != null) {
    return current;
  }

  try {
    return await auth
        .authStateChanges()
        .where((User? user) => user != null)
        .cast<User>()
        .first
        .timeout(timeout);
  } on TimeoutException {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message:
          'FirebaseAuth did not supply a user within ${timeout.inMilliseconds}ms.',
    );
  }
}
