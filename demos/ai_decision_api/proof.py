from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Literal

from scoring import ScoreInputs


ProofConfidence = Literal["complete", "rules_only", "partial"]


@dataclass(frozen=True)
class SimilarCaseResult:
    used: bool
    case_id: str | None = None
    label: str | None = None
    similarity: float | None = None
    contribution: float = 0.0


def build_rule_trace(*, inputs: ScoreInputs) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    trace: list[dict[str, Any]] = []
    evidence: list[dict[str, Any]] = []

    ratio = inputs.amount_income_ratio
    ratio_pass = ratio > 3.0
    ratio_contrib = 0.25 if ratio_pass else 0.0
    trace.append(
        {
            "id": "amount_revenue_ratio",
            "label": "Amount / revenue ratio",
            "observed": round(ratio, 4),
            "threshold": "> 3.0",
            "passed": ratio_pass,
            "contribution": ratio_contrib,
            "evidence": f"Loan amount {inputs.amount:g} / monthly revenue {inputs.monthly_revenue:g} = {ratio:.2f}",
        }
    )
    evidence.append(
        {
            "source": "loan.amount",
            "label": "Loan amount",
            "value": f"{inputs.amount:g}",
            "supports": "amount_revenue_ratio",
        }
    )
    evidence.append(
        {
            "source": "business.monthly_revenue",
            "label": "Monthly revenue",
            "value": f"{inputs.monthly_revenue:g}",
            "supports": "amount_revenue_ratio",
        }
    )

    defaults_pass = inputs.prior_defaults > 0
    defaults_contrib = 0.25 if defaults_pass else 0.0
    trace.append(
        {
            "id": "prior_defaults",
            "label": "Prior defaults",
            "observed": inputs.prior_defaults,
            "threshold": "> 0",
            "passed": defaults_pass,
            "contribution": defaults_contrib,
            "evidence": f"Applicant has {inputs.prior_defaults} prior default(s)",
        }
    )
    evidence.append(
        {
            "source": "applicant.prior_defaults",
            "label": "Prior defaults",
            "value": str(inputs.prior_defaults),
            "supports": "higher_risk" if defaults_pass else "lower_risk",
        }
    )

    young_pass = inputs.business_age_months < 24
    trace.append(
        {
            "id": "young_business",
            "label": "Business age",
            "observed": inputs.business_age_months,
            "threshold": "< 24 months",
            "passed": young_pass,
            "contribution": 0.10 if young_pass else 0.0,
            "evidence": f"Business age is {inputs.business_age_months} months",
        }
    )
    evidence.append(
        {
            "source": "business.age_months",
            "label": "Business age (months)",
            "value": str(inputs.business_age_months),
            "supports": "higher_risk" if young_pass else "lower_risk",
        }
    )

    low_rev_pass = inputs.monthly_revenue < 3000
    trace.append(
        {
            "id": "low_revenue",
            "label": "Low monthly revenue",
            "observed": inputs.monthly_revenue,
            "threshold": "< 3000",
            "passed": low_rev_pass,
            "contribution": 0.10 if low_rev_pass else 0.0,
            "evidence": f"Monthly revenue is {inputs.monthly_revenue:g}",
        }
    )

    low_credit_pass = inputs.personal_credit_score < 620
    trace.append(
        {
            "id": "low_credit_score",
            "label": "Low credit score",
            "observed": inputs.personal_credit_score,
            "threshold": "< 620",
            "passed": low_credit_pass,
            "contribution": 0.10 if low_credit_pass else 0.0,
            "evidence": f"Personal credit score is {inputs.personal_credit_score}",
        }
    )

    return trace, evidence


def top_driver_from_trace(trace: list[dict[str, Any]]) -> str:
    # Largest contribution wins; stable tie-breaker by id.
    scored = sorted(trace, key=lambda r: (float(r["contribution"]), str(r["id"])), reverse=True)
    if not scored:
        return "unknown"
    return str(scored[0]["id"])


def build_proof(
    *,
    inputs: ScoreInputs,
    base_score: float,
    final_score: float,
    confidence: ProofConfidence,
    similar_case: SimilarCaseResult,
) -> dict[str, Any]:
    trace, evidence = build_rule_trace(inputs=inputs)
    return {
        "confidence": confidence,
        "input_snapshot": {
            "amount": inputs.amount,
            "monthly_revenue": inputs.monthly_revenue,
            "business_age_months": inputs.business_age_months,
            "personal_credit_score": inputs.personal_credit_score,
            "prior_defaults": inputs.prior_defaults,
        },
        "base_score": base_score,
        "final_score": final_score,
        "rule_trace": trace,
        "band_thresholds": {
            "low": "< 0.35",
            "medium": "0.35 - 0.64",
            "high": ">= 0.65",
            "selected": "high" if final_score >= 0.65 else ("medium" if final_score >= 0.35 else "low"),
        },
        "evidence": evidence,
        "similar_case": {
            "used": similar_case.used,
            "case_id": similar_case.case_id,
            "label": similar_case.label,
            "similarity": similar_case.similarity,
            "contribution": similar_case.contribution,
        },
    }
