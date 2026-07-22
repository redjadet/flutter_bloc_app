import 'dart:async';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/firebase/realtime_database_guard.dart';
import 'package:flutter_bloc_app/app/firebase/run_with_auth_user.dart';
import 'package:flutter_bloc_app/app/firebase/stream_with_auth_user.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

/// Firebase Realtime Database backed implementation of [CounterRepository].
class RealtimeDatabaseCounterRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
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

  final DatabaseReference _counterRef;
  final FirebaseAuth _auth;

  @override
  Future<CounterSnapshot> load() async => _executeForUser<CounterSnapshot>(
    operation: 'load',
    action: (final user) async {
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseCounterRepository.load requesting counter value',
      );
      final DataSnapshot snapshot = await _counterRef.child(user.uid).get();
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseCounterRepository.load response exists: '
        '${snapshot.exists}',
      );
      return snapshotFromValue(snapshot.value, userId: user.uid);
    },
  );

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    await _executeForUser<void>(
      operation: 'save',
      action: (final user) async {
        AppLogger.debugInDebugMode(
          'RealtimeDatabaseCounterRepository.save writing counter value',
        );
        final Map<String, Object?> data = <String, Object?>{
          'userId': user.uid,
          'count': snapshot.count,
          'last_changed': snapshot.lastChanged?.millisecondsSinceEpoch,
        };
        await _setCounterWithPlatformErrorGuard(userId: user.uid, data: data);
      },
      onFailureFallback: () async {},
    );
  }

  @override
  Stream<CounterSnapshot> watch() => streamWithAuthUser<CounterSnapshot>(
    auth: _auth,
    logContext: IntegrationLogMessages.realtimeDatabaseCounterWatchLogContext,
    streamPerUser: (final user) => _counterRef
        .child(user.uid)
        .onValue
        .map(
          (final event) =>
              snapshotFromValue(event.snapshot.value, userId: user.uid),
        ),
  );

  @visibleForTesting
  static CounterSnapshot snapshotFromValue(
    final Object? value, {
    required final String userId,
    final bool logUnexpected = true,
  }) {
    return switch (value) {
      null => CounterSnapshot(userId: userId, count: 0),
      final num v => CounterSnapshot(userId: userId, count: v.toInt()),
      final Map<Object?, Object?> data => _snapshotFromMap(
        data,
        userId: userId,
      ),
      _ => _unexpectedSnapshotValue(
        value,
        userId: userId,
        logUnexpected: logUnexpected,
      ),
    };
  }

  static CounterSnapshot _snapshotFromMap(
    final Map<Object?, Object?> data, {
    required final String userId,
  }) {
    final Map<Object?, Object?> map = Map<Object?, Object?>.from(data);
    final int count = intFromDynamic(map['count']) ?? 0;
    final int? lastChangedMs = intFromDynamic(map['last_changed']);
    final DateTime? lastChanged = lastChangedMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastChangedMs)
        : null;
    final String snapshotId =
        stringFromDynamicTrimmed(map['userId']) ??
        stringFromDynamicTrimmed(map['id']) ??
        userId;
    return CounterSnapshot(
      userId: snapshotId,
      count: count,
      lastChanged: lastChanged,
    );
  }

  static CounterSnapshot _unexpectedSnapshotValue(
    final Object? value, {
    required final String userId,
    required final bool logUnexpected,
  }) {
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
    final Future<T> Function()? onFailureFallback,
  }) => runWithAuthUser<T>(
    auth: _auth,
    logContext: 'RealtimeDatabaseCounterRepository.$operation',
    action: action,
    onFailureFallback: onFailureFallback,
  );

  Future<void> _setCounterWithPlatformErrorGuard({
    required final String userId,
    required final Map<String, Object?> data,
  }) async {
    await guardRealtimeDatabaseWrite(
      () => _counterRef.child(userId).set(data),
      message:
          'Realtime Database write failed while saving counter. '
          'Check database rules and auth state.',
    );
  }
}
