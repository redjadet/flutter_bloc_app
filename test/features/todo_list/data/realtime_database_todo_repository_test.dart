import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/features/todo_list/data/realtime_database_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('RealtimeDatabaseTodoRepository', () {
    test('fetchAll returns empty list when no todos exist', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();

      when(() => snapshot.exists).thenReturn(false);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn(null);

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final List<TodoItem> result = await AppLogger.silenceAsync(() {
        return repository.fetchAll();
      });

      expect(result, isEmpty);
    });

    test('fetchAll returns parsed todos from database', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();
      final DateTime now = DateTime.now().toUtc();
      final String nowIso = now.toIso8601String();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-1': {
          'id': 'todo-1',
          'title': 'Test Todo',
          'description': 'Test Description',
          'isCompleted': false,
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'priority': 'high',
          'userId': 'user-123',
        },
      });

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final List<TodoItem> result = await AppLogger.silenceAsync(() {
        return repository.fetchAll();
      });

      expect(result, hasLength(1));
      expect(result.first.id, 'todo-1');
      expect(result.first.title, 'Test Todo');
      expect(result.first.description, 'Test Description');
      expect(result.first.isCompleted, false);
      expect(result.first.priority, TodoPriority.high);
    });

    test('fetchAll returns sorted todos by updatedAt descending', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();
      final DateTime baseTime = DateTime.now().toUtc();
      final String time1 = baseTime.toIso8601String();
      final String time2 = baseTime
          .add(const Duration(hours: 1))
          .toIso8601String();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-1': {
          'id': 'todo-1',
          'title': 'Older Todo',
          'createdAt': time1,
          'updatedAt': time1,
          'isCompleted': false,
          'userId': 'user-123',
        },
        'todo-2': {
          'id': 'todo-2',
          'title': 'Newer Todo',
          'createdAt': time1,
          'updatedAt': time2,
          'isCompleted': false,
          'userId': 'user-123',
        },
      });

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final List<TodoItem> result = await AppLogger.silenceAsync(() {
        return repository.fetchAll();
      });

      expect(result, hasLength(2));
      expect(result.first.id, 'todo-2'); // Newer first
      expect(result.last.id, 'todo-1'); // Older last
    });

    test('fetchAll falls back to empty list on firebase exception', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-456'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();

      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-456')).thenReturn(userRef);
      when(
        () => userRef.get(),
      ).thenThrow(FirebaseException(plugin: 'database', message: 'boom'));

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final List<TodoItem> result = await AppLogger.silenceAsync(() {
        return repository.fetchAll();
      });

      expect(result, isEmpty);
    });

    test('fetchAll skips invalid entries and logs errors', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();
      final DateTime now = DateTime.now().toUtc();
      final String nowIso = now.toIso8601String();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-valid': {
          'id': 'todo-valid',
          'title': 'Valid Todo',
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'isCompleted': false,
          'userId': 'user-123',
        },
        'todo-invalid': {
          // Missing required fields
          'title': 'Invalid Todo',
        },
      });

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final List<TodoItem> result = await AppLogger.silenceAsync(() {
        return repository.fetchAll();
      });

      expect(result, hasLength(1));
      expect(result.first.id, 'todo-valid');
    });

    test('fetchAll falls back to entry key when id is missing', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();
      final DateTime now = DateTime.now().toUtc();
      final String nowIso = now.toIso8601String();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-1': {
          'title': 'Missing Id',
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'isCompleted': false,
          'userId': 'user-123',
        },
      });

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final List<TodoItem> result = await AppLogger.silenceAsync(() {
        return repository.fetchAll();
      });

      expect(result, hasLength(1));
      expect(result.first.id, 'todo-1');
      expect(result.first.title, 'Missing Id');
    });

    test('save writes todo to database with userId', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDatabaseReference todoRef = _MockDatabaseReference();
      final DateTime now = DateTime.now().toUtc();
      final TodoItem item = TodoItem.create(
        title: 'New Todo',
        description: 'Description',
        priority: TodoPriority.high,
        now: now,
      );

      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.child(item.id)).thenReturn(todoRef);
      when(() => todoRef.set(any())).thenAnswer((_) async => {});

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      await AppLogger.silenceAsync(() {
        return repository.save(item);
      });

      final captured = verify(() => todoRef.set(captureAny())).captured;
      final Map<String, dynamic> writtenData =
          captured.first as Map<String, dynamic>;
      expect(writtenData['id'], item.id);
      expect(writtenData['title'], 'New Todo');
      expect(writtenData['description'], 'Description');
      expect(writtenData['priority'], 'high');
      expect(writtenData['userId'], 'user-123');
    });

    test(
      'save falls back gracefully when FlutterFire throws details cast TypeError',
      () async {
        final MockFirebaseAuth auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-123'),
        );
        final _MockDatabaseReference rootRef = _MockDatabaseReference();
        final _MockDatabaseReference userRef = _MockDatabaseReference();
        final _MockDatabaseReference todoRef = _MockDatabaseReference();
        final DateTime now = DateTime.now().toUtc();
        final TodoItem item = TodoItem.create(
          title: 'Type Error Todo',
          now: now,
        );

        when(() => rootRef.path).thenReturn('todos');
        when(() => rootRef.child('user-123')).thenReturn(userRef);
        when(() => userRef.child(item.id)).thenReturn(todoRef);
        when(() => todoRef.set(any())).thenAnswer((_) async {
          final dynamic details = 'permission-denied';
          // Simulate FlutterFire internals cast failure:
          // String cannot be cast to Map<dynamic, dynamic>.
          details as Map<dynamic, dynamic>;
        });

        final RealtimeDatabaseTodoRepository repository =
            RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

        await AppLogger.silenceAsync(() {
          return repository.save(item);
        });

        verify(() => todoRef.set(any())).called(1);
      },
    );

    test('delete removes todo from database', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDatabaseReference todoRef = _MockDatabaseReference();

      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.child('todo-1')).thenReturn(todoRef);
      when(() => todoRef.remove()).thenAnswer((_) async => {});

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      await AppLogger.silenceAsync(() {
        return repository.delete('todo-1');
      });

      verify(() => todoRef.remove()).called(1);
    });

    test('delete falls back gracefully on firebase exception', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDatabaseReference todoRef = _MockDatabaseReference();

      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.child('todo-1')).thenReturn(todoRef);
      when(
        () => todoRef.remove(),
      ).thenThrow(FirebaseException(plugin: 'database', message: 'boom'));

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      await AppLogger.silenceAsync(() {
        return repository.delete('todo-1');
      });

      // Should not throw
    });

    test('clearCompleted removes all completed todos', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();
      final DateTime now = DateTime.now().toUtc();
      final String nowIso = now.toIso8601String();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-1': {
          'id': 'todo-1',
          'title': 'Completed Todo',
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'isCompleted': true,
          'userId': 'user-123',
        },
        'todo-2': {
          'id': 'todo-2',
          'title': 'Active Todo',
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'isCompleted': false,
          'userId': 'user-123',
        },
      });
      when(() => rootRef.update(any())).thenAnswer((_) async => {});

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      await AppLogger.silenceAsync(() {
        return repository.clearCompleted();
      });

      final captured = verify(() => rootRef.update(captureAny())).captured;
      final Map<String, Object?> updates =
          captured.first as Map<String, Object?>;
      expect(updates['user-123/todo-1'], isNull);
      expect(updates.containsKey('user-123/todo-2'), false);
    });

    test('clearCompleted does nothing when no completed todos exist', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );
      final _MockDatabaseReference rootRef = _MockDatabaseReference();
      final _MockDatabaseReference userRef = _MockDatabaseReference();
      final _MockDataSnapshot snapshot = _MockDataSnapshot();
      final DateTime now = DateTime.now().toUtc();
      final String nowIso = now.toIso8601String();

      when(() => snapshot.exists).thenReturn(true);
      when(() => rootRef.path).thenReturn('todos');
      when(() => rootRef.child('user-123')).thenReturn(userRef);
      when(() => userRef.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-1': {
          'id': 'todo-1',
          'title': 'Active Todo',
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'isCompleted': false,
          'userId': 'user-123',
        },
      });

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      await AppLogger.silenceAsync(() {
        return repository.clearCompleted();
      });

      verifyNever(() => rootRef.update(any()));
    });

    test('watchAll emits todos from database stream', () async {
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
      final DateTime now = DateTime.now().toUtc();
      final String nowIso = now.toIso8601String();

      when(() => rootRef.child('user-watch')).thenReturn(userRef);
      when(() => userRef.onValue).thenAnswer((_) => controller.stream);
      when(() => event.snapshot).thenReturn(snapshot);
      when(() => snapshot.value).thenReturn({
        'todo-1': {
          'id': 'todo-1',
          'title': 'Watched Todo',
          'createdAt': nowIso,
          'updatedAt': nowIso,
          'isCompleted': false,
          'userId': 'user-watch',
        },
      });

      final RealtimeDatabaseTodoRepository repository =
          RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

      final Future<List<TodoItem>> futureTodos = AppLogger.silenceAsync(() {
        return repository.watchAll().first;
      });

      controller.add(event);
      final List<TodoItem> result = await futureTodos;

      expect(result, hasLength(1));
      expect(result.first.id, 'todo-1');
      expect(result.first.title, 'Watched Todo');

      await controller.close();
    });

    test(
      'throws FirebaseAuthException when user is not authenticated',
      () async {
        final MockFirebaseAuth auth = MockFirebaseAuth();
        final _MockDatabaseReference rootRef = _MockDatabaseReference();

        when(() => rootRef.path).thenReturn('todos');

        final RealtimeDatabaseTodoRepository repository =
            RealtimeDatabaseTodoRepository(todoRef: rootRef, auth: auth);

        await expectLater(
          AppLogger.silenceAsync(() {
            return repository.fetchAll();
          }),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );
  });
}

class _MockDatabaseReference extends Mock implements DatabaseReference {}

class _MockDataSnapshot extends Mock implements DataSnapshot {}

class _MockDatabaseEvent extends Mock implements DatabaseEvent {}
