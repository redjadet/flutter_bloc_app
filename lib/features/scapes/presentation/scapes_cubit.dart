import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';

class ScapesCubit extends Cubit<ScapesState> {
  ScapesCubit({
    required final ScapesRepository repository,
    required final TimerService timerService,
  }) : _repository = repository,
       _timerService = timerService,
       super(const ScapesState()) {
    _loadScapes();
  }

  final ScapesRepository _repository;
  final TimerService _timerService;
  TimerDisposable? _loadDelayHandle;

  void _loadScapes() {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    _loadDelayHandle?.dispose();
    _loadDelayHandle = _timerService.runOnce(
      const Duration(milliseconds: 300),
      () {
        unawaited(_loadScapesFromRepository());
      },
    );
  }

  Future<void> _loadScapesFromRepository() async {
    try {
      final scapes = await _repository.loadScapes();
      if (isClosed) return;
      emit(
        state.copyWith(
          scapes: scapes,
          isLoading: false,
        ),
      );
    } on Object catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void toggleViewMode() {
    final newMode = state.viewMode == ScapesViewMode.grid
        ? ScapesViewMode.list
        : ScapesViewMode.grid;
    emit(state.copyWith(viewMode: newMode));
  }

  void toggleFavorite(final String scapeId) {
    final updatedScapes = state.scapes.map((final scape) {
      if (scape.id == scapeId) {
        return scape.copyWith(isFavorite: !scape.isFavorite);
      }
      return scape;
    }).toList();

    emit(state.copyWith(scapes: updatedScapes));
  }

  void reload() {
    _loadScapes();
  }

  @override
  Future<void> close() {
    _loadDelayHandle?.dispose();
    _loadDelayHandle = null;
    return super.close();
  }
}
