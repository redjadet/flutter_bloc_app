import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_models.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_cubit.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAiDecisionRepository extends Mock implements AiDecisionRepository {}

void main() {
  group('AiDecisionCubit', () {
    late _MockAiDecisionRepository repository;

    setUp(() {
      repository = _MockAiDecisionRepository();
    });

    AiDecisionCubit buildCubit() => AiDecisionCubit(repository: repository);

    final queue = [
      AiDecisionCaseSummary(
        id: 'case_1',
        applicantName: 'A',
        businessName: 'B',
        amount: 1000,
        status: 'new',
        lastDecisionBand: null,
      ),
      AiDecisionCaseSummary(
        id: 'case_2',
        applicantName: 'C',
        businessName: 'D',
        amount: 2000,
        status: 'new',
        lastDecisionBand: null,
      ),
    ];

    final detail = AiDecisionCaseDetail(
      caseId: 'case_1',
      status: 'new',
      createdAt: '2026-04-20T00:00:00Z',
      applicant: const {
        'name': 'A',
        'prior_defaults': 0,
        'personal_credit_score': 700,
      },
      business: const {'name': 'B', 'monthly_revenue': 5000, 'age_months': 36},
      loan: const {'amount': 1000, 'purpose': 'Test'},
      riskSignals: const [],
      actions: const [],
      latestDecision: null,
    );

    final secondDetail = AiDecisionCaseDetail(
      caseId: 'case_2',
      status: 'new',
      createdAt: '2026-04-20T00:00:00Z',
      applicant: const {
        'name': 'C',
        'prior_defaults': 1,
        'personal_credit_score': 610,
      },
      business: const {'name': 'D', 'monthly_revenue': 4000, 'age_months': 18},
      loan: const {'amount': 2000, 'purpose': 'Test 2'},
      riskSignals: const [],
      actions: const [],
      latestDecision: null,
    );

    final highDecision = AiDecisionDecisionResult(
      riskScore: 0.72,
      riskBand: 'high',
      recommendedAction: 'request_docs',
      rationale: 'Because reasons.',
      proof: const {'rule_trace': []},
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'loadQueue emits loading -> queue -> case detail',
      build: () {
        when(repository.getCases).thenAnswer((_) async => queue);
        when(
          () => repository.getCaseDetail('case_1'),
        ).thenAnswer((_) async => detail);
        return buildCubit();
      },
      act: (final cubit) async => cubit.loadQueue(),
      expect: () => [
        isA<AiDecisionState>().having(
          (final s) => s.isLoadingQueue,
          'loading',
          true,
        ),
        isA<AiDecisionState>()
            .having((final s) => s.isLoadingQueue, 'loading', false)
            .having((final s) => s.queue.length, 'queue length', 2)
            .having((final s) => s.selectedCaseId, 'selectedCaseId', 'case_1'),
        // loadCase intermediate emit
        isA<AiDecisionState>().having(
          (final s) => s.selectedCaseId,
          'selectedCaseId',
          'case_1',
        ),
        isA<AiDecisionState>().having(
          (final s) => s.caseDetail?.caseId,
          'caseId',
          'case_1',
        ),
      ],
      verify: (final cubit) {
        verify(repository.getCases).called(1);
        verify(() => repository.getCaseDetail('case_1')).called(1);
      },
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'runDecisionSupport emits running -> decision -> reloads case',
      build: () {
        when(
          () => repository.getCaseDetail('case_1'),
        ).thenAnswer((_) async => detail);
        when(
          () => repository.runDecisionSupport(
            caseId: 'case_1',
            operatorNote: any(named: 'operatorNote'),
          ),
        ).thenAnswer((_) async => highDecision);
        return buildCubit();
      },
      seed: () => AiDecisionState.initial().copyWith(
        isLoadingQueue: false,
        queue: queue,
        selectedCaseId: 'case_1',
        caseDetail: detail,
      ),
      act: (final cubit) async =>
          cubit.runDecisionSupport(operatorNote: 'note'),
      expect: () => [
        isA<AiDecisionState>().having(
          (final s) => s.isRunningDecision,
          'running',
          true,
        ),
        isA<AiDecisionState>()
            .having((final s) => s.isRunningDecision, 'running', false)
            .having((final s) => s.decision?.riskBand, 'band', 'high'),
        // loadCase intermediate emit
        isA<AiDecisionState>().having(
          (final s) => s.selectedCaseId,
          'selectedCaseId',
          'case_1',
        ),
        isA<AiDecisionState>().having(
          (final s) => s.caseDetail?.caseId,
          'reloaded case',
          'case_1',
        ),
      ],
      verify: (final cubit) {
        verify(
          () => repository.runDecisionSupport(
            caseId: 'case_1',
            operatorNote: any(named: 'operatorNote'),
          ),
        ).called(1);
        verify(
          () => repository.getCaseDetail('case_1'),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'loadCase clears stale decision proof for the previously selected case',
      build: () {
        when(
          () => repository.getCaseDetail('case_2'),
        ).thenAnswer((_) async => secondDetail);
        return buildCubit();
      },
      seed: () => AiDecisionState.initial().copyWith(
        isLoadingQueue: false,
        queue: queue,
        selectedCaseId: 'case_1',
        caseDetail: detail,
        decision: highDecision,
      ),
      act: (final cubit) async => cubit.loadCase('case_2'),
      expect: () => [
        isA<AiDecisionState>()
            .having((final s) => s.selectedCaseId, 'selectedCaseId', 'case_2')
            .having((final s) => s.caseDetail, 'caseDetail', isNull)
            .having((final s) => s.decision, 'decision', isNull),
        isA<AiDecisionState>()
            .having((final s) => s.caseDetail?.caseId, 'caseId', 'case_2')
            .having((final s) => s.decision, 'decision', isNull),
      ],
      verify: (final cubit) {
        verify(() => repository.getCaseDetail('case_2')).called(1);
      },
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'saveAction emits saving -> not saving -> reloads case',
      build: () {
        when(
          () => repository.createAction(
            caseId: 'case_1',
            actionType: any(named: 'actionType'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => repository.getCaseDetail('case_1'),
        ).thenAnswer((_) async => detail);
        return buildCubit();
      },
      seed: () => AiDecisionState.initial().copyWith(
        isLoadingQueue: false,
        queue: queue,
        selectedCaseId: 'case_1',
        caseDetail: detail,
      ),
      act: (final cubit) async =>
          cubit.saveAction(actionType: 'approve', note: 'ok'),
      expect: () => [
        isA<AiDecisionState>().having(
          (final s) => s.isSavingAction,
          'saving',
          true,
        ),
        isA<AiDecisionState>().having(
          (final s) => s.isSavingAction,
          'saving',
          false,
        ),
        // loadCase intermediate emit
        isA<AiDecisionState>().having(
          (final s) => s.selectedCaseId,
          'selectedCaseId',
          'case_1',
        ),
        isA<AiDecisionState>().having(
          (final s) => s.caseDetail?.caseId,
          'reloaded case',
          'case_1',
        ),
      ],
      verify: (final cubit) {
        verify(
          () => repository.createAction(
            caseId: 'case_1',
            actionType: 'approve',
            note: 'ok',
          ),
        ).called(1);
      },
    );
  });
}
