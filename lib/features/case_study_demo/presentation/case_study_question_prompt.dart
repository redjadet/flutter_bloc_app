import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String caseStudyQuestionPrompt(
  final AppLocalizations l10n,
  final CaseStudyQuestionId id,
) {
  switch (id) {
    case 'q1':
      return l10n.caseStudyQuestion1;
    case 'q2':
      return l10n.caseStudyQuestion2;
    case 'q3':
      return l10n.caseStudyQuestion3;
    case 'q4':
      return l10n.caseStudyQuestion4;
    case 'q5':
      return l10n.caseStudyQuestion5;
    case 'q6':
      return l10n.caseStudyQuestion6;
    case 'q7':
      return l10n.caseStudyQuestion7;
    case 'q8':
      return l10n.caseStudyQuestion8;
    case 'q9':
      return l10n.caseStudyQuestion9;
    case 'q10':
      return l10n.caseStudyQuestion10;
    default:
      return id;
  }
}
