import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';
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
      applicant: const AiDecisionApplicant(
        name: 'A',
        priorDefaults: 0,
        personalCreditScore: 700,
      ),
      business: const AiDecisionBusiness(
        name: 'B',
        monthlyRevenue: 5000,
        ageMonths: 36,
      ),
      loan: const AiDecisionLoan(amount: 1000, purpose: 'Test'),
      riskSignals: const <AiDecisionRiskSignal>[],
      actions: const <AiDecisionActionRecord>[],
      latestDecision: null,
    );

    final secondDetail = AiDecisionCaseDetail(
      caseId: 'case_2',
      status: 'new',
      createdAt: '2026-04-20T00:00:00Z',
      applicant: const AiDecisionApplicant(
        name: 'C',
        priorDefaults: 1,
        personalCreditScore: 610,
      ),
      business: const AiDecisionBusiness(
        name: 'D',
        monthlyRevenue: 4000,
        ageMonths: 18,
      ),
      loan: const AiDecisionLoan(amount: 2000, purpose: 'Test 2'),
      riskSignals: const <AiDecisionRiskSignal>[],
      actions: const <AiDecisionActionRecord>[],
      latestDecision: null,
    );

    final highDecision = AiDecisionDecisionResult(
      riskScore: 0.72,
      riskBand: 'high',
      recommendedAction: 'request_docs',
      rationale: 'Because reasons.',
      proof: const AiDecisionProof(),
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'loadQueue maps Dio connection errors to user-friendly copy',
      build: () {
        when(repository.getCases).thenThrow(
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/cases'),
            reason: 'XMLHttpRequest onError callback was called',
          ),
        );
        return buildCubit();
      },
      act: (cubit) async => cubit.loadQueue(),
      expect: () => [
        isA<AiDecisionState>().having((s) => s.isLoadingQueue, 'loading', true),
        isA<AiDecisionState>()
            .having((s) => s.isLoadingQueue, 'loading', false)
            .having(
              (s) => s.failure?.displayMessage,
              'failure.displayMessage',
              'Network connection error. Please check your internet connection.',
            ),
      ],
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'loadQueue emits loading -> queue -> case detail',
      build: () {
        when(repository.getCases).thenAnswer((_) async => queue);
        when(() => repository.getCaseDetail('case_1'))
            .thenAnswer((_) async => detail);
        return buildCubit();
      },
      act: (cubit) async => cubit.loadQueue(),
      expect: () => [
        isA<AiDecisionState>().having((s) => s.isLoadingQueue, 'loading', true),
        isA<AiDecisionState>()
            .having((s) => s.isLoadingQueue, 'loading', false)
            .having((s) => s.queue.length, 'queue length', 2)
            .having((s) => s.selectedCaseId, 'selectedCaseId', 'case_1'),
        isA<AiDecisionState>().having(
          (s) => s.caseDetail?.caseId,
          'caseId',
          'case_1',
        ),
      ],
      verify: (cubit) {
        verify(repository.getCases).called(1);
        verify(() => repository.getCaseDetail('case_1')).called(1);
      },
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'runDecisionSupport emits running -> decision -> reloads case',
      build: () {
        when(() => repository.getCaseDetail('case_1'))
            .thenAnswer((_) async => detail);
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
      act: (cubit) async => cubit.runDecisionSupport(operatorNote: 'note'),
      expect: () => [
        isA<AiDecisionState>().having(
          (s) => s.isRunningDecision,
          'running',
          true,
        ),
        isA<AiDecisionState>()
            .having((s) => s.isRunningDecision, 'running', false)
            .having((s) => s.decision?.riskBand, 'band', 'high'),
        // loadCase intermediate emit
        isA<AiDecisionState>().having(
          (s) => s.selectedCaseId,
          'selectedCaseId',
          'case_1',
        ),
        isA<AiDecisionState>().having(
          (s) => s.caseDetail?.caseId,
          'reloaded case',
          'case_1',
        ),
      ],
      verify: (cubit) {
        verify(
          () => repository.runDecisionSupport(
            caseId: 'case_1',
            operatorNote: any(named: 'operatorNote'),
          ),
        ).called(1);
        verify(() => repository.getCaseDetail('case_1'))
            .called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<AiDecisionCubit, AiDecisionState>(
      'loadCase clears stale decision proof for the previously selected case',
      build: () {
        when(() => repository.getCaseDetail('case_2'))
            .thenAnswer((_) async => secondDetail);
        return buildCubit();
      },
      seed: () => AiDecisionState.initial().copyWith(
        isLoadingQueue: false,
        queue: queue,
        selectedCaseId: 'case_1',
        caseDetail: detail,
        decision: highDecision,
      ),
      act: (cubit) async => cubit.loadCase('case_2'),
      expect: () => [
        isA<AiDecisionState>()
            .having((s) => s.selectedCaseId, 'selectedCaseId', 'case_2')
            .having((s) => s.caseDetail, 'caseDetail', isNull)
            .having((s) => s.decision, 'decision', isNull),
        isA<AiDecisionState>()
            .having((s) => s.caseDetail?.caseId, 'caseId', 'case_2')
            .having((s) => s.decision, 'decision', isNull),
      ],
      verify: (cubit) {
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
        when(() => repository.getCaseDetail('case_1'))
            .thenAnswer((_) async => detail);
        return buildCubit();
      },
      seed: () => AiDecisionState.initial().copyWith(
        isLoadingQueue: false,
        queue: queue,
        selectedCaseId: 'case_1',
        caseDetail: detail,
      ),
      act: (cubit) async => cubit.saveAction(actionType: 'approve', note: 'ok'),
      expect: () => [
        isA<AiDecisionState>().having((s) => s.isSavingAction, 'saving', true),
        isA<AiDecisionState>().having((s) => s.isSavingAction, 'saving', false),
        // loadCase intermediate emit
        isA<AiDecisionState>().having(
          (s) => s.selectedCaseId,
          'selectedCaseId',
          'case_1',
        ),
        isA<AiDecisionState>().having(
          (s) => s.caseDetail?.caseId,
          'reloaded case',
          'case_1',
        ),
      ],
      verify: (cubit) {
        verify(
          () => repository.createAction(
            caseId: 'case_1',
            actionType: 'approve',
            note: 'ok',
          ),
        ).called(1);
      },
    );

    test(
      'loadCase: slower older case cannot overwrite newer selection',
      () async {
        final Completer<AiDecisionCaseDetail> first =
            Completer<AiDecisionCaseDetail>();
        final Completer<AiDecisionCaseDetail> second =
            Completer<AiDecisionCaseDetail>();
        when(() => repository.getCaseDetail('case_1'))
            .thenAnswer((_) => first.future);
        when(() => repository.getCaseDetail('case_2'))
            .thenAnswer((_) => second.future);

        final AiDecisionCubit cubit = buildCubit();
        var sawCase1Detail = false;
        final sub = cubit.stream.listen((AiDecisionState state) {
          if (state.caseDetail?.caseId == 'case_1') {
            sawCase1Detail = true;
          }
        });

        final Future<void> loadA = cubit.loadCase('case_1');
        final Future<void> loadB = cubit.loadCase('case_2');

        second.complete(secondDetail);
        await loadB;
        first.complete(detail);
        await loadA;

        expect(cubit.state.selectedCaseId, 'case_2');
        expect(cubit.state.caseDetail?.caseId, 'case_2');
        expect(sawCase1Detail, isFalse);

        await sub.cancel();
        await cubit.close();
      },
    );

    test(
      'loadCase: stale error from older case does not overwrite newer detail',
      () async {
        final Completer<AiDecisionCaseDetail> first =
            Completer<AiDecisionCaseDetail>();
        final Completer<AiDecisionCaseDetail> second =
            Completer<AiDecisionCaseDetail>();
        when(() => repository.getCaseDetail('case_1'))
            .thenAnswer((_) => first.future);
        when(() => repository.getCaseDetail('case_2'))
            .thenAnswer((_) => second.future);

        final AiDecisionCubit cubit = buildCubit();
        final Future<void> loadA = cubit.loadCase('case_1');
        final Future<void> loadB = cubit.loadCase('case_2');

        second.complete(secondDetail);
        await loadB;
        first.completeError(StateError('stale'));
        await loadA;

        expect(cubit.state.selectedCaseId, 'case_2');
        expect(cubit.state.caseDetail?.caseId, 'case_2');
        expect(cubit.state.failure, isNull);

        await cubit.close();
      },
    );

    test(
      'runDecisionSupport: result dropped when selection changes mid-flight',
      () async {
        final Completer<AiDecisionDecisionResult> decision =
            Completer<AiDecisionDecisionResult>();
        when(
          () => repository.runDecisionSupport(
            caseId: 'case_1',
            operatorNote: any(named: 'operatorNote'),
          ),
        ).thenAnswer((_) => decision.future);
        when(() => repository.getCaseDetail('case_2'))
            .thenAnswer((_) async => secondDetail);

        final AiDecisionCubit cubit = buildCubit();
        // ignore: invalid_use_of_protected_member
        cubit.emit(
          AiDecisionState.initial().copyWith(
            isLoadingQueue: false,
            queue: queue,
            selectedCaseId: 'case_1',
            caseDetail: detail,
          ),
        );

        final Future<void> running = cubit.runDecisionSupport(
          operatorNote: 'note',
        );
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.isRunningDecision, isTrue);
        await cubit.loadCase('case_2');
        expect(cubit.state.isRunningDecision, isFalse);
        decision.complete(highDecision);
        await running;

        expect(cubit.state.selectedCaseId, 'case_2');
        expect(cubit.state.caseDetail?.caseId, 'case_2');
        expect(cubit.state.decision, isNull);
        expect(cubit.state.isRunningDecision, isFalse);

        await cubit.close();
      },
    );

    test(
      'saveAction: success dropped when selection changes mid-flight',
      () async {
        final Completer<void> save = Completer<void>();
        when(
          () => repository.createAction(
            caseId: 'case_1',
            actionType: any(named: 'actionType'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) => save.future);
        when(() => repository.getCaseDetail('case_2'))
            .thenAnswer((_) async => secondDetail);

        final AiDecisionCubit cubit = buildCubit();
        // ignore: invalid_use_of_protected_member
        cubit.emit(
          AiDecisionState.initial().copyWith(
            isLoadingQueue: false,
            queue: queue,
            selectedCaseId: 'case_1',
            caseDetail: detail,
          ),
        );

        final Future<void> saving = cubit.saveAction(
          actionType: 'approve',
          note: 'ok',
        );
        await cubit.loadCase('case_2');
        save.complete();
        await saving;

        expect(cubit.state.selectedCaseId, 'case_2');
        expect(cubit.state.isSavingAction, isFalse);
        verifyNever(() => repository.getCaseDetail('case_1'));

        await cubit.close();
      },
    );

    test(
      'same-case concurrent decision+save: both complete and refresh',
      () async {
        final Completer<AiDecisionDecisionResult> decision =
            Completer<AiDecisionDecisionResult>();
        final Completer<void> save = Completer<void>();
        final AiDecisionCaseDetail detailAfterSave = AiDecisionCaseDetail(
          caseId: 'case_1',
          status: 'approved',
          createdAt: '2026-04-20T00:00:00Z',
          applicant: detail.applicant,
          business: detail.business,
          loan: detail.loan,
          riskSignals: detail.riskSignals,
          actions: const <AiDecisionActionRecord>[
            AiDecisionActionRecord(actionType: 'approve', note: 'ok'),
          ],
          latestDecision: null,
        );

        when(
          () => repository.runDecisionSupport(
            caseId: 'case_1',
            operatorNote: any(named: 'operatorNote'),
          ),
        ).thenAnswer((_) => decision.future);
        when(
          () => repository.createAction(
            caseId: 'case_1',
            actionType: any(named: 'actionType'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) => save.future);
        when(() => repository.getCaseDetail('case_1'))
            .thenAnswer((_) async => detailAfterSave);

        final AiDecisionCubit cubit = buildCubit();
        // ignore: invalid_use_of_protected_member
        cubit.emit(
          AiDecisionState.initial().copyWith(
            isLoadingQueue: false,
            queue: queue,
            selectedCaseId: 'case_1',
            caseDetail: detail,
          ),
        );

        final Future<void> running = cubit.runDecisionSupport(
          operatorNote: 'note',
        );
        final Future<void> saving = cubit.saveAction(
          actionType: 'approve',
          note: 'ok',
        );
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.isRunningDecision, isTrue);
        expect(cubit.state.isSavingAction, isTrue);

        // Decision finishes first and refreshes same case — must not kill save.
        decision.complete(highDecision);
        await running;
        expect(cubit.state.decision?.riskBand, 'high');
        expect(cubit.state.isSavingAction, isTrue);

        save.complete();
        await saving;

        expect(cubit.state.isRunningDecision, isFalse);
        expect(cubit.state.isSavingAction, isFalse);
        expect(cubit.state.decision?.riskBand, 'high');
        expect(cubit.state.caseDetail?.status, 'approved');
        expect(cubit.state.caseDetail?.actions, isNotEmpty);
        verify(() => repository.getCaseDetail('case_1'))
            .called(greaterThanOrEqualTo(1));

        await cubit.close();
      },
    );
  });
}
