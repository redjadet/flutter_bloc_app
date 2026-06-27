import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_defaults.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
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
    required this._profileRepository,
  }) : super(const StaffDemoMessagesState());

  final AuthRepository _authRepository;
  final StaffDemoInboxRepository _inboxRepository;
  final StaffDemoMessagingRepository _messagingRepository;
  final StaffDemoProfileRepository _profileRepository;

  // ignore: cancel_subscriptions - Replaced via cancelRegisteredSubscription; mixin closes on dispose.
  StreamSubscription<List<StaffDemoInboxRecipientSnapshot>>? _subscription;

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
          (recipients) {
            final token = ++_inboxHydrationToken;
            unawaited(hydrateFromRecipientsImpl(recipients, token));
          },
          onError: (Object error, StackTrace stackTrace) {
            AppLogger.error(
              'StaffDemoMessagesCubit recipients stream error',
              error,
              stackTrace,
            );
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

  Future<List<StaffDemoProfile>> loadAssignableStaff() =>
      _profileRepository.listAssignableStaff();

  Future<void> sendShiftAssignmentWithDefaults({
    required final String toUserId,
    required final String body,
    required final String siteId,
  }) {
    final ({DateTime startAtUtc, DateTime endAtUtc}) window =
        StaffDemoShiftDefaults.defaultWindowUtc();
    return sendShiftAssignment(
      toUserId: toUserId,
      body: body,
      siteId: siteId,
      startAtUtc: window.startAtUtc,
      endAtUtc: window.endAtUtc,
    );
  }

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
