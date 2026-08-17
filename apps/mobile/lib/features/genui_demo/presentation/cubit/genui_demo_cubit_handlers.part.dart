// Split helper extension shares Cubit internals from the owning library.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'genui_demo_cubit.dart';

extension GenUiDemoCubitHandlers on GenUiDemoCubit {
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final bool canSend = state.maybeWhen(
      ready: (_, _, _) => true,
      loading: (_, _, _) => true,
      error: (_, _, hostHandle, _) => hostHandle != null,
      orElse: () => false,
    );
    if (!canSend) return;
    if (isClosed) return;

    state.mapOrNull(
      ready: (state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: true));
      },
      loading: (state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: true));
      },
      error: (state) {
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
      onError: (message) {
        if (isClosed) return;
        state.mapOrNull(
          ready: (state) => emit(
            GenUiDemoState.error(
              message: message,
              surfaceIds: state.surfaceIds,
              hostHandle: state.hostHandle,
            ),
          ),
          loading: (state) => emit(
            GenUiDemoState.error(
              message: message,
              surfaceIds: state.surfaceIds,
              hostHandle: state.hostHandle,
            ),
          ),
          error: (state) => emit(
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
      ready: (state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
      loading: (state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
      error: (state) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
    );
  }

  void _onSurfaceEvent(GenUiSurfaceEvent event) {
    if (isClosed) return;

    event.when(
      added: (surfaceId) {
        state.mapOrNull(
          ready: (state) {
            if (isClosed) return;
            emit(state.copyWith(surfaceIds: [...state.surfaceIds, surfaceId]));
          },
          loading: (state) {
            if (isClosed) return;
            emit(state.copyWith(surfaceIds: [...state.surfaceIds, surfaceId]));
          },
        );
      },
      removed: (surfaceId) {
        state.mapOrNull(
          ready: (state) {
            if (isClosed) return;
            emit(
              state.copyWith(
                surfaceIds: state.surfaceIds
                    .where((id) => id != surfaceId)
                    .toList(),
              ),
            );
          },
          loading: (state) {
            if (isClosed) return;
            emit(
              state.copyWith(
                surfaceIds: state.surfaceIds
                    .where((id) => id != surfaceId)
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _onError(String error) {
    if (isClosed) return;

    state.mapOrNull(
      ready: (state) {
        if (isClosed) return;
        emit(
          GenUiDemoState.error(
            message: error,
            surfaceIds: state.surfaceIds,
            hostHandle: state.hostHandle,
          ),
        );
      },
      loading: (state) {
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
