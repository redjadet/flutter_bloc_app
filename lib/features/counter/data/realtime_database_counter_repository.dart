import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Firebase Realtime Database backed implementation of [CounterRepository].
class RealtimeDatabaseCounterRepository implements CounterRepository {
  RealtimeDatabaseCounterRepository({
    final FirebaseDatabase? database,
    final DatabaseReference? counterRef,
    final FirebaseAuth? auth,
    final String counterPath = _defaultCounterPath,
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
  Future<CounterSnapshot> load() async => _executeForUser<CounterSnapshot>(
    operation: 'load',
    action: (final User user) async {
      _debugLog(
        'RealtimeDatabaseCounterRepository.load requesting counter value',
      );
      final DataSnapshot snapshot = await _counterRef.child(user.uid).get();
      _debugLog(
        'RealtimeDatabaseCounterRepository.load response exists: '
        '${snapshot.exists}',
      );
      return snapshotFromValue(snapshot.value, userId: user.uid);
    },
    onFailureFallback: () async {
      final String? userId = _auth.currentUser?.uid;
      return _emptySnapshot.copyWith(userId: userId);
    },
  );

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    await _executeForUser<void>(
      operation: 'save',
      action: (final User user) async {
        _debugLog(
          'RealtimeDatabaseCounterRepository.save writing counter value',
        );
        await _counterRef.child(user.uid).set(<String, Object?>{
          'userId': user.uid,
          'count': snapshot.count,
          'last_changed': snapshot.lastChanged?.millisecondsSinceEpoch,
        });
      },
      onFailureFallback: () async {},
    );
  }

  @override
  Stream<CounterSnapshot> watch() => Stream.fromFuture(waitForAuthUser(_auth))
      .asyncExpand(
        (final User user) => _counterRef
            .child(user.uid)
            .onValue
            .map(
              (final DatabaseEvent event) =>
                  snapshotFromValue(event.snapshot.value, userId: user.uid),
            ),
      )
      .handleError((final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'RealtimeDatabaseCounterRepository.watch failed',
          error,
          stackTrace,
        );
      });

  @visibleForTesting
  static CounterSnapshot snapshotFromValue(
    final Object? value, {
    required final String userId,
    final bool logUnexpected = true,
  }) {
    if (value == null) {
      return CounterSnapshot(userId: userId, count: 0);
    }

    if (value is num) {
      return CounterSnapshot(userId: userId, count: value.toInt());
    }

    if (value is Map) {
      final Map<Object?, Object?> data = Map<Object?, Object?>.from(value);
      final int count = (data['count'] as num?)?.toInt() ?? 0;
      final int? lastChangedMs = (data['last_changed'] as num?)?.toInt();
      final DateTime? lastChanged = lastChangedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastChangedMs)
          : null;
      final String snapshotId =
          (data['userId'] as String?) ?? (data['id'] as String?) ?? userId;
      return CounterSnapshot(
        userId: snapshotId,
        count: count,
        lastChanged: lastChanged,
      );
    }

    if (logUnexpected) {
      AppLogger.warning(
        'RealtimeDatabaseCounterRepository.load unexpected payload type: '
        '${value.runtimeType}',
      );
    }
    return CounterSnapshot(userId: userId, count: 0);
  }

  Future<T> _executeForUser<T>({
    required final String operation,
    required final Future<T> Function(User user) action,
    Future<T> Function()? onFailureFallback,
  }) async {
    try {
      final User user = await waitForAuthUser(_auth);
      return await action(user);
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeDatabaseCounterRepository.$operation failed',
        error,
        stackTrace,
      );
      if (onFailureFallback != null) {
        return onFailureFallback();
      }
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeDatabaseCounterRepository.$operation failed',
        error,
        stackTrace,
      );
      if (onFailureFallback != null) {
        return onFailureFallback();
      }
      rethrow;
    }
  }
}

void _debugLog(final String message) {
  if (kDebugMode) {
    AppLogger.debug(message);
  }
}

@visibleForTesting
Future<User> waitForAuthUser(
  final FirebaseAuth auth, {
  final Duration timeout = RealtimeDatabaseCounterRepository._authWaitTimeout,
}) async {
  final User? current = auth.currentUser;
  if (current != null) {
    return current;
  }

  try {
    return await auth
        .authStateChanges()
        .where((final User? user) => user != null)
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
