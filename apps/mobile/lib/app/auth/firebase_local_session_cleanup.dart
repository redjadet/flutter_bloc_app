import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

/// Firebase-backed offline stores that share one device-local Hive box / queue
/// entry without a user id. Cleared on sign-out and account switch so the next
/// session cannot read or sync the previous user's mutations.
const Set<String> kFirebaseSharedPendingSyncEntityTypes = <String>{
  OfflineFirstTodoRepository.todoEntity,
  OfflineFirstCounterRepository.counterEntity,
  chatSyncEntityType,
};

/// Clears shared Firebase offline caches and pending sync rows for [provider].
///
/// Quiesces [BackgroundSyncCoordinator] before mutating the queue so an
/// in-flight cycle cannot process previous-user ops under the new session.
Future<void> clearFirebaseLocalSessionData({
  required final AuthProviderKind provider,
  required final SessionLocalCleanupReason reason,
}) async {
  if (provider != AuthProviderKind.firebase) {
    return;
  }

  // Keep reason in the call signature for diagnostics and future scoped clears.
  assert(
    reason == SessionLocalCleanupReason.signOut ||
        reason == SessionLocalCleanupReason.accountSwitch,
    'Unexpected SessionLocalCleanupReason: $reason',
  );

  final BackgroundSyncCoordinator? syncCoordinator =
      getIt.isRegistered<BackgroundSyncCoordinator>()
      ? getIt<BackgroundSyncCoordinator>()
      : null;
  if (syncCoordinator != null) {
    await syncCoordinator.quiesceForSessionCleanup();
  }

  try {
    if (getIt.isRegistered<PendingSyncRepository>()) {
      await getIt<PendingSyncRepository>().clearEntityTypes(
        kFirebaseSharedPendingSyncEntityTypes,
      );
    }

    if (getIt.isRegistered<TodoRepository>()) {
      final TodoRepository todos = getIt<TodoRepository>();
      if (todos is OfflineFirstTodoRepository) {
        await todos.clearAllLocalData();
      }
    }

    if (getIt.isRegistered<CounterRepository>()) {
      final CounterRepository counter = getIt<CounterRepository>();
      if (counter is OfflineFirstCounterRepository) {
        await counter.clearAllLocalData();
      }
    }

    if (getIt.isRegistered<ChatHistoryRepository>()) {
      await getIt<ChatHistoryRepository>().save(const <ChatConversation>[]);
    }
  } finally {
    // Restart sync after clears so the next session can enqueue/push again.
    if (syncCoordinator != null) {
      await syncCoordinator.resumeAfterSessionCleanup();
    }
  }
}
