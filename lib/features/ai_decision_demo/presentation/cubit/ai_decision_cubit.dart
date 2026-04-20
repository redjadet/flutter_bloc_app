import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_state.dart';

class AiDecisionCubit extends Cubit<AiDecisionState> {
  AiDecisionCubit({required this.repository})
    : super(AiDecisionState.initial());

  final AiDecisionRepository repository;

  void _safeEmit(final AiDecisionState next) {
    if (isClosed) return;
    emit(next);
  }

  Future<void> loadQueue() async {
    _safeEmit(state.copyWith(isLoadingQueue: true, clearError: true));
    try {
      final queue = await repository.getCases();
      final selected = queue.isNotEmpty ? queue.first.id : null;
      _safeEmit(
        state.copyWith(
          isLoadingQueue: false,
          queue: queue,
          selectedCaseId: selected,
        ),
      );
      if (selected != null) {
        await loadCase(selected);
      }
    } on Object catch (e) {
      _safeEmit(
        state.copyWith(isLoadingQueue: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadCase(
    final String caseId, {
    final bool preserveDecision = false,
  }) async {
    _safeEmit(
      state.copyWith(
        selectedCaseId: caseId,
        clearCaseDetail: true,
        clearDecision: !preserveDecision,
        clearError: true,
      ),
    );
    try {
      final detail = await repository.getCaseDetail(caseId);
      _safeEmit(state.copyWith(caseDetail: detail));
    } on Object catch (e) {
      _safeEmit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> runDecisionSupport({required final String operatorNote}) async {
    final caseId = state.selectedCaseId;
    if (caseId == null) return;
    _safeEmit(state.copyWith(isRunningDecision: true, clearError: true));
    try {
      final result = await repository.runDecisionSupport(
        caseId: caseId,
        operatorNote: operatorNote,
      );
      _safeEmit(state.copyWith(isRunningDecision: false, decision: result));
      await loadCase(caseId, preserveDecision: true);
    } on Object catch (e) {
      _safeEmit(
        state.copyWith(isRunningDecision: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> saveAction({
    required final String actionType,
    required final String note,
  }) async {
    final caseId = state.selectedCaseId;
    if (caseId == null) return;
    _safeEmit(state.copyWith(isSavingAction: true, clearError: true));
    try {
      await repository.createAction(
        caseId: caseId,
        actionType: actionType,
        note: note,
      );
      _safeEmit(state.copyWith(isSavingAction: false));
      await loadCase(caseId, preserveDecision: true);
    } on Object catch (e) {
      _safeEmit(
        state.copyWith(isSavingAction: false, errorMessage: e.toString()),
      );
    }
  }
}
