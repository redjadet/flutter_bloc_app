/// Fixed question ids for the 10-step wizard (q1–q10 only).
typedef CaseStudyQuestionId = String;

/// Canonical question ordering for the dentist case-study demo.
class CaseStudyQuestions {
  CaseStudyQuestions._();

  static const List<CaseStudyQuestionId> orderedIds = <CaseStudyQuestionId>[
    'q1',
    'q2',
    'q3',
    'q4',
    'q5',
    'q6',
    'q7',
    'q8',
    'q9',
    'q10',
  ];

  static Set<CaseStudyQuestionId> get idSet => orderedIds.toSet();

  static bool isCompleteAnswers(
    final Map<CaseStudyQuestionId, String> answers,
  ) {
    if (answers.length != orderedIds.length) return false;
    for (final CaseStudyQuestionId id in orderedIds) {
      final String? p = answers[id];
      if (p == null || p.trim().isEmpty) return false;
    }
    return true;
  }
}
