import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

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
