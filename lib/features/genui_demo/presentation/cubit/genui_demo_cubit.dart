import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';

class GenUiDemoCubit extends Cubit<GenUiDemoState>
    with CubitSubscriptionMixin<GenUiDemoState> {
  GenUiDemoCubit({required final GenUiDemoAgent agent})
    : _agent = agent,
      super(const GenUiDemoState.initial());

  final GenUiDemoAgent _agent;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<GenUiSurfaceEvent>? _surfaceSubscription;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<String>? _errorSubscription;

  Future<void> initialize() async {
    final bool isReady = state.maybeWhen(
      ready: (_, final _, final _) => true,
      orElse: () => false,
    );
    if (isReady) return;
    final bool isLoading = state.maybeWhen(
      loading: (_, final _, final _) => true,
      orElse: () => false,
    );
    if (isLoading) return;
    if (isClosed) return;

    emit(const GenUiDemoState.loading());

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _agent.initialize(),
      isAlive: () => !isClosed,
      logContext: 'GenUiDemoCubit.initialize',
      onError: (final message) {
        if (isClosed) return;
        emit(GenUiDemoState.error(message: message));
      },
    );

    if (isClosed) return;
    final bool isError = state.maybeWhen(
      error: (_, final _, final _, final _) => true,
      orElse: () => false,
    );
    if (isError) return;
    if (isClosed) return;

    // Subscribe to streams
    _surfaceSubscription = _agent.surfaceEvents.listen(_onSurfaceEvent);
    _errorSubscription = _agent.errors.listen(_onError);
    registerSubscription(_surfaceSubscription);
    registerSubscription(_errorSubscription);

    if (isClosed) return;
    emit(
      GenUiDemoState.ready(
        surfaceIds: const [],
        hostHandle: _agent.hostHandle,
      ),
    );
  }

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
