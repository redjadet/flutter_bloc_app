import 'dart:async';

import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPendingSyncRepository extends Mock implements PendingSyncRepository {}

void main() {
  late MockPendingSyncRepository pendingRepository;
  late StreamController<void> enqueueController;

  setUpAll(() {
    registerFallbackValue(DateTime.fromMillisecondsSinceEpoch(0));
  });

  setUp(() {
    pendingRepository = MockPendingSyncRepository();
    enqueueController = StreamController<void>.broadcast();
    when(
      () => pendingRepository.onOperationEnqueued,
    ).thenAnswer((_) => enqueueController.stream);
  });

  tearDown(() async {
    await enqueueController.close();
  });

  ChatSyncStatusCubit buildCubit() =>
      ChatSyncStatusCubit(pendingRepository: pendingRepository);

  group('ChatSyncStatusCubit', () {
    test('initial pendingCount is zero', () {
      final ChatSyncStatusCubit cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.pendingCount, 0);
    });

    test('refresh counts only chat entity operations', () async {
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer(
        (_) async => <SyncOperation>[
          SyncOperation.create(
            entityType: chatSyncEntityType,
            payload: const <String, dynamic>{},
            idempotencyKey: 'chat-1',
          ),
          SyncOperation.create(
            entityType: chatSyncEntityType,
            payload: const <String, dynamic>{},
            idempotencyKey: 'chat-2',
          ),
          SyncOperation.create(
            entityType: 'counter',
            payload: const <String, dynamic>{},
            idempotencyKey: 'counter-1',
          ),
        ],
      );

      final ChatSyncStatusCubit cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.pendingCount, 2);
    });

    test('onOperationEnqueued triggers refresh', () async {
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer(
        (_) async => <SyncOperation>[
          SyncOperation.create(
            entityType: chatSyncEntityType,
            payload: const <String, dynamic>{},
            idempotencyKey: 'chat-enqueue',
          ),
        ],
      );

      final ChatSyncStatusCubit cubit = buildCubit();
      addTearDown(cubit.close);

      enqueueController.add(null);
      await pumpEventQueue();

      expect(cubit.state.pendingCount, 1);
      verify(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).called(1);
    });
  });
}
