import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_dto_mappers.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

export 'ai_decision_dto_mappers.dart';

/// Wire DTO for AI Decision API case queue rows.
class AiDecisionCaseSummaryDto {
  AiDecisionCaseSummaryDto({
    required this.id,
    required this.applicantName,
    required this.businessName,
    required this.amount,
    required this.status,
    required this.lastDecisionBand,
  });

  factory AiDecisionCaseSummaryDto.fromJson(final Map<String, dynamic> json) =>
      AiDecisionCaseSummaryDto(
        id: json['id'] as String,
        applicantName: json['applicant_name'] as String,
        businessName: json['business_name'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: json['status'] as String,
        lastDecisionBand: json['last_decision_band'] as String?,
      );

  final String id;
  final String applicantName;
  final String businessName;
  final double amount;
  final String status;
  final String? lastDecisionBand;

  AiDecisionCaseSummary toDomain() => AiDecisionCaseSummary(
    id: id,
    applicantName: applicantName,
    businessName: businessName,
    amount: amount,
    status: status,
    lastDecisionBand: lastDecisionBand,
  );
}

class AiDecisionDecisionResultDto {
  AiDecisionDecisionResultDto({
    required this.riskScore,
    required this.riskBand,
    required this.recommendedAction,
    required this.rationale,
    required this.proof,
  });

  factory AiDecisionDecisionResultDto.fromJson(
    final Map<String, dynamic> json,
  ) => AiDecisionDecisionResultDto(
    riskScore: (json['risk_score'] as num).toDouble(),
    riskBand: json['risk_band'] as String,
    recommendedAction: json['recommended_action'] as String,
    rationale: json['rationale'] as String,
    proof: json['proof'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  );

  final double riskScore;
  final String riskBand;
  final String recommendedAction;
  final String rationale;
  final Map<String, dynamic> proof;

  AiDecisionDecisionResult toDomain() => AiDecisionDecisionResult(
    riskScore: riskScore,
    riskBand: riskBand,
    recommendedAction: recommendedAction,
    rationale: rationale,
    proof: mapAiDecisionProof(proof),
  );
}

class AiDecisionCaseDetailDto {
  AiDecisionCaseDetailDto({
    required this.caseId,
    required this.status,
    required this.createdAt,
    required this.applicant,
    required this.business,
    required this.loan,
    required this.riskSignals,
    required this.actions,
    required this.latestDecision,
  });

  factory AiDecisionCaseDetailDto.fromJson(final Map<String, dynamic> json) {
    final caseJson = json['case'] as Map<String, dynamic>;
    return AiDecisionCaseDetailDto(
      caseId: caseJson['id'] as String,
      status: caseJson['status'] as String,
      createdAt: caseJson['created_at'] as String,
      applicant: json['applicant'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      business: json['business'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      loan: json['loan'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      riskSignals: (json['risk_signals'] as List<dynamic>? ?? const <dynamic>[])
          .map((final e) => e as Map<String, dynamic>)
          .toList(growable: false),
      actions: (json['actions'] as List<dynamic>? ?? const <dynamic>[])
          .map((final e) => e as Map<String, dynamic>)
          .toList(growable: false),
      latestDecision: json['latest_decision'] == null
          ? null
          : AiDecisionDecisionResultDto.fromJson(
              json['latest_decision'] as Map<String, dynamic>,
            ),
    );
  }

  final String caseId;
  final String status;
  final String createdAt;
  final Map<String, dynamic> applicant;
  final Map<String, dynamic> business;
  final Map<String, dynamic> loan;
  final List<Map<String, dynamic>> riskSignals;
  final List<Map<String, dynamic>> actions;
  final AiDecisionDecisionResultDto? latestDecision;

  AiDecisionCaseDetail toDomain() => AiDecisionCaseDetail(
    caseId: caseId,
    status: status,
    createdAt: createdAt,
    applicant: mapAiDecisionApplicant(applicant),
    business: mapAiDecisionBusiness(business),
    loan: mapAiDecisionLoan(loan),
    riskSignals: riskSignals
        .map(mapAiDecisionRiskSignal)
        .toList(growable: false),
    actions: actions.map(mapAiDecisionActionRecord).toList(growable: false),
    latestDecision: latestDecision?.toDomain(),
  );
}
