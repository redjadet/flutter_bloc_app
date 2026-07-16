import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_dto_mappers.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_json.dart';
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
        id: requireAiDecisionString(json, 'id'),
        applicantName: requireAiDecisionString(json, 'applicant_name'),
        businessName: requireAiDecisionString(json, 'business_name'),
        amount: requireAiDecisionNumAsDouble(json, 'amount'),
        status: requireAiDecisionString(json, 'status'),
        lastDecisionBand: optionalAiDecisionString(json, 'last_decision_band'),
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
    riskScore: requireAiDecisionNumAsDouble(json, 'risk_score'),
    riskBand: requireAiDecisionString(json, 'risk_band'),
    recommendedAction: requireAiDecisionString(json, 'recommended_action'),
    rationale: requireAiDecisionString(json, 'rationale'),
    proof: optionalAiDecisionMap(json, 'proof'),
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
    final Map<String, dynamic> caseJson = requireAiDecisionMap(json, 'case');
    final Object? latestRaw = json['latest_decision'];
    AiDecisionDecisionResultDto? latestDecision;
    if (latestRaw != null) {
      // requireAiDecisionMap redacts value kinds; never interpolate payload.
      latestDecision = AiDecisionDecisionResultDto.fromJson(
        requireAiDecisionMap(json, 'latest_decision'),
      );
    }
    return AiDecisionCaseDetailDto(
      caseId: requireAiDecisionString(caseJson, 'id'),
      status: requireAiDecisionString(caseJson, 'status'),
      createdAt: requireAiDecisionString(caseJson, 'created_at'),
      applicant: optionalAiDecisionMap(json, 'applicant'),
      business: optionalAiDecisionMap(json, 'business'),
      loan: optionalAiDecisionMap(json, 'loan'),
      riskSignals: requireAiDecisionMapList(json, 'risk_signals'),
      actions: requireAiDecisionMapList(json, 'actions'),
      latestDecision: latestDecision,
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
