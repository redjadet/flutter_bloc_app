from __future__ import annotations


def test_health_ok(client):
    r = client.get("/health")
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "ok"
    assert body["similar_cases_enabled"] is False


def test_cases_seeded(client):
    r = client.get("/cases")
    assert r.status_code == 200
    body = r.json()
    assert "cases" in body
    assert len(body["cases"]) >= 6
    assert {"id", "applicant_name", "business_name", "amount", "status"} <= set(body["cases"][0].keys())


def test_case_detail(client):
    r = client.get("/cases/case_high_001")
    assert r.status_code == 200
    body = r.json()
    assert body["case"]["id"] == "case_high_001"
    assert body["applicant"]["prior_defaults"] >= 0
    assert body["business"]["monthly_revenue"] > 0
    assert isinstance(body["risk_signals"], list)


def test_decision_returns_score_rationale_proof(client):
    r = client.post("/cases/case_high_001/decision", json={"operator_note": "Check seasonality"})
    assert r.status_code == 200
    body = r.json()
    assert body["case_id"] == "case_high_001"
    assert 0.0 <= body["risk_score"] <= 1.0
    assert body["risk_band"] in {"low", "medium", "high"}
    assert body["recommended_action"] in {"approve", "manual_review", "request_docs", "decline"}
    assert isinstance(body["rationale"], str) and body["rationale"]

    proof = body["proof"]
    assert proof["confidence"] in {"rules_only", "complete", "partial"}
    assert "input_snapshot" in proof
    assert "rule_trace" in proof and len(proof["rule_trace"]) >= 1
    assert proof["base_score"] >= 0.0
    assert proof["final_score"] == body["risk_score"]

    detail = client.get("/cases/case_high_001")
    assert detail.status_code == 200
    latest = detail.json()["latest_decision"]
    assert latest["id"] == body["id"]
    assert latest["proof"]["final_score"] == body["risk_score"]
    assert latest["proof"]["rule_trace"]


def test_action_persists(client):
    r = client.post("/cases/case_high_001/actions", json={"action_type": "request_docs", "note": "Need bank statements"})
    assert r.status_code == 200
    action = r.json()
    assert action["case_id"] == "case_high_001"
    assert action["action_type"] == "request_docs"

    r2 = client.get("/cases/case_high_001")
    assert r2.status_code == 200
    body2 = r2.json()
    assert len(body2["actions"]) >= 1
    assert body2["actions"][0]["action_type"] in {"approve", "manual_review", "request_docs", "decline"}


def test_404_case_not_found(client):
    r = client.get("/cases/nope")
    assert r.status_code == 404
    assert r.json()["detail"] == "case_not_found"


def test_decision_includes_similar_case_when_enabled(client_with_fake_matcher):
    r = client_with_fake_matcher.get("/health")
    assert r.status_code == 200
    assert r.json()["similar_cases_enabled"] is True

    r2 = client_with_fake_matcher.post(
        "/cases/case_high_001/decision",
        json={"operator_note": "Check seasonality"},
    )
    assert r2.status_code == 200
    body = r2.json()
    assert body["proof"]["confidence"] == "complete"
    assert body["proof"]["similar_case"]["used"] is True
    assert body["proof"]["similar_case"]["case_id"] == "case_ref_003"
    assert body["signals"]["nearest_case_id"] == "case_ref_003"
