import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_models.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/pages/ai_decision_demo_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

class _MockAiDecisionRepository extends Mock implements AiDecisionRepository {}

void main() {
  testWidgets('AiDecisionDemoPage renders proof DataTable after decision', (
    final tester,
  ) async {
    final repository = _MockAiDecisionRepository();

    final queue = <AiDecisionCaseSummary>[
      AiDecisionCaseSummary(
        id: 'case_1',
        applicantName: 'A',
        businessName: 'B',
        amount: 1000,
        status: 'new',
        lastDecisionBand: null,
      ),
    ];

    final detail = AiDecisionCaseDetail(
      caseId: 'case_1',
      status: 'new',
      createdAt: '2026-04-20T00:00:00Z',
      applicant: const {
        'id': 'app_1',
        'name': 'A',
        'personal_credit_score': 610,
        'prior_defaults': 1,
      },
      business: const {
        'id': 'biz_1',
        'name': 'B',
        'industry': 'retail',
        'monthly_revenue': 4000,
        'age_months': 18,
      },
      loan: const {'amount': 15000, 'purpose': 'Inventory expansion'},
      riskSignals: const [
        {
          'key': 'prior_default',
          'label': 'Prior defaults',
          'value': '1',
          'severity': 'high',
        },
      ],
      actions: const [],
      latestDecision: null,
    );

    final decision = AiDecisionDecisionResult(
      riskScore: 0.72,
      riskBand: 'high',
      recommendedAction: 'request_docs',
      rationale: 'Prior default and amount/revenue ratio drive the score.',
      proof: const {
        'rule_trace': [
          {
            'id': 'prior_defaults',
            'label': 'Prior defaults',
            'passed': true,
            'contribution': 0.25,
            'evidence': 'Applicant has 1 prior default',
          },
        ],
      },
    );

    when(repository.getCases).thenAnswer((_) async => queue);
    when(() => repository.getCaseDetail(any())).thenAnswer((_) async => detail);
    when(
      () => repository.runDecisionSupport(
        caseId: any(named: 'caseId'),
        operatorNote: any(named: 'operatorNote'),
      ),
    ).thenAnswer((_) async => decision);

    await getIt.reset();
    getIt.registerSingleton<AiDecisionRepository>(repository);

    await tester.pumpWidget(
      wrapWithProviders(child: const AiDecisionDemoPage()),
    );

    await tester.pumpAndSettle();

    final runButton = find.text('Run decision support');
    expect(runButton, findsOneWidget);

    await tester.tap(runButton);
    await tester.pumpAndSettle();

    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('Action: request_docs'), findsOneWidget);

    // The proof section sits below the fold in the workbench ListView.
    await tester.scrollUntilVisible(
      find.text('Proof'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Proof'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);
    expect(find.text('Rule'), findsOneWidget);
    expect(find.text('Contrib'), findsOneWidget);
  });
}
