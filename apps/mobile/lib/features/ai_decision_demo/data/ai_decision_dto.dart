import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

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

AiDecisionApplicant mapAiDecisionApplicant(final Map<String, dynamic> json) =>
    AiDecisionApplicant(
      name: _stringOf(json['name']),
      id: _optionalString(json['id']),
      personalCreditScore: _optionalInt(json['personal_credit_score']),
      priorDefaults: _optionalInt(json['prior_defaults']),
    );

AiDecisionBusiness mapAiDecisionBusiness(final Map<String, dynamic> json) =>
    AiDecisionBusiness(
      name: _stringOf(json['name']),
      id: _optionalString(json['id']),
      industry: _optionalString(json['industry']),
      monthlyRevenue: _optionalDouble(json['monthly_revenue']),
      ageMonths: _optionalInt(json['age_months']),
    );

AiDecisionLoan mapAiDecisionLoan(final Map<String, dynamic> json) =>
    AiDecisionLoan(
      amount: _optionalDouble(json['amount']) ?? 0,
      purpose: _stringOf(json['purpose']),
    );

AiDecisionRiskSignal mapAiDecisionRiskSignal(final Map<String, dynamic> json) {
  final String label = _stringOf(json['label']).isNotEmpty
      ? _stringOf(json['label'])
      : _stringOf(json['code']);
  return AiDecisionRiskSignal(
    key: _optionalString(json['key']),
    label: label,
    value: _stringOf(json['value']),
    severity: _stringOf(json['severity']),
  );
}

AiDecisionActionRecord mapAiDecisionActionRecord(
  final Map<String, dynamic> json,
) {
  final String actionType = _stringOf(json['action_type']).isNotEmpty
      ? _stringOf(json['action_type'])
      : _stringOf(json['type']);
  return AiDecisionActionRecord(
    actionType: actionType,
    note: _stringOf(json['note']),
  );
}

AiDecisionProof mapAiDecisionProof(final Map<String, dynamic> json) {
  const knownKeys = <String>{
    'rule_trace',
    'input_snapshot',
    'band_thresholds',
    'similar_case',
    'confidence',
    'final_score',
  };
  final extras = <String, dynamic>{
    for (final MapEntry<String, dynamic> e in json.entries)
      if (!knownKeys.contains(e.key)) e.key: e.value,
  };

  final thresholdsRaw = json['band_thresholds'];
  final similarRaw = json['similar_case'];

  return AiDecisionProof(
    ruleTrace: (json['rule_trace'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(mapAiDecisionProofRule)
        .toList(growable: false),
    inputSnapshot:
        json['input_snapshot'] as Map<String, dynamic>? ??
        const <String, dynamic>{},
    bandThresholds: thresholdsRaw is Map<String, dynamic>
        ? mapAiDecisionBandThresholds(thresholdsRaw)
        : null,
    similarCase: similarRaw is Map<String, dynamic>
        ? mapAiDecisionSimilarCase(similarRaw)
        : null,
    confidence: _optionalString(json['confidence']) ?? 'unknown',
    finalScore: _optionalDouble(json['final_score']),
    extras: extras,
  );
}

AiDecisionProofRule mapAiDecisionProofRule(final Map<String, dynamic> json) =>
    AiDecisionProofRule(
      id: _stringOf(json['id']),
      label: _stringOf(json['label']),
      passed: json['passed'] == true,
      contribution: _optionalDouble(json['contribution']) ?? 0,
      evidence: _optionalString(json['evidence']),
    );

AiDecisionBandThresholds mapAiDecisionBandThresholds(
  final Map<String, dynamic> json,
) => AiDecisionBandThresholds(
  low: json['low'],
  medium: json['medium'],
  high: json['high'],
  selected: json['selected'],
);

AiDecisionSimilarCase mapAiDecisionSimilarCase(
  final Map<String, dynamic> json,
) => AiDecisionSimilarCase(
  used: json['used'] == true,
  caseId: _optionalString(json['case_id']),
  label: _optionalString(json['label']),
  similarity: json['similarity'],
);

String _stringOf(final Object? value) => value?.toString() ?? '';

String? _optionalString(final Object? value) {
  if (value == null) return null;
  final String text = value.toString();
  return text.isEmpty ? null : text;
}

int? _optionalInt(final Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _optionalDouble(final Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
