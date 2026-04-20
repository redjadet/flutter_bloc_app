from __future__ import annotations

from typing import Any


def build_rationale(*, proof: dict[str, Any], recommended_action: str) -> str:
    trace = list(proof.get("rule_trace") or [])
    top = sorted(trace, key=lambda r: float(r.get("contribution", 0.0)), reverse=True)[:2]
    drivers = [t for t in top if float(t.get("contribution", 0.0)) > 0]

    if not drivers:
        return f"Low evidence of risk drivers from rules. Recommended action: {recommended_action}."

    parts: list[str] = []
    for d in drivers:
        parts.append(str(d.get("evidence") or d.get("label") or d.get("id")))

    similar = proof.get("similar_case") or {}
    if bool(similar.get("used")):
        cid = similar.get("case_id")
        lbl = similar.get("label")
        sim = similar.get("similarity")
        if cid and lbl and sim is not None:
            parts.append(f"Similar reference case {cid} labeled {lbl} (similarity {float(sim):.2f}).")

    return " ".join(parts)
