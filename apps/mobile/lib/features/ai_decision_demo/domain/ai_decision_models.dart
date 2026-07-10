class AiDecisionCaseSummary {
  AiDecisionCaseSummary({
    required this.id,
    required this.applicantName,
    required this.businessName,
    required this.amount,
    required this.status,
    required this.lastDecisionBand,
  });

  final String id;
  final String applicantName;
  final String businessName;
  final double amount;
  final String status;
  final String? lastDecisionBand;
}

class AiDecisionApplicant {
  const AiDecisionApplicant({
    required this.name,
    this.id,
    this.personalCreditScore,
    this.priorDefaults,
  });

  final String name;
  final String? id;
  final int? personalCreditScore;
  final int? priorDefaults;
}

class AiDecisionBusiness {
  const AiDecisionBusiness({
    required this.name,
    this.id,
    this.industry,
    this.monthlyRevenue,
    this.ageMonths,
  });

  final String name;
  final String? id;
  final String? industry;
  final double? monthlyRevenue;
  final int? ageMonths;
}

class AiDecisionLoan {
  const AiDecisionLoan({
    required this.amount,
    required this.purpose,
  });

  final double amount;
  final String purpose;
}

class AiDecisionRiskSignal {
  const AiDecisionRiskSignal({
    required this.label,
    required this.value,
    required this.severity,
    this.key,
  });

  final String label;
  final String value;
  final String severity;
  final String? key;
}

class AiDecisionActionRecord {
  const AiDecisionActionRecord({
    required this.actionType,
    required this.note,
  });

  final String actionType;
  final String note;
}

class AiDecisionProofRule {
  const AiDecisionProofRule({
    required this.id,
    required this.label,
    required this.passed,
    required this.contribution,
    this.evidence,
  });

  final String id;
  final String label;
  final bool passed;
  final double contribution;
  final String? evidence;
}

class AiDecisionBandThresholds {
  const AiDecisionBandThresholds({
    this.low,
    this.medium,
    this.high,
    this.selected,
  });

  final Object? low;
  final Object? medium;
  final Object? high;
  final Object? selected;

  bool get isEmpty =>
      low == null && medium == null && high == null && selected == null;
}

class AiDecisionSimilarCase {
  const AiDecisionSimilarCase({
    required this.used,
    this.caseId,
    this.label,
    this.similarity,
  });

  final bool used;
  final String? caseId;
  final String? label;
  final Object? similarity;
}

class AiDecisionProof {
  const AiDecisionProof({
    this.ruleTrace = const <AiDecisionProofRule>[],
    this.inputSnapshot = const <String, dynamic>{},
    this.bandThresholds,
    this.similarCase,
    this.confidence = 'unknown',
    this.finalScore,
    this.extras = const <String, dynamic>{},
  });

  final List<AiDecisionProofRule> ruleTrace;
  final Map<String, dynamic> inputSnapshot;
  final AiDecisionBandThresholds? bandThresholds;
  final AiDecisionSimilarCase? similarCase;
  final String confidence;
  final double? finalScore;

  /// Wire keys not modeled as first-class fields (e.g. legacy `model`).
  final Map<String, dynamic> extras;
}

class AiDecisionCaseDetail {
  AiDecisionCaseDetail({
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

  final String caseId;
  final String status;
  final String createdAt;
  final AiDecisionApplicant applicant;
  final AiDecisionBusiness business;
  final AiDecisionLoan loan;
  final List<AiDecisionRiskSignal> riskSignals;
  final List<AiDecisionActionRecord> actions;
  final AiDecisionDecisionResult? latestDecision;
}

class AiDecisionDecisionResult {
  AiDecisionDecisionResult({
    required this.riskScore,
    required this.riskBand,
    required this.recommendedAction,
    required this.rationale,
    required this.proof,
  });

  final double riskScore;
  final String riskBand;
  final String recommendedAction;
  final String rationale;
  final AiDecisionProof proof;
}
