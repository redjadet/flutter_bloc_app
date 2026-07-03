// Split helper extension shares Cubit internals from the owning library.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'genui_demo_cubit.dart';

extension GenUiDemoCubitHandlers on GenUiDemoCubit {
  Future<void> sendMessage(final String text) async {
    if (text.trim().isEmpty) return;
    final bool canSend = state.maybeWhen(
      ready: (_, final _, final _) => true,
      loading: (_, final _, final _) => true,
      error: (_, final _, final hostHandle, final _) => hostHandle != null,
      orElse: () => false,
    );
    if (!canSend) return;
    if (isClosed) return;

    state.mapOrNull(
      ready: (final state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: true));
      },
      loading: (final state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: true));
      },
      error: (final state) {
        if (isClosed) return;
        emit(
          GenUiDemoState.ready(
            surfaceIds: state.surfaceIds,
            hostHandle: state.hostHandle,
            isSending: true,
          ),
        );
      },
    );

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _agent.sendMessage(text),
      isAlive: () => !isClosed,
      logContext: 'GenUiDemoCubit.sendMessage',
      onError: (final message) {
        if (isClosed) return;
        state.mapOrNull(
          ready: (final state) => emit(
            GenUiDemoState.error(
              message: message,
              surfaceIds: state.surfaceIds,
              hostHandle: state.hostHandle,
            ),
          ),
          loading: (final state) => emit(
            GenUiDemoState.error(
              message: message,
              surfaceIds: state.surfaceIds,
              hostHandle: state.hostHandle,
            ),
          ),
          error: (final state) => emit(
            state.copyWith(
              message: message,
              isSending: false,
            ),
          ),
        );
      },
    );

    if (isClosed) return;

    state.mapOrNull(
      ready: (final state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
      loading: (final state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
      error: (final state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
    );
  }

  void _onSurfaceEvent(final GenUiSurfaceEvent event) {
    if (isClosed) return;

    event.when(
      added: (final surfaceId) {
        state.mapOrNull(
          ready: (final state) {
            if (isClosed) return;
            emit(state.copyWith(surfaceIds: [...state.surfaceIds, surfaceId]));
          },
          loading: (final state) {
            if (isClosed) return;
            emit(state.copyWith(surfaceIds: [...state.surfaceIds, surfaceId]));
          },
        );
      },
      removed: (final surfaceId) {
        state.mapOrNull(
          ready: (final state) {
            if (isClosed) return;
            emit(
              state.copyWith(
                surfaceIds: state.surfaceIds
                    .where((final id) => id != surfaceId)
                    .toList(),
              ),
            );
          },
          loading: (final state) {
            if (isClosed) return;
            emit(
              state.copyWith(
                surfaceIds: state.surfaceIds
                    .where((final id) => id != surfaceId)
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _onError(final String error) {
    if (isClosed) return;

    state.mapOrNull(
      ready: (final state) {
        if (isClosed) return;
        emit(
          GenUiDemoState.error(
            message: error,
            surfaceIds: state.surfaceIds,
            hostHandle: state.hostHandle,
          ),
        );
      },
      loading: (final state) {
        if (isClosed) return;
        emit(
          GenUiDemoState.error(
            message: error,
            surfaceIds: state.surfaceIds,
            hostHandle: state.hostHandle,
          ),
        );
      },
    );
  }
}
