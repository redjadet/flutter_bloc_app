import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_failure.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_state.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';

class AiDecisionCubit extends Cubit<AiDecisionState> {
  new({required this.repository}) : super(AiDecisionState.initial());

  final AiDecisionRepository repository;
  final RequestIdGuard _queueGuard = RequestIdGuard();
  final RequestIdGuard _caseGuard = RequestIdGuard();
  final RequestIdGuard _decisionGuard = RequestIdGuard();
  final RequestIdGuard _saveGuard = RequestIdGuard();

  AiDecisionFailure _failure(Object error) => AiDecisionFailure.load(
    message: NetworkErrorMapper.getErrorMessage(error),
    cause: error,
  );

  void _safeEmit(AiDecisionState next) {
    if (isClosed) return;
    emit(next);
  }

  bool _isCaseCurrent(int requestId, String caseId) =>
      !isClosed &&
      _caseGuard.isCurrent(requestId) &&
      state.selectedCaseId == caseId;

  Future<void> loadQueue() async {
    final int queueRequestId = _queueGuard.next();
    // Supersede in-flight case/decision/save so stale writers cannot mutate
    // after a fresh queue load owns selection.
    _caseGuard.next();
    _decisionGuard.next();
    _saveGuard.next();
    _safeEmit(
      state.copyWith(
        isLoadingQueue: true,
        failure: null,
        isRunningDecision: false,
        isSavingAction: false,
      ),
    );
    try {
      final queue = await repository.getCases();
      if (isClosed || !_queueGuard.isCurrent(queueRequestId)) {
        return;
      }
      final selected = queue.isNotEmpty ? queue.first.id : null;
      _safeEmit(
        state.copyWith(
          isLoadingQueue: false,
          queue: queue,
          selectedCaseId: selected,
          caseDetail: null,
          decision: null,
        ),
      );
      if (selected != null && _queueGuard.isCurrent(queueRequestId)) {
        await loadCase(selected);
      }
    } on Object catch (e) {
      if (isClosed || !_queueGuard.isCurrent(queueRequestId)) {
        return;
      }
      _safeEmit(state.copyWith(isLoadingQueue: false, failure: _failure(e)));
    }
  }

  Future<void> loadCase(String caseId, {bool preserveDecision = false}) async {
    final bool selectionChanged = state.selectedCaseId != caseId;
    final int requestId = _caseGuard.next();
    // Only selection/queue changes supersede in-flight decision/save.
    // Same-case refresh after a mutation must not discard a concurrent sibling.
    if (selectionChanged) {
      _decisionGuard.next();
      _saveGuard.next();
    }
    _safeEmit(
      state.copyWith(
        selectedCaseId: caseId,
        caseDetail: null,
        decision: preserveDecision ? state.decision : null,
        failure: null,
        isRunningDecision: !selectionChanged && state.isRunningDecision,
        isSavingAction: !selectionChanged && state.isSavingAction,
      ),
    );
    try {
      final detail = await repository.getCaseDetail(caseId);
      if (!_isCaseCurrent(requestId, caseId)) {
        return;
      }
      _safeEmit(state.copyWith(caseDetail: detail));
    } on Object catch (e) {
      if (!_isCaseCurrent(requestId, caseId)) {
        return;
      }
      _safeEmit(state.copyWith(failure: _failure(e)));
    }
  }

  Future<void> runDecisionSupport({required String operatorNote}) async {
    final caseId = state.selectedCaseId;
    if (caseId == null) return;
    final int requestId = _decisionGuard.next();
    _safeEmit(state.copyWith(isRunningDecision: true, failure: null));
    try {
      final result = await repository.runDecisionSupport(
        caseId: caseId,
        operatorNote: operatorNote,
      );
      if (isClosed || !_decisionGuard.isCurrent(requestId)) {
        return;
      }
      if (state.selectedCaseId != caseId) {
        _safeEmit(state.copyWith(isRunningDecision: false));
        return;
      }
      _safeEmit(state.copyWith(isRunningDecision: false, decision: result));
      await loadCase(caseId, preserveDecision: true);
    } on Object catch (e) {
      if (isClosed || !_decisionGuard.isCurrent(requestId)) {
        return;
      }
      if (state.selectedCaseId != caseId) {
        _safeEmit(state.copyWith(isRunningDecision: false));
        return;
      }
      _safeEmit(state.copyWith(isRunningDecision: false, failure: _failure(e)));
    }
  }

  Future<void> saveAction({
    required String actionType,
    required String note,
  }) async {
    final caseId = state.selectedCaseId;
    if (caseId == null) return;
    final int requestId = _saveGuard.next();
    _safeEmit(state.copyWith(isSavingAction: true, failure: null));
    try {
      await repository.createAction(
        caseId: caseId,
        actionType: actionType,
        note: note,
      );
      if (isClosed || !_saveGuard.isCurrent(requestId)) {
        return;
      }
      if (state.selectedCaseId != caseId) {
        _safeEmit(state.copyWith(isSavingAction: false));
        return;
      }
      _safeEmit(state.copyWith(isSavingAction: false));
      await loadCase(caseId, preserveDecision: true);
    } on Object catch (e) {
      if (isClosed || !_saveGuard.isCurrent(requestId)) {
        return;
      }
      if (state.selectedCaseId != caseId) {
        _safeEmit(state.copyWith(isSavingAction: false));
        return;
      }
      _safeEmit(state.copyWith(isSavingAction: false, failure: _failure(e)));
    }
  }
}
