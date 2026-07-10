import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_failure.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_state.dart';

class AiDecisionCubit extends Cubit<AiDecisionState> {
  AiDecisionCubit({required this.repository})
    : super(AiDecisionState.initial());

  final AiDecisionRepository repository;

  AiDecisionFailure _failure(final Object error) => AiDecisionFailure.load(
    message: NetworkErrorMapper.getErrorMessage(error),
    cause: error,
  );

  void _safeEmit(final AiDecisionState next) {
    if (isClosed) return;
    emit(next);
  }

  Future<void> loadQueue() async {
    _safeEmit(state.copyWith(isLoadingQueue: true, failure: null));
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
        state.copyWith(
          isLoadingQueue: false,
          failure: _failure(e),
        ),
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
        caseDetail: null,
        decision: preserveDecision ? state.decision : null,
        failure: null,
      ),
    );
    try {
      final detail = await repository.getCaseDetail(caseId);
      _safeEmit(state.copyWith(caseDetail: detail));
    } on Object catch (e) {
      _safeEmit(state.copyWith(failure: _failure(e)));
    }
  }

  Future<void> runDecisionSupport({required final String operatorNote}) async {
    final caseId = state.selectedCaseId;
    if (caseId == null) return;
    _safeEmit(state.copyWith(isRunningDecision: true, failure: null));
    try {
      final result = await repository.runDecisionSupport(
        caseId: caseId,
        operatorNote: operatorNote,
      );
      _safeEmit(state.copyWith(isRunningDecision: false, decision: result));
      await loadCase(caseId, preserveDecision: true);
    } on Object catch (e) {
      _safeEmit(
        state.copyWith(
          isRunningDecision: false,
          failure: _failure(e),
        ),
      );
    }
  }

  Future<void> saveAction({
    required final String actionType,
    required final String note,
  }) async {
    final caseId = state.selectedCaseId;
    if (caseId == null) return;
    _safeEmit(state.copyWith(isSavingAction: true, failure: null));
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
        state.copyWith(
          isSavingAction: false,
          failure: _failure(e),
        ),
      );
    }
  }
}
