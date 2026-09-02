import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/domain/toggle_scape_favorite.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/cubit/scapes_state.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';

/// Cubit for scapes list: load, grid/list toggle, and favorite toggle.
class ScapesCubit extends Cubit<ScapesState>
    with CubitSubscriptionMixin<ScapesState> {
  ScapesCubit({
    required this._repository,
    required this._timerService,
  }) : super(const ScapesState.initial()) {
    _loadScapes();
  }

  final ScapesRepository _repository;
  final TimerService _timerService;
  final RequestIdGuard _loadRequestIdGuard = RequestIdGuard();
  TimerDisposable? _loadDelayHandle;

  void _loadScapes() {
    final int requestId = _loadRequestIdGuard.next();
    emit(const ScapesState.loading());

    _loadDelayHandle?.dispose();
    unregisterTimer(_loadDelayHandle);
    late final TimerDisposable handle;
    handle = _timerService.runOnce(const Duration(milliseconds: 300), () {
      unregisterTimer(handle);
      if (identical(_loadDelayHandle, handle)) {
        _loadDelayHandle = null;
      }
      unawaited(_loadScapesFromRepository(requestId));
    });
    _loadDelayHandle = registerTimer(handle);
  }

  Future<void> _loadScapesFromRepository(int requestId) async {
    try {
      final scapes = await _repository.loadScapes();
      if (!_loadRequestIdGuard.isCurrent(requestId) || isClosed) return;
      emit(ScapesState.ready(scapes: scapes));
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'ScapesCubit._loadScapesFromRepository failed',
        e,
        stackTrace,
      );
      if (!_loadRequestIdGuard.isCurrent(requestId) || isClosed) return;
      emit(ScapesState.error(NetworkErrorMapper.getAppError(e)));
    }
  }

  void toggleViewMode() {
    final current = state;
    if (current is! ScapesReady) return;
    final newMode = current.viewMode == ScapesViewMode.grid
        ? ScapesViewMode.list
        : ScapesViewMode.grid;
    emit(current.copyWith(viewMode: newMode));
  }

  void toggleFavorite(String scapeId) {
    final current = state;
    if (current is! ScapesReady) return;
    emit(
      current.copyWith(
        scapes: toggleScapeFavorite(current.scapes, scapeId),
      ),
    );
  }

  void reload() {
    _loadScapes();
  }

  @override
  Future<void> close() {
    _loadDelayHandle?.dispose();
    unregisterTimer(_loadDelayHandle);
    _loadDelayHandle = null;
    return super.close();
  }
}
