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

    test(
      'accepts unknown status string and ignores unknown top-level keys',
      () {
        final dto = AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
          'id': 'case-1',
          'applicant_name': 'Ada',
          'business_name': 'Engines',
          'amount': 12000,
          'status': 'totally_new_backend_status',
          'last_decision_band': null,
          'unexpected_backend_field': true,
        });
        expect(dto.toDomain().status, 'totally_new_backend_status');
      },
    );

    test('throws FormatException when required field is missing', () {
      expect(
        () => AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
          'id': 'case-1',
          'applicant_name': 'Ada',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when amount is malformed', () {
      expect(
        () => AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
          'id': 'case-1',
          'applicant_name': 'Ada',
          'business_name': 'Engines',
          'amount': 'not-a-number',
          'status': 'review',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-map risk_signals element with FormatException', () {
      expect(
        () => AiDecisionCaseDetailDto.fromJson(<String, dynamic>{
          'case': <String, dynamic>{
            'id': 'c1',
            'status': 'open',
            'created_at': '2026-01-01',
          },
          'risk_signals': <dynamic>['not-a-map'],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('does not include untrusted payload values in parse failures', () {
      const String sensitiveValue = 'customer@example.com';

      expect(
        () => AiDecisionCaseSummaryDto.fromJson(<String, dynamic>{
          'id': 'case-1',
          'applicant_name': 'Ada',
          'business_name': 'Engines',
          'amount': sensitiveValue,
          'status': 'review',
        }),
        throwsA(
          isA<FormatException>().having(
            (final error) => error.message,
            'message',
            allOf(contains('String'), isNot(contains(sensitiveValue))),
          ),
        ),
      );
    });

    test('latest_decision non-map throws without leaking payload', () {
      const String sensitiveValue = 'ssn:123-45-6789';

      expect(
        () => AiDecisionCaseDetailDto.fromJson(<String, dynamic>{
          'case': <String, dynamic>{
            'id': 'c1',
            'status': 'open',
            'created_at': '2026-01-01',
          },
          'latest_decision': sensitiveValue,
        }),
        throwsA(
          isA<FormatException>().having(
            (final error) => error.message,
            'message',
            allOf(
              contains('latest_decision'),
              contains('String'),
              isNot(contains(sensitiveValue)),
            ),
          ),
        ),
      );
    });
  });
}
