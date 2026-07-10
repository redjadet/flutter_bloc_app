import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiDecisionDecisionResultDto', () {
    test('maps JSON to domain', () {
      final AiDecisionDecisionResultDto dto =
          AiDecisionDecisionResultDto.fromJson(<String, dynamic>{
            'risk_score': 0.42,
            'risk_band': 'medium',
            'recommended_action': 'review',
            'rationale': 'mixed signals',
            'proof': <String, dynamic>{'model': 'v1'},
          });

      final domain = dto.toDomain();
      expect(domain.riskScore, 0.42);
      expect(domain.riskBand, 'medium');
      expect(domain.recommendedAction, 'review');
      expect(domain.rationale, 'mixed signals');
      expect(domain.proof.extras['model'], 'v1');
    });
  });

  group('AiDecisionCaseDetailDto', () {
    test('maps nested case JSON with latest decision', () {
      final AiDecisionCaseDetailDto dto = AiDecisionCaseDetailDto.fromJson(
        <String, dynamic>{
          'case': <String, dynamic>{
            'id': 'c-9',
            'status': 'open',
            'created_at': '2026-01-01T00:00:00Z',
          },
          'applicant': <String, dynamic>{'name': 'Ada'},
          'business': <String, dynamic>{'name': 'Engines'},
          'loan': <String, dynamic>{'amount': 1000},
          'risk_signals': <dynamic>[
            <String, dynamic>{'code': 'late_pay'},
          ],
          'actions': <dynamic>[
            <String, dynamic>{'type': 'note'},
          ],
          'latest_decision': <String, dynamic>{
            'risk_score': 0.1,
            'risk_band': 'low',
            'recommended_action': 'approve',
            'rationale': 'ok',
            'proof': <String, dynamic>{},
          },
        },
      );

      final domain = dto.toDomain();
      expect(domain.caseId, 'c-9');
      expect(domain.status, 'open');
      expect(domain.createdAt, '2026-01-01T00:00:00Z');
      expect(domain.applicant.name, 'Ada');
      expect(domain.riskSignals, hasLength(1));
      expect(domain.actions, hasLength(1));
      expect(domain.latestDecision?.riskBand, 'low');
    });

    test('allows null latest decision', () {
      final AiDecisionCaseDetailDto dto = AiDecisionCaseDetailDto.fromJson(
        <String, dynamic>{
          'case': <String, dynamic>{
            'id': 'c-1',
            'status': 'new',
            'created_at': '2026-02-01T00:00:00Z',
          },
          'applicant': <String, dynamic>{},
          'business': <String, dynamic>{},
          'loan': <String, dynamic>{},
          'risk_signals': <dynamic>[],
          'actions': <dynamic>[],
          'latest_decision': null,
        },
      );

      expect(dto.toDomain().latestDecision, isNull);
    });
  });
}
