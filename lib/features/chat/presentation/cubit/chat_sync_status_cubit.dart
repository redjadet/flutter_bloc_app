import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class ChatSyncStatusState {
  const ChatSyncStatusState({this.pendingCount = 0});

  final int pendingCount;

  ChatSyncStatusState copyWith({final int? pendingCount}) =>
      ChatSyncStatusState(
        pendingCount: pendingCount ?? this.pendingCount,
      );
}

/// Route-scoped cubit exposing pending chat sync queue depth for banner UI.
class ChatSyncStatusCubit extends Cubit<ChatSyncStatusState> {
  ChatSyncStatusCubit({required this.pendingRepository})
    : super(const ChatSyncStatusState()) {
    _enqueueSubscription = pendingRepository.onOperationEnqueued.listen(
      (_) {
        unawaited(refresh());
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'ChatSyncStatusCubit enqueue stream error',
          error,
          stackTrace,
        );
      },
    );
  }

  final PendingSyncRepository pendingRepository;
  StreamSubscription<void>? _enqueueSubscription;

  @override
  Future<void> close() async {
    await _enqueueSubscription?.cancel();
    return super.close();
  }

  Future<void> refresh() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        final List<SyncOperation> operations = await pendingRepository
            .getPendingOperations(
              now: DateTime.now().toUtc(),
            );
        final int chatPending = operations
            .where((final op) => op.entityType == chatSyncEntityType)
            .length;
        if (isClosed) {
          return;
        }
        emit(state.copyWith(pendingCount: chatPending));
      },
      isAlive: () => !isClosed,
      onError: (final errorMessage) {
        AppLogger.error('ChatSyncStatusCubit.refresh failed: $errorMessage');
      },
      logContext: 'ChatSyncStatusCubit.refresh',
    );
  }
}
