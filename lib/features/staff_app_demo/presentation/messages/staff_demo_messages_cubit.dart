import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class StaffDemoMessagesCubit extends Cubit<StaffDemoMessagesState>
    with CubitSubscriptionMixin<StaffDemoMessagesState> {
  StaffDemoMessagesCubit({
    required final AuthRepository authRepository,
    required final FirestoreStaffDemoInboxRepository inboxRepository,
    required final FirestoreStaffDemoMessagingRepository messagingRepository,
  }) : _authRepository = authRepository,
       _inboxRepository = inboxRepository,
       _messagingRepository = messagingRepository,
       super(const StaffDemoMessagesState());

  final AuthRepository _authRepository;
  final FirestoreStaffDemoInboxRepository _inboxRepository;
  final FirestoreStaffDemoMessagingRepository _messagingRepository;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  Future<void> initialize() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoMessagesStatus.error,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: StaffDemoMessagesStatus.loading));
    await _subscription?.cancel();

    _subscription = _inboxRepository
        .watchRecipients(userId: userId)
        .listen(
          (snapshot) => unawaited(_hydrateFromRecipients(snapshot.docs)),
          onError: (Object error, StackTrace stackTrace) {
            if (error is FirebaseException &&
                error.code == 'permission-denied') {
              AppLogger.info(
                'StaffDemoMessagesCubit recipients stream permission denied',
              );
              // Some roles/environments may not be allowed to read inbox updates.
              // Keep the screen usable (e.g. manager compose) rather than forcing
              // a hard error state.
              if (isClosed) return;
              emit(
                state.copyWith(
                  status: StaffDemoMessagesStatus.ready,
                  items: const <StaffDemoInboxItem>[],
                  errorMessage: null,
                ),
              );
              return;
            } else {
              AppLogger.error(
                'StaffDemoMessagesCubit recipients stream error',
                error,
                stackTrace,
              );
            }
            if (isClosed) return;
            emit(
              state.copyWith(
                status: StaffDemoMessagesStatus.error,
                errorMessage: 'Failed to load inbox updates.',
              ),
            );
          },
        );
    registerSubscription(_subscription);
  }

  Future<void> _hydrateFromRecipients(
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final items = <StaffDemoInboxItem>[];

    for (final doc in docs) {
      final data = doc.data();
      final messageId = data['messageId'] as String?;
      if (messageId == null || messageId.isEmpty) continue;
      final Object? confirmedAtRaw = data['confirmedAt'];
      final int? confirmedAtMs = confirmedAtRaw is Timestamp
          ? confirmedAtRaw.toDate().millisecondsSinceEpoch
          : null;

      final msg = await _inboxRepository.loadMessage(messageId);
      if (msg == null) continue;

      final shiftId = msg['shiftId'] as String?;
      final String? shiftStatus = (shiftId == null || shiftId.isEmpty)
          ? null
          : await _inboxRepository.loadShiftStatus(shiftId);

      items.add(
        StaffDemoInboxItem(
          messageId: messageId,
          body: (msg['body'] as String?) ?? '',
          type: (msg['type'] as String?) ?? '',
          shiftId: shiftId,
          confirmedAtMs: confirmedAtMs,
          shiftStatus: shiftStatus,
        ),
      );
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        status: StaffDemoMessagesStatus.ready,
        items: items,
        errorMessage: null,
      ),
    );
  }

  Future<void> confirm(final StaffDemoInboxItem item) async {
    final shiftId = item.shiftId;
    if (shiftId == null || shiftId.isEmpty) return;
    await CubitExceptionHandler.executeAsync<void>(
      operation: () => _messagingRepository.confirmShiftAssignment(
        messageId: item.messageId,
        shiftId: shiftId,
      ),
      isAlive: () => !isClosed,
      onSuccess: (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            items: state.items
                .map(
                  (i) => i.messageId == item.messageId
                      ? StaffDemoInboxItem(
                          messageId: i.messageId,
                          body: i.body,
                          type: i.type,
                          shiftId: i.shiftId,
                          confirmedAtMs: i.confirmedAtMs,
                          shiftStatus: 'confirmed',
                        )
                      : i,
                )
                .toList(),
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoMessagesStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoMessagesCubit.confirm',
    );
  }

  Future<void> sendShiftAssignment({
    required final String toUserId,
    required final String body,
    required final String siteId,
    required final DateTime startAtUtc,
    required final DateTime endAtUtc,
  }) async {
    await CubitExceptionHandler.executeAsync<void>(
      operation: () async {
        await _messagingRepository.sendShiftAssignment(
          toUserId: toUserId,
          body: body,
          siteId: siteId,
          startAtUtc: startAtUtc,
          endAtUtc: endAtUtc,
          timezoneName: 'UTC',
        );
      },
      isAlive: () => !isClosed,
      onSuccess: (_) {},
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoMessagesStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoMessagesCubit.sendShiftAssignment',
    );
  }
}
