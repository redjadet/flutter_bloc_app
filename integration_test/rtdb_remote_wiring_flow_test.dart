import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
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

      final TodoRepository todo = getIt<TodoRepository>();
      expect(todo, isA<OfflineFirstTodoRepository>());
      final OfflineFirstTodoRepository offlineTodo =
          todo as OfflineFirstTodoRepository;
      expect(
        offlineTodo.hasRemoteRepository,
        isTrue,
        reason: 'RTDB todo remote should be wired when Firebase is ready.',
      );
      final DateTime now = DateTime.now().toUtc();
      final TodoItem probe = TodoItem(
        id: 'rtdb-wiring-${now.microsecondsSinceEpoch}',
        title: 'RTDB wiring probe',
        createdAt: now,
        updatedAt: now,
      );
      try {
        await offlineTodo.save(probe);
      } finally {
        await offlineTodo.delete(probe.id);
      }
    },
  );
}
