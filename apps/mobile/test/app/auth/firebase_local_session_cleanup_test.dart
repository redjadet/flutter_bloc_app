import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc_app/app/auth/firebase_local_session_cleanup.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

import '../../test_helpers_shared.dart';

class _MockChatHistoryRepository extends Mock
    implements ChatHistoryRepository {}

class _RecordingSyncCoordinator extends FakeBackgroundSyncCoordinator {
  int stopCalls = 0;
  int ensureStartedCalls = 0;
  int quiesceCalls = 0;
  int resumeCalls = 0;

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> ensureStarted() async {
    ensureStartedCalls += 1;
  }

  @override
  Future<void> quiesceForSessionCleanup() async {
    quiesceCalls += 1;
  }

  @override
  Future<void> resumeAfterSessionCleanup() async {
    resumeCalls += 1;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const <ChatConversation>[]);
  });

  group('clearFirebaseLocalSessionData', () {
    late FakePendingSyncRepository pendingSync;
    late _MockChatHistoryRepository chatHistory;
    late _RecordingSyncCoordinator syncCoordinator;

    setUp(() async {
      await getIt.reset();
      pendingSync = FakePendingSyncRepository();
      chatHistory = _MockChatHistoryRepository();
      syncCoordinator = _RecordingSyncCoordinator();
      when(() => chatHistory.save(any())).thenAnswer((_) async {});

      getIt.registerSingleton<PendingSyncRepository>(pendingSync);
      getIt.registerSingleton<ChatHistoryRepository>(chatHistory);
      getIt.registerSingleton<BackgroundSyncCoordinator>(syncCoordinator);
    });

    tearDown(() async {
      await getIt.reset();
    });

    test(
      'quiesces sync, clears pending rows + chat, then restarts sync',
      () async {
        await pendingSync.enqueue(
          SyncOperation.create(
            entityType: 'todo',
            payload: const <String, dynamic>{'id': 't1'},
            idempotencyKey: 'todo-1',
            createdAt: DateTime.utc(2026),
            nextRetryAt: DateTime.utc(2026),
          ),
        );
        await pendingSync.enqueue(
          SyncOperation.create(
            entityType: chatSyncEntityType,
            payload: const <String, dynamic>{'id': 'c1'},
            idempotencyKey: 'chat-1',
            createdAt: DateTime.utc(2026),
            nextRetryAt: DateTime.utc(2026),
          ),
        );
        await pendingSync.enqueue(
          SyncOperation.create(
            entityType: 'other',
            payload: const <String, dynamic>{'id': 'o1'},
            idempotencyKey: 'other-1',
            createdAt: DateTime.utc(2026),
            nextRetryAt: DateTime.utc(2026),
          ),
        );

        await clearFirebaseLocalSessionData(
          provider: AuthProviderKind.firebase,
          reason: SessionLocalCleanupReason.accountSwitch,
        );

        expect(syncCoordinator.quiesceCalls, 1);
        expect(syncCoordinator.resumeCalls, 1);
        final List<SyncOperation> remaining = await pendingSync
            .getPendingOperations();
        expect(
          remaining.map((final SyncOperation op) => op.entityType).toList(),
          <String>['other'],
        );
        verify(() => chatHistory.save(const <ChatConversation>[])).called(1);
      },
    );

    test('skips non-firebase providers', () async {
      await clearFirebaseLocalSessionData(
        provider: AuthProviderKind.supabase,
        reason: SessionLocalCleanupReason.signOut,
      );

      expect(syncCoordinator.quiesceCalls, 0);
      verifyNever(() => chatHistory.save(any()));
    });
  });
}
