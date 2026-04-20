from __future__ import annotations

import uuid
from dataclasses import dataclass
from typing import Any

from proof import SimilarCaseResult, build_proof, top_driver_from_trace
from rationale import build_rationale
from scoring import ScoreInputs, band_from_score, recommended_action_from_band, score_rules
from similar_cases import SimilarCaseMatcher
from store import Store


@dataclass(frozen=True)
class DecisionService:
    store: Store
    matcher: SimilarCaseMatcher

    def create_decision(self, *, case_id: str, operator_note: str) -> dict[str, Any]:
        detail = self.store.get_case_detail(case_id=case_id)
        if detail is None:
            raise KeyError("case_not_found")

        applicant = detail["applicant"]
        business = detail["business"]
        loan = detail["loan"]

        inputs = ScoreInputs(
            amount=float(loan["amount"]),
            monthly_revenue=float(business["monthly_revenue"]),
            business_age_months=int(business["age_months"]),
            personal_credit_score=int(applicant["personal_credit_score"]),
            prior_defaults=int(applicant["prior_defaults"]),
        )

        rule_score, rule_meta = score_rules(inputs)
        base_score = float(rule_meta["base_score"])
        signals: dict[str, Any] = dict(rule_meta["signals"])

        # Similar-case matching (Day-1 disabled by default).
        similar = SimilarCaseResult(used=False)
        if self.matcher.enabled:
            try:
                nearest = self.matcher.nearest(
                    f"{business['industry']} business; purpose={loan['purpose']}; "
                    f"amount={inputs.amount:g}; revenue={inputs.monthly_revenue:g}; defaults={inputs.prior_defaults}"
                )
            except Exception as e:
                signals["similar_cases_error"] = f"{type(e).__name__}: {e}"
                nearest = None

            if nearest is not None:
                similar = SimilarCaseResult(
                    used=True,
                    case_id=nearest.case_id,
                    label=nearest.label,
                    similarity=nearest.similarity,
                    contribution=float(nearest.contribution),
                )
                signals.update(
                    {
                        "nearest_case_id": nearest.case_id,
                        "nearest_case_label": nearest.label,
                        "nearest_case_similarity": round(nearest.similarity, 4),
                        "similar_case_adjustment": float(nearest.contribution),
                    }
                )

        final_score = float(min(1.0, max(0.0, rule_score + similar.contribution)))
        band = band_from_score(final_score)

        # Determine a top driver from the rule trace (largest contribution).
        tmp_proof = build_proof(
            inputs=inputs,
            base_score=base_score,
            final_score=final_score,
            confidence="complete" if similar.used else "rules_only",
            similar_case=similar,
        )
        top_driver = top_driver_from_trace(list(tmp_proof["rule_trace"]))
        action = recommended_action_from_band(band=band, top_driver=top_driver)

        rationale = build_rationale(proof=tmp_proof, recommended_action=action)

        decision_id = f"dec_{uuid.uuid4().hex[:8]}"
        meta = {"scoring_version": "mvp-rules-0.1", "similar_cases_used": bool(similar.used)}

        return self.store.insert_decision(
            decision_id=decision_id,
            case_id=case_id,
            risk_score=final_score,
            risk_band=band,
            recommended_action=action,
            rationale=rationale,
            signals=signals,
            proof=tmp_proof,
            meta=meta,
        )
