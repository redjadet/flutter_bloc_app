import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/shared/diagnostics/integration_log_messages.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'staff_demo_messages_cubit_actions.part.dart';

class StaffDemoMessagesCubit extends Cubit<StaffDemoMessagesState>
    with CubitSubscriptionMixin<StaffDemoMessagesState> {
  StaffDemoMessagesCubit({
    required this._authRepository,
    required this._inboxRepository,
    required this._messagingRepository,
  }) : super(const StaffDemoMessagesState());

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
            unawaited(hydrateFromRecipientsImpl(snapshot.docs, token));
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

  Future<void> confirm(final StaffDemoInboxItem item) => confirmImpl(item);

  Future<void> sendShiftAssignment({
    required final String toUserId,
    required final String body,
    required final String siteId,
    required final DateTime startAtUtc,
    required final DateTime endAtUtc,
  }) => sendShiftAssignmentImpl(
    toUserId: toUserId,
    body: body,
    siteId: siteId,
    startAtUtc: startAtUtc,
    endAtUtc: endAtUtc,
  );
}
