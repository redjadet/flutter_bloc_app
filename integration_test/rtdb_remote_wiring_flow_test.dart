import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

void main() {
  registerIntegrationHarness();

  registerIntegrationFlow(
    groupName: 'RTDB remotes',
    testName: 'wires Counter/Todo remote repos with real auth',
    options: const IntegrationDependencyOptions(
      authMode: IntegrationAuthMode.realFirebaseAuth,
      overrideCounterRepository: false,
    ),
    body: (final tester) async {
      expect(
        FirebaseBootstrapService.isFirebaseInitialized,
        isTrue,
        reason: 'Firebase must be initialized for real-auth wiring.',
      );

      const String email = 'staffdemo.manager@example.com';
      const String password = 'StaffDemo!234';
      final UserCredential credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      addTearDown(FirebaseAuth.instance.signOut);
      expect(
        credentials.user?.uid,
        isNot(isEmpty),
        reason: 'RTDB calls need a plugin-backed Firebase Auth user.',
      );
      final String uid = credentials.user!.uid;

      final CounterRepository counter = getIt<CounterRepository>();
      expect(counter, isA<OfflineFirstCounterRepository>());
      final OfflineFirstCounterRepository offlineCounter =
          counter as OfflineFirstCounterRepository;
      expect(
        offlineCounter.hasRemoteRepository,
        isTrue,
        reason: 'RTDB counter remote should be wired when Firebase is ready.',
      );
      await offlineCounter.pullRemote();

      final DatabaseReference counterRef = FirebaseDatabase.instance
          .ref('counter')
          .child(uid);
      final DataSnapshot counterBefore = await counterRef.get();
      final Object? counterBeforeValue = counterBefore.value;
      addTearDown(() async {
        if (counterBeforeValue == null) {
          await counterRef.remove();
        } else {
          await counterRef.set(counterBeforeValue);
        }
      });

      final int remoteCounterProbe =
          DateTime.now().microsecondsSinceEpoch.remainder(100000) + 1;
      final Future<void> counterWatchProof = counter
          .watch()
          .firstWhere((final s) => s.count == remoteCounterProbe)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TestFailure(
              'CounterRepository.watch() did not emit remote RTDB update. '
              'Expected count=$remoteCounterProbe for uid=$uid.',
            ),
          )
          .then((_) {});

      await counterRef.set(<String, Object?>{
        'userId': uid,
        'count': remoteCounterProbe,
        'last_changed': DateTime.now().toUtc().millisecondsSinceEpoch,
      });
      await counterWatchProof;

      final TodoRepository todo = getIt<TodoRepository>();
      expect(todo, isA<OfflineFirstTodoRepository>());
      final OfflineFirstTodoRepository offlineTodo =
          todo as OfflineFirstTodoRepository;
      expect(
        offlineTodo.hasRemoteRepository,
        isTrue,
        reason: 'RTDB todo remote should be wired when Firebase is ready.',
      );

      final DatabaseReference todoRef = FirebaseDatabase.instance
          .ref('todos')
          .child(uid);

      final DateTime now = DateTime.now().toUtc();
      final String todoId = 'rtdb-watch-${now.microsecondsSinceEpoch}';
      addTearDown(() async {
        await todoRef.child(todoId).remove();
      });

      final Future<void> todoWatchProof = todo
          .watchAll()
          .firstWhere(
            (final items) => items.any((final item) => item.id == todoId),
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TestFailure(
              'TodoRepository.watchAll() did not emit remote RTDB update. '
              'Expected id=$todoId for uid=$uid.',
            ),
          )
          .then((_) {});

      await todoRef.child(todoId).set(<String, Object?>{
        'id': todoId,
        'title': 'RTDB remote watch probe',
        'description': null,
        'isCompleted': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'priority': 'none',
        'synchronized': false,
        'userId': uid,
      });
      await todoWatchProof;
    },
  );
}
