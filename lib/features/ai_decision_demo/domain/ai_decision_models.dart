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
  final Map<String, dynamic> applicant;
  final Map<String, dynamic> business;
  final Map<String, dynamic> loan;
  final List<Map<String, dynamic>> riskSignals;
  final List<Map<String, dynamic>> actions;
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
  final Map<String, dynamic> proof;
}
