import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';

/// A submitted (mock-uploaded) case for history.
// check-ignore: freezed_preferred - demo model (kept lightweight)
class CaseStudyRecord extends Equatable {
  const CaseStudyRecord({
    required this.id,
    required this.submittedAt,
    required this.doctorName,
    required this.caseType,
    required this.notes,
    required this.answers,
  });

  final String id;
  final DateTime submittedAt;
  final String doctorName;
  final CaseStudyCaseType caseType;
  final String notes;
  final Map<String, String> answers;

  @override
  List<Object?> get props => <Object?>[
    id,
    submittedAt,
    doctorName,
    caseType,
    notes,
    answers,
  ];
}
