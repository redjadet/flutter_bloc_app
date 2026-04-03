import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaseStudyDraft codec', () {
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

      final String encoded = CaseStudyDraft.encode(draft);
      final CaseStudyDraft? decoded = CaseStudyDraft.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded, equals(draft));
      expect(decoded!.answers, equals(draft.answers));
    });

    test('decode returns null for null/empty/malformed JSON', () {
      expect(CaseStudyDraft.decode(null), isNull);
      expect(CaseStudyDraft.decode(''), isNull);
      expect(CaseStudyDraft.decode('not-json'), isNull);
    });

    test('decode tolerates unexpected JSON shape with defaults', () {
      final CaseStudyDraft? decoded = CaseStudyDraft.decode(
        '{"not":"a draft"}',
      );
      expect(decoded, isNotNull);
      expect(decoded!.caseId, isEmpty);
      expect(decoded.doctorName, isEmpty);
      expect(decoded.caseType, isNull);
      expect(decoded.answers, isEmpty);
    });

    test('decode tolerates non-string answer values by coercing to string', () {
      final String raw =
          '{"caseId":"c","doctorName":"d","caseType":"implant","notes":"n","answers":{"q1":123},"remoteObjectKeysByQuestion":{"q1":456},"currentQuestionIndex":0,"phase":"metadata"}';

      final CaseStudyDraft? decoded = CaseStudyDraft.decode(raw);

      expect(decoded, isNotNull);
      expect(decoded!.answers['q1'], '123');
      expect(decoded.remoteObjectKeysByQuestion['q1'], '456');
    });
  });

  group('CaseStudyRecord codec', () {
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

        final String encoded = CaseStudyRecord.encodeList(records);
        final List<CaseStudyRecord> decoded = CaseStudyRecord.decodeList(
          encoded,
        );

        expect(decoded, equals(records));
      },
    );

    test('decodeList returns empty list for null/empty/malformed JSON', () {
      expect(CaseStudyRecord.decodeList(null), isEmpty);
      expect(CaseStudyRecord.decodeList(''), isEmpty);
      expect(CaseStudyRecord.decodeList('not-json'), isEmpty);
      expect(CaseStudyRecord.decodeList('{"not":"a list"}'), isEmpty);
    });

    test('decodeList drops invalid entries but keeps valid ones', () {
      final String raw = '''
[
  {"id":"r1","submittedAt":"2026-04-02T00:00:00Z","doctorName":"Dr. Ada","caseType":"implant","notes":"","answers":{"q1":"/tmp/q1.mp4"}},
  {"id":null,"submittedAt":"2026-04-02T00:00:00Z","doctorName":"x","caseType":"implant","notes":"","answers":{}},
  {"id":"r2","submittedAt":"2026-04-03T00:00:00Z","doctorName":"Dr. Bob","caseType":"general","notes":"","answers":{"q2":"/tmp/q2.mp4"}}
]
''';

      final List<CaseStudyRecord> decoded = CaseStudyRecord.decodeList(raw);
      expect(decoded.map((r) => r.id).toList(), <String>['r1', 'r2']);
    });
  });
}
