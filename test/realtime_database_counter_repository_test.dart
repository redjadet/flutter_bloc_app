import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('RealtimeDatabaseCounterRepository.snapshotFromValue', () {
    test('returns empty snapshot when value is null', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(
            null,
            userId: 'user-1',
          );

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'user-1');
    });

    test('parses map payload with count and timestamp', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(42);
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'userId': 'user-2',
            'count': 5,
            'last_changed': expected.millisecondsSinceEpoch,
          }, userId: 'ignored');

      expect(result.count, 5);
      expect(result.lastChanged, expected);
      expect(result.userId, 'user-2');
    });

    test('parses count and last_changed when sent as strings', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'userId': 'u-s',
            'count': ' 8 ',
            'last_changed': ' 1710000000000 ',
          }, userId: 'fallback');

      expect(result.count, 8);
      expect(result.userId, 'u-s');
      expect(result.lastChanged, isNotNull);
      expect(result.lastChanged!.millisecondsSinceEpoch, 1710000000000);
    });

    test('defaults missing fields to safe values', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'count': null,
            'last_changed': null,
          }, userId: 'user-3');

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'user-3');
    });

    test('falls back to path userId when payload userId/id are malformed', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(<String, Object?>{
            'userId': 42,
            'id': <String, Object?>{'nested': true},
            'count': 9,
          }, userId: 'user-from-path');

      expect(result.count, 9);
      expect(result.userId, 'user-from-path');
    });

    test('parses numeric payload into snapshot', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(
            7,
            userId: 'user-4',
          );

      expect(result.count, 7);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'user-4');
    });

    test('returns empty snapshot for unsupported payload', () {
      final CounterSnapshot result =
          RealtimeDatabaseCounterRepository.snapshotFromValue(
            'unexpected',
            userId: 'test-user',
            logUnexpected: false,
          );

      expect(result.count, 0);
      expect(result.lastChanged, isNull);
      expect(result.userId, 'test-user');
    });
  });

  group('waitForAuthUser', () {
    test('returns current user immediately when already signed in', () async {
      final MockUser mockUser = MockUser(uid: 'user-123');
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: mockUser,
      );

      final User user = await waitForAuthUser(auth);
      expect(user.uid, mockUser.uid);
    });

    test('awaits authStateChanges when current user is null', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth();

      Future<void>.delayed(const Duration(milliseconds: 10)).then((_) {
        auth.signInAnonymously();
      });

      final User user = await waitForAuthUser(
        auth,
        timeout: const Duration(seconds: 1),
      );
      expect(user.isAnonymous, isTrue);
    });

    test('throws when no user arrives before timeout', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth();

      await expectLater(
        waitForAuthUser(auth, timeout: const Duration(milliseconds: 20)),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('RealtimeDatabaseCounterRepository', () {
    test('load returns parsed snapshot from database', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('counter');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(
        () => snapshot.value,
      ).thenReturn(<String, Object?>{'count': 9, 'last_changed': 10});

      final RealtimeDatabaseCounterRepository repository =
          RealtimeDatabaseCounterRepository(counterRef: rootRef, auth: auth);

      final CounterSnapshot result = await AppLogger.silenceAsync(() {
        return repository.load();
      });

      expect(result.userId, 'user-123');
      expect(result.count, 9);
      expect(result.lastChanged, isNotNull);
    });

    test('load falls back to empty snapshot on firebase exception', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-456'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();

      when(() => rootRef.path).thenReturn('counter');
      when(() => rootRef.child('user-456')).thenReturn(userRef);
      when(
        () => userRef.get(),
      ).thenThrow(FirebaseException(plugin: 'database', message: 'boom'));

      final RealtimeDatabaseCounterRepository repository =
          RealtimeDatabaseCounterRepository(counterRef: rootRef, auth: auth);

      final CounterSnapshot result = await AppLogger.silenceAsync(() {
        return repository.load();
      });

      expect(result.userId, 'user-456');
      expect(result.count, 0);
    });

    test('save writes normalized snapshot to database', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-789'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();

      when(() => rootRef.path).thenReturn('counter');
      when(() => rootRef.child('user-789')).thenReturn(userRef);
      when(() => userRef.set(any<dynamic>())).thenAnswer((_) async {});

      final RealtimeDatabaseCounterRepository repository =
          RealtimeDatabaseCounterRepository(counterRef: rootRef, auth: auth);
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(42);

      await AppLogger.silenceAsync(() async {
        await repository.save(
          CounterSnapshot(userId: '', count: 4, lastChanged: timestamp),
        );
      });

      final VerificationResult verification = verify(() {
        return userRef.set(captureAny<dynamic>());
      });
      verification.called(1);
      final Object? payload = verification.captured.single;
      expect(payload, isA<Map<String, Object?>>());
      final Map<dynamic, dynamic> map = payload as Map<dynamic, dynamic>;
      expect(map['userId'], 'user-789');
      expect(map['count'], 4);
      expect(map['last_changed'], timestamp.millisecondsSinceEpoch);
    });

    test(
      'save falls back gracefully when FlutterFire throws details cast TypeError',
      () async {
        final MockFirebaseAuth auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-typed'),
        );
        final _MockDatabaseReference rootRef = _MockDatabaseReference();
        final _MockDatabaseReference userRef = _MockDatabaseReference();

        when(() => rootRef.path).thenReturn('counter');
        when(() => rootRef.child('user-typed')).thenReturn(userRef);
        when(() => userRef.set(any<dynamic>())).thenAnswer((_) async {
          final dynamic details = 'permission-denied';
          details as Map<dynamic, dynamic>;
          return;
        });

        final RealtimeDatabaseCounterRepository repository =
            RealtimeDatabaseCounterRepository(counterRef: rootRef, auth: auth);

        await AppLogger.silenceAsync(() async {
          await repository.save(const CounterSnapshot(userId: '', count: 2));
        });

        verify(() => userRef.set(any<dynamic>())).called(1);
      },
    );

    test('watch emits snapshots from database stream', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-watch'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final StreamController<DatabaseEvent> controller =
          StreamController<DatabaseEvent>();
      final _MockDatabaseEvent event = _MockDatabaseEvent();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();

      when(() => rootRef.child('user-watch')).thenReturn(userRef);
      when(() => userRef.onValue).thenAnswer((_) => controller.stream);
      when(() => event.snapshot).thenReturn(snapshot);
      when(() => snapshot.value).thenReturn(<String, Object?>{'count': 6});

      final RealtimeDatabaseCounterRepository repository =
          RealtimeDatabaseCounterRepository(counterRef: rootRef, auth: auth);

      final Future<CounterSnapshot> futureSnapshot = AppLogger.silenceAsync(() {
        return repository.watch().first;
      });

      controller.add(event);
      final CounterSnapshot result = await futureSnapshot;

      expect(result.userId, 'user-watch');
      expect(result.count, 6);

      await controller.close();
    });
  });
}

class _MockDatabaseReference extends Mock implements DatabaseReference {}

class _MockDataSnapshot extends Mock implements DataSnapshot {}

class _MockDatabaseEvent extends Mock implements DatabaseEvent {}
