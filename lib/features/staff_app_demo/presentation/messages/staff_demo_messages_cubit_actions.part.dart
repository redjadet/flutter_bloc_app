// Split helper extension calls Cubit.emit while sharing the owning library.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'staff_demo_messages_cubit.dart';

extension _StaffDemoMessagesCubitActions on StaffDemoMessagesCubit {
  Future<void> hydrateFromRecipientsImpl(
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

  Future<void> confirmImpl(final StaffDemoInboxItem item) async {
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

  Future<void> sendShiftAssignmentImpl({
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
      logContext: IntegrationLogMessages.staffDemoSendShiftAssignment,
    );
  }
}
