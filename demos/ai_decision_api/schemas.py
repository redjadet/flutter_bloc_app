from __future__ import annotations

from datetime import datetime
from typing import Any, Literal, Optional

from pydantic import BaseModel, ConfigDict, Field


RiskBand = Literal["low", "medium", "high"]
RecommendedAction = Literal["approve", "manual_review", "request_docs", "decline"]
ProofConfidence = Literal["complete", "rules_only", "partial"]

MAX_NOTE_LENGTH = 2000


class RequestModel(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class CaseSummary(BaseModel):
    id: str
    applicant_name: str
    business_name: str
    amount: float
    status: str
    last_decision_band: Optional[RiskBand] = None


class GetCasesResponse(BaseModel):
    cases: list[CaseSummary]


class CaseInfo(BaseModel):
    id: str
    status: str
    created_at: str


class Applicant(BaseModel):
    id: str
    name: str
    personal_credit_score: int
    prior_defaults: int


class Business(BaseModel):
    id: str
    name: str
    industry: str
    monthly_revenue: float
    age_months: int


class Loan(BaseModel):
    amount: float
    purpose: str


class RiskSignal(BaseModel):
    key: str
    label: str
    value: str
    severity: str


class Action(BaseModel):
    id: str
    case_id: str
    action_type: str
    note: str
    created_at: str


class CreateDecisionRequest(RequestModel):
    operator_note: str = Field(default="", max_length=MAX_NOTE_LENGTH)


class SimilarCaseProof(BaseModel):
    used: bool
    case_id: Optional[str] = None
    label: Optional[str] = None
    similarity: Optional[float] = None
    contribution: float = 0.0


class RuleTraceRow(BaseModel):
    id: str
    label: str
    observed: float | int | str
    threshold: str
    passed: bool
    contribution: float
    evidence: str


class EvidenceRow(BaseModel):
    source: str
    label: str
    value: str
    supports: str


class Proof(BaseModel):
    confidence: ProofConfidence
    input_snapshot: dict[str, Any]
    base_score: float
    final_score: float
    rule_trace: list[RuleTraceRow]
    band_thresholds: dict[str, str]
    evidence: list[EvidenceRow]
    similar_case: SimilarCaseProof


class LatestDecision(BaseModel):
    id: str
    case_id: str
    risk_score: float
    risk_band: RiskBand
    recommended_action: RecommendedAction
    rationale: str
    signals: dict[str, Any]
    proof: Proof
    meta: dict[str, Any]
    created_at: str


class GetCaseDetailResponse(BaseModel):
    case: CaseInfo
    applicant: Applicant
    business: Business
    loan: Loan
    risk_signals: list[RiskSignal]
    latest_decision: Optional[LatestDecision] = None
    actions: list[Action]


class CreateDecisionResponse(BaseModel):
    id: str
    case_id: str
    risk_score: float
    risk_band: RiskBand
    recommended_action: RecommendedAction
    rationale: str
    signals: dict[str, Any]
    proof: Proof
    meta: dict[str, Any]


class CreateActionRequest(RequestModel):
    action_type: RecommendedAction
    note: str = Field(min_length=1, max_length=MAX_NOTE_LENGTH)


class CreateActionResponse(Action):
    pass


class HealthResponse(BaseModel):
    status: Literal["ok"] = "ok"
    similar_cases_enabled: bool
    model: Optional[str] = None
