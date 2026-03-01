import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/firebase/run_with_auth_user.dart';
import 'package:flutter_bloc_app/shared/firebase/stream_with_auth_user.dart';
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
    onFailureFallback: () async {
      final String? userId = _auth.currentUser?.uid;
      return _emptySnapshot.copyWith(userId: userId);
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
    logContext: 'RealtimeDatabaseCounterRepository.watch',
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
    if (value == null) {
      return CounterSnapshot(userId: userId, count: 0);
    }

    if (value is num) {
      return CounterSnapshot(userId: userId, count: value.toInt());
    }

    if (value is Map) {
      final Map<Object?, Object?> data = Map<Object?, Object?>.from(value);
      final int count = _intFromSnapshotValue(data['count']) ?? 0;
      final int? lastChangedMs = _intFromSnapshotValue(data['last_changed']);
      final DateTime? lastChanged = lastChangedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastChangedMs)
          : null;
      final String snapshotId =
          _stringFromSnapshotValue(data['userId']) ??
          _stringFromSnapshotValue(data['id']) ??
          userId;
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

  static String? _stringFromSnapshotValue(final Object? value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _intFromSnapshotValue(final Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
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
    try {
      await _counterRef.child(userId).set(data);
    } catch (error, stackTrace) {
      if (error is TypeError) {
        final String errorMessage = error.toString();
        final bool isFlutterFireDetailsCastIssue = errorMessage.contains(
          "'String' is not a subtype of type 'Map",
        );
        if (isFlutterFireDetailsCastIssue) {
          Error.throwWithStackTrace(
            FirebaseException(
              plugin: 'firebase_database',
              code: 'database-platform-error-details',
              message:
                  'Realtime Database write failed while saving counter. '
                  'Check database rules and auth state.',
            ),
            stackTrace,
          );
        }
      }
      rethrow;
    }
  }
}
