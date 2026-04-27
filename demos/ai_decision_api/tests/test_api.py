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


def test_action_ids_are_unique_even_with_stale_action_snapshot(client, monkeypatch):
    import main as main_mod
    from store import Store

    store = main_mod.app.state.store
    original_get_case_detail = Store.get_case_detail
    original_insert_action = Store.insert_action
    captured_ids = []

    def stale_detail(self, *, case_id: str):
        detail = original_get_case_detail(self, case_id=case_id)
        if detail is not None:
            detail = dict(detail)
            detail["actions"] = []
        return detail

    def capture_insert_action(self, **kwargs):
        captured_ids.append(kwargs["action_id"])
        return original_insert_action(self, **kwargs)

    monkeypatch.setattr(Store, "get_case_detail", stale_detail)
    monkeypatch.setattr(Store, "insert_action", capture_insert_action)

    first = client.post("/cases/case_high_001/actions", json={"action_type": "request_docs", "note": "Need bank statements"})
    second = client.post("/cases/case_high_001/actions", json={"action_type": "manual_review", "note": "Review cash flow"})

    assert first.status_code == 200
    assert second.status_code == 200
    assert len(captured_ids) == 2
    assert len(set(captured_ids)) == 2


def test_decision_rejects_oversized_operator_note(client):
    oversized = "x" * 2500
    r = client.post("/cases/case_high_001/decision", json={"operator_note": oversized})
    assert r.status_code == 422


def test_action_rejects_empty_note(client):
    r = client.post("/cases/case_high_001/actions", json={"action_type": "request_docs", "note": ""})
    assert r.status_code == 422


def test_action_rejects_oversized_note(client):
    oversized = "x" * 2500
    r = client.post("/cases/case_high_001/actions", json={"action_type": "request_docs", "note": oversized})
    assert r.status_code == 422


def test_action_rejects_unknown_fields(client):
    r = client.post(
        "/cases/case_high_001/actions",
        json={"action_type": "request_docs", "note": "Need docs", "unknown": "nope"},
    )
    assert r.status_code == 422
