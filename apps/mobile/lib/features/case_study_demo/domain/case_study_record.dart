import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';

/// A submitted (mock-uploaded) case for history.
// check-ignore: freezed_preferred - demo model (kept lightweight)
class const CaseStudyRecord({
  required final String id,
  required final DateTime submittedAt,
  required final String doctorName,
  required final CaseStudyCaseType caseType,
  required final String notes,
  required final Map<String, String> answers,
}) extends Equatable {
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
