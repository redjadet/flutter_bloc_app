import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiDecisionCaseSummaryDto', () {
    test('maps valid JSON to domain', () {
      final AiDecisionCaseSummaryDto dto =
          AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
            'id': 'case-1',
            'applicant_name': 'Ada',
            'business_name': 'Engines',
            'amount': 12000,
            'status': 'review',
            'last_decision_band': 'medium',
          });

      final domain = dto.toDomain();
      expect(domain.id, 'case-1');
      expect(domain.applicantName, 'Ada');
      expect(domain.amount, 12000);
      expect(domain.lastDecisionBand, 'medium');
    });

    test('throws when required field is missing', () {
      expect(
        () => AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
          'id': 'case-1',
          'applicant_name': 'Ada',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when amount is malformed', () {
      expect(
        () => AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
          'id': 'case-1',
          'applicant_name': 'Ada',
          'business_name': 'Engines',
          'amount': 'not-a-number',
          'status': 'review',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
