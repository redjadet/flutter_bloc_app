from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Literal


RiskBand = Literal["low", "medium", "high"]
RecommendedAction = Literal["approve", "manual_review", "request_docs", "decline"]


@dataclass(frozen=True)
class ScoreInputs:
    amount: float
    monthly_revenue: float
    business_age_months: int
    personal_credit_score: int
    prior_defaults: int

    @property
    def amount_income_ratio(self) -> float:
        if self.monthly_revenue <= 0:
            return 999.0
        return float(self.amount) / float(self.monthly_revenue)


def clamp(x: float, lo: float = 0.0, hi: float = 1.0) -> float:
    return max(lo, min(hi, x))


def score_rules(inputs: ScoreInputs) -> tuple[float, dict[str, Any]]:
    base = 0.20
    score = base

    ratio = inputs.amount_income_ratio
    if ratio > 3.0:
        score += 0.25
    if inputs.prior_defaults > 0:
        score += 0.25
    if inputs.business_age_months < 24:
        score += 0.10
    if inputs.monthly_revenue < 3000:
        score += 0.10
    if inputs.personal_credit_score < 620:
        score += 0.10

    score = clamp(score)

    signals: dict[str, Any] = {
        "amount_income_ratio": round(ratio, 4),
        "prior_defaults": inputs.prior_defaults,
        "business_age_months": inputs.business_age_months,
        "monthly_revenue": inputs.monthly_revenue,
        "personal_credit_score": inputs.personal_credit_score,
    }
    return score, {"base_score": base, "signals": signals}


def band_from_score(score: float) -> RiskBand:
    if score < 0.35:
        return "low"
    if score < 0.65:
        return "medium"
    return "high"


def recommended_action_from_band(*, band: RiskBand, top_driver: str) -> RecommendedAction:
    if band == "low":
        return "approve"
    if band == "medium":
        return "manual_review"
    # For MVP, use a simple heuristic: defaults -> decline, otherwise request_docs.
    if top_driver in {"prior_defaults", "personal_credit_score"}:
        return "decline"
    return "request_docs"
