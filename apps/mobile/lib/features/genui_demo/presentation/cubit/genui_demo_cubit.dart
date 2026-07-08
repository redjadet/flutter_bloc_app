import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:genui/genui.dart' as genui;

part 'genui_demo_cubit_handlers.part.dart';

class GenUiDemoCubit extends Cubit<GenUiDemoState>
    with CubitSubscriptionMixin<GenUiDemoState> {
  GenUiDemoCubit({required this._agent})
    : super(const GenUiDemoState.initial());

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
    _surfaceSubscription = _agent.surfaceEvents.listen(
      _onSurfaceEvent,
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'GenUiDemoCubit surface events stream error',
          error,
          stackTrace,
        );
      },
    );
    _errorSubscription = _agent.errors.listen(
      _onError,
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'GenUiDemoCubit errors stream error',
          error,
          stackTrace,
        );
      },
    );
    registerSubscription(_surfaceSubscription);
    registerSubscription(_errorSubscription);

    if (isClosed) return;
    final Object? rawHostHandle = _agent.hostHandle;
    final genui.A2uiMessageProcessor? hostHandle =
        rawHostHandle is genui.A2uiMessageProcessor ? rawHostHandle : null;
    if (rawHostHandle != null && hostHandle == null) {
      emit(
        const GenUiDemoState.error(
          message: 'GenUI host handle has an unexpected type.',
        ),
      );
      return;
    }
    emit(
      GenUiDemoState.ready(
        surfaceIds: const [],
        hostHandle: hostHandle,
      ),
    );
  }
}
