class const AiDecisionCaseSummary({
  required final String id,
  required final String applicantName,
  required final String businessName,
  required final double amount,
  required final String status,
  required final String? lastDecisionBand,
});

class const AiDecisionApplicant({
  required final String name,
  final String? id,
  final int? personalCreditScore,
  final int? priorDefaults,
});

class const AiDecisionBusiness({
  required final String name,
  final String? id,
  final String? industry,
  final double? monthlyRevenue,
  final int? ageMonths,
});

class const AiDecisionLoan({
  required final double amount,
  required final String purpose,
});

class const AiDecisionRiskSignal({
  required final String label,
  required final String value,
  required final String severity,
  final String? key,
});

class const AiDecisionActionRecord({
  required final String actionType,
  required final String note,
});

class const AiDecisionProofRule({
  required final String id,
  required final String label,
  required final bool passed,
  required final double contribution,
  final String? evidence,
});

class const AiDecisionBandThresholds({
  final Object? low,
  final Object? medium,
  final Object? high,
  final Object? selected,
}) {
  bool get isEmpty =>
      low == null && medium == null && high == null && selected == null;
}

class const AiDecisionSimilarCase({
  required final bool used,
  final String? caseId,
  final String? label,
  final Object? similarity,
});

class const AiDecisionProof({
  final List<AiDecisionProofRule> ruleTrace = const <AiDecisionProofRule>[],
  final Map<String, dynamic> inputSnapshot = const <String, dynamic>{},
  final AiDecisionBandThresholds? bandThresholds,
  final AiDecisionSimilarCase? similarCase,
  final String confidence = 'unknown',
  final double? finalScore,

  /// Wire keys not modeled as first-class fields (e.g. legacy `model`).
  final Map<String, dynamic> extras = const <String, dynamic>{},
});

class const AiDecisionCaseDetail({
  required final String caseId,
  required final String status,
  required final String createdAt,
  required final AiDecisionApplicant applicant,
  required final AiDecisionBusiness business,
  required final AiDecisionLoan loan,
  required final List<AiDecisionRiskSignal> riskSignals,
  required final List<AiDecisionActionRecord> actions,
  required final AiDecisionDecisionResult? latestDecision,
});

class const AiDecisionDecisionResult({
  required final double riskScore,
  required final String riskBand,
  required final String recommendedAction,
  required final String rationale,
  required final AiDecisionProof proof,
});
