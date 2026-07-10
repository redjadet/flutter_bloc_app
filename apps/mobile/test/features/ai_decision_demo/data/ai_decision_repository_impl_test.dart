import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements AiDecisionApiClient {}

void main() {
  late _MockApi api;
  late AiDecisionRepositoryImpl repository;

  setUp(() {
    api = _MockApi();
    repository = AiDecisionRepositoryImpl(api: api);
  });

  test('delegates getCases', () async {
    when(() => api.getCases()).thenAnswer(
      (_) async => <AiDecisionCaseSummary>[
        AiDecisionCaseSummary(
          id: '1',
          applicantName: 'A',
          businessName: 'B',
          amount: 1,
          status: 'open',
          lastDecisionBand: null,
        ),
      ],
    );

    final List<AiDecisionCaseSummary> cases = await repository.getCases();
    expect(cases, hasLength(1));
    verify(() => api.getCases()).called(1);
  });

  test('delegates getCaseDetail', () async {
    final AiDecisionCaseDetail detail = AiDecisionCaseDetail(
      caseId: '1',
      status: 'open',
      createdAt: 't',
      applicant: const AiDecisionApplicant(name: ''),
      business: const AiDecisionBusiness(name: ''),
      loan: const AiDecisionLoan(amount: 0, purpose: ''),
      riskSignals: const <AiDecisionRiskSignal>[],
      actions: const <AiDecisionActionRecord>[],
      latestDecision: null,
    );
    when(() => api.getCaseDetail('1')).thenAnswer((_) async => detail);

    expect(await repository.getCaseDetail('1'), detail);
    verify(() => api.getCaseDetail('1')).called(1);
  });

  test('delegates runDecisionSupport', () async {
    final AiDecisionDecisionResult result = AiDecisionDecisionResult(
      riskScore: 0.2,
      riskBand: 'low',
      recommendedAction: 'approve',
      rationale: 'ok',
      proof: const AiDecisionProof(),
    );
    when(
      () => api.runDecisionSupport(caseId: '1', operatorNote: 'n'),
    ).thenAnswer((_) async => result);

    expect(
      await repository.runDecisionSupport(caseId: '1', operatorNote: 'n'),
      result,
    );
  });

  test('delegates createAction', () async {
    when(
      () => api.createAction(caseId: '1', actionType: 'note', note: 'hi'),
    ).thenAnswer((_) async {});

    await repository.createAction(caseId: '1', actionType: 'note', note: 'hi');
    verify(
      () => api.createAction(caseId: '1', actionType: 'note', note: 'hi'),
    ).called(1);
  });
}
