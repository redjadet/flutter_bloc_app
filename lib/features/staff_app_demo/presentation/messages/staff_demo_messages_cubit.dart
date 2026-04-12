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

  // ignore: cancel_subscriptions - Replaced via cancelRegisteredSubscription; mixin closes on dispose.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  /// Incremented on each recipients snapshot; stale async hydrates bail out before emit.
  int _inboxHydrationToken = 0;

  Future<void> initialize() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoMessagesStatus.error,
          knownError: StaffDemoMessagesKnownError.notSignedIn,
          errorMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: StaffDemoMessagesStatus.loading,
        knownError: null,
        errorMessage: null,
      ),
    );
    // Invalidate any in-flight async hydration immediately so a manual refresh
    // cannot be overwritten by stale pre-refresh message loads.
    _inboxHydrationToken += 1;
    final previous = _subscription;
    _subscription = null;
    if (previous != null) {
      await cancelRegisteredSubscription(previous);
    }

    _subscription = _inboxRepository
        .watchRecipients(userId: userId)
        .listen(
          (snapshot) {
            final token = ++_inboxHydrationToken;
            unawaited(_hydrateFromRecipients(snapshot.docs, token));
          },
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
                  knownError: null,
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
                knownError: StaffDemoMessagesKnownError.inboxStreamFailed,
                errorMessage: null,
              ),
            );
          },
        );
    registerSubscription(_subscription);
  }

  Future<void> _hydrateFromRecipients(
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    final int hydrationToken,
  ) async {
    try {
      final items = <StaffDemoInboxItem>[];

      for (final doc in docs) {
        if (isClosed || hydrationToken != _inboxHydrationToken) return;
        final data = doc.data();
        final messageId = data['messageId'] as String?;
        if (messageId == null || messageId.isEmpty) continue;
        final Object? confirmedAtRaw = data['confirmedAt'];
        final int? confirmedAtMs = confirmedAtRaw is Timestamp
            ? confirmedAtRaw.toDate().millisecondsSinceEpoch
            : null;

        final msg = await _inboxRepository.loadMessage(messageId);
        if (hydrationToken != _inboxHydrationToken) return;
        if (msg == null) continue;

        final shiftId = msg['shiftId'] as String?;
        final String? shiftStatus = (shiftId == null || shiftId.isEmpty)
            ? null
            : await _inboxRepository.loadShiftStatus(shiftId);

        if (hydrationToken != _inboxHydrationToken) return;

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

      if (isClosed || hydrationToken != _inboxHydrationToken) return;
      emit(
        state.copyWith(
          status: StaffDemoMessagesStatus.ready,
          items: items,
          knownError: null,
          errorMessage: null,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (hydrationToken != _inboxHydrationToken) return;
      AppLogger.error(
        'StaffDemoMessagesCubit inbox hydrate failed',
        error,
        stackTrace,
      );
      if (isClosed || hydrationToken != _inboxHydrationToken) return;
      emit(
        state.copyWith(
          status: StaffDemoMessagesStatus.error,
          knownError: null,
          errorMessage: error.toString(),
        ),
      );
    }
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
            status: StaffDemoMessagesStatus.ready,
            knownError: null,
            errorMessage: null,
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
            knownError: null,
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
      onSuccess: (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoMessagesStatus.ready,
            knownError: null,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoMessagesStatus.error,
            knownError: null,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoMessagesCubit.sendShiftAssignment',
    );
  }
}
