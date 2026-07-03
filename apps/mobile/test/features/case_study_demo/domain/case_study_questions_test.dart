import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaseStudyQuestions.isCompleteAnswers', () {
    test('false when map is empty', () {
      expect(CaseStudyQuestions.isCompleteAnswers(<String, String>{}), isFalse);
    });

    test('false when one key missing', () {
      final Map<String, String> partial = <String, String>{
        for (int i = 1; i <= 9; i++) 'q$i': '/p$i',
      };
      expect(CaseStudyQuestions.isCompleteAnswers(partial), isFalse);
    });

    test('false when path empty', () {
      final Map<String, String> map = <String, String>{
        for (final String id in CaseStudyQuestions.orderedIds) id: '/x',
      };
      map['q5'] = '  ';
      expect(CaseStudyQuestions.isCompleteAnswers(map), isFalse);
    });

    test('true when all ten non-empty paths', () {
      final Map<String, String> map = <String, String>{
        for (final String id in CaseStudyQuestions.orderedIds) id: '/v/$id',
      };
      expect(CaseStudyQuestions.isCompleteAnswers(map), isTrue);
    });
  });
}
