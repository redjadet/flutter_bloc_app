import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_draft_dto.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_record_dto.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaseStudyDraftDto codec', () {
    test('encode/decode round-trips', () {
      final CaseStudyDraft draft = CaseStudyDraft(
        caseId: 'case-1',
        doctorName: 'Dr. Ada',
        caseType: CaseStudyCaseType.implant,
        notes: 'note',
        answers: <String, String>{
          for (final CaseStudyQuestionId id in CaseStudyQuestions.orderedIds)
            id: '/tmp/$id.mp4',
        },
        remoteObjectKeysByQuestion: const <String, String>{
          'q1': 'user/u1/case/case-1/question/q1/clip-1.mp4',
        },
        currentQuestionIndex: 3,
        phase: CaseStudyDraftPhase.recording,
      );

      final String encoded = CaseStudyDraftDto.encode(draft);
      final CaseStudyDraft? decoded = CaseStudyDraftDto.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded, equals(draft));
      expect(decoded!.answers, equals(draft.answers));
    });

    test('decode returns null for null/empty/malformed JSON', () {
      expect(CaseStudyDraftDto.decode(null), isNull);
      expect(CaseStudyDraftDto.decode(''), isNull);
      expect(CaseStudyDraftDto.decode('not-json'), isNull);
    });

    test('decode tolerates unexpected JSON shape with defaults', () {
      final CaseStudyDraft? decoded = CaseStudyDraftDto.decode(
        '{"not":"a draft"}',
      );
      expect(decoded, isNotNull);
      expect(decoded!.caseId, isEmpty);
      expect(decoded.doctorName, isEmpty);
      expect(decoded.caseType, isNull);
      expect(decoded.answers, isEmpty);
    });

    test('decode tolerates non-string answer values by coercing to string', () {
      const String raw =
          '{"caseId":"c","doctorName":"d","caseType":"implant","notes":"n","answers":{"q1":123},"remoteObjectKeysByQuestion":{"q1":456},"currentQuestionIndex":0,"phase":"metadata"}';

      final CaseStudyDraft? decoded = CaseStudyDraftDto.decode(raw);

      expect(decoded, isNotNull);
      expect(decoded!.answers['q1'], '123');
      expect(decoded.remoteObjectKeysByQuestion['q1'], '456');
    });
  });

  group('CaseStudyRecordDto codec', () {
    test(
      'encodeList/decodeList round-trips (stable enough for Hive storage)',
      () {
        final List<CaseStudyRecord> records = <CaseStudyRecord>[
          CaseStudyRecord(
            id: 'r1',
            submittedAt: DateTime.parse('2026-04-02T00:00:00Z'),
            doctorName: 'Dr. Ada',
            caseType: CaseStudyCaseType.implant,
            notes: 'n1',
            answers: <String, String>{'q1': '/tmp/q1.mp4'},
          ),
          CaseStudyRecord(
            id: 'r2',
            submittedAt: DateTime.parse('2026-04-03T00:00:00Z'),
            doctorName: 'Dr. Bob',
            caseType: CaseStudyCaseType.general,
            notes: 'n2',
            answers: <String, String>{'q2': '/tmp/q2.mp4'},
          ),
        ];

        final String encoded = CaseStudyRecordDto.encodeList(records);
        final List<CaseStudyRecord> decoded = CaseStudyRecordDto.decodeList(
          encoded,
        );

        expect(decoded, equals(records));
      },
    );

    test('decodeList returns empty list for null/empty/malformed JSON', () {
      expect(CaseStudyRecordDto.decodeList(null), isEmpty);
      expect(CaseStudyRecordDto.decodeList(''), isEmpty);
      expect(CaseStudyRecordDto.decodeList('not-json'), isEmpty);
      expect(CaseStudyRecordDto.decodeList('{"not":"a list"}'), isEmpty);
    });

    test('decodeList drops invalid entries but keeps valid ones', () {
      const String raw = '''
[
  {"id":"r1","submittedAt":"2026-04-02T00:00:00Z","doctorName":"Dr. Ada","caseType":"implant","notes":"","answers":{"q1":"/tmp/q1.mp4"}},
  {"id":null,"submittedAt":"2026-04-02T00:00:00Z","doctorName":"x","caseType":"implant","notes":"","answers":{}},
  {"id":"r2","submittedAt":"2026-04-03T00:00:00Z","doctorName":"Dr. Bob","caseType":"general","notes":"","answers":{"q2":"/tmp/q2.mp4"}}
]
''';

      final List<CaseStudyRecord> decoded = CaseStudyRecordDto.decodeList(raw);
      expect(decoded.map((final r) => r.id).toList(), <String>['r1', 'r2']);
    });
  });
}
