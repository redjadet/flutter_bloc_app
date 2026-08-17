import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_dto_mappers.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_json.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

export 'ai_decision_dto_mappers.dart';

/// Wire DTO for AI Decision API case queue rows.
class AiDecisionCaseSummaryDto({
  required final String id,
  required final String applicantName,
  required final String businessName,
  required final double amount,
  required final String status,
  required final String? lastDecisionBand,
}) {
  factory AiDecisionCaseSummaryDto.fromJson(Map<String, dynamic> json) =>
      AiDecisionCaseSummaryDto(
        id: requireAiDecisionString(json, 'id'),
        applicantName: requireAiDecisionString(json, 'applicant_name'),
        businessName: requireAiDecisionString(json, 'business_name'),
        amount: requireAiDecisionNumAsDouble(json, 'amount'),
        status: requireAiDecisionString(json, 'status'),
        lastDecisionBand: optionalAiDecisionString(json, 'last_decision_band'),
      );

  AiDecisionCaseSummary toDomain() => AiDecisionCaseSummary(
    id: id,
    applicantName: applicantName,
    businessName: businessName,
    amount: amount,
    status: status,
    lastDecisionBand: lastDecisionBand,
  );
}

class AiDecisionDecisionResultDto({
  required final double riskScore,
  required final String riskBand,
  required final String recommendedAction,
  required final String rationale,
  required final Map<String, dynamic> proof,
}) {
  factory AiDecisionDecisionResultDto.fromJson(
    Map<String, dynamic> json,
  ) => AiDecisionDecisionResultDto(
    riskScore: requireAiDecisionNumAsDouble(json, 'risk_score'),
    riskBand: requireAiDecisionString(json, 'risk_band'),
    recommendedAction: requireAiDecisionString(json, 'recommended_action'),
    rationale: requireAiDecisionString(json, 'rationale'),
    proof: optionalAiDecisionMap(json, 'proof'),
  );

  AiDecisionDecisionResult toDomain() => AiDecisionDecisionResult(
    riskScore: riskScore,
    riskBand: riskBand,
    recommendedAction: recommendedAction,
    rationale: rationale,
    proof: mapAiDecisionProof(proof),
  );
}

class AiDecisionCaseDetailDto({
  required final String caseId,
  required final String status,
  required final String createdAt,
  required final Map<String, dynamic> applicant,
  required final Map<String, dynamic> business,
  required final Map<String, dynamic> loan,
  required final List<Map<String, dynamic>> riskSignals,
  required final List<Map<String, dynamic>> actions,
  required final AiDecisionDecisionResultDto? latestDecision,
}) {
  factory AiDecisionCaseDetailDto.fromJson(Map<String, dynamic> json) {
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
