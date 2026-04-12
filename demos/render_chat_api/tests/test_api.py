"""HTTP contract tests (TestClient)."""

from __future__ import annotations

from typing import Any
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient

from main import app
from settings import get_settings


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_health() -> None:
    with TestClient(app) as client:
        r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_chat_missing_hf_token() -> None:
    with TestClient(app) as client:
        r = client.post(
            "/v1/chat/completions",
            headers={
                "Authorization": "Bearer test-token",
                "Idempotency-Key": "k1",
            },
            json={
                "model": "auto",
                "messages": [{"role": "user", "content": "Hello"}],
            },
        )
    assert r.status_code == 401
    body = r.json()
    assert body["code"] == "auth_required"


def test_chat_success_with_mock_hf() -> None:
    async def _fake_hf(**kwargs: Any) -> str:
        return "assistant-from-mock"

    with patch(
        "orchestration.pipeline.call_hf_chat_completions",
        new=AsyncMock(side_effect=_fake_hf),
    ):
        with TestClient(app) as client:
            r = client.post(
                "/v1/chat/completions",
                headers={
                    "Authorization": "Bearer test-token",
                    "X-HF-Authorization": "Bearer hf-test",
                    "Idempotency-Key": "k-success-1",
                },
                json={
                    "model": "openai/gpt-oss-20b",
                    "messages": [{"role": "user", "content": "Hello"}],
                },
            )
    assert r.status_code == 200, r.text
    data = r.json()
    assert data["choices"][0]["message"]["content"] == "assistant-from-mock"


def test_cache_hit_second_call_no_second_hf() -> None:
    calls: list[int] = []

    async def _fake_hf(**kwargs: Any) -> str:
        calls.append(1)
        return "once"

    with patch(
        "orchestration.pipeline.call_hf_chat_completions",
        new=AsyncMock(side_effect=_fake_hf),
    ):
        with TestClient(app) as client:
            headers = {
                "Authorization": "Bearer test-token",
                "X-HF-Authorization": "Bearer hf-test",
                "Idempotency-Key": "idem-cache",
            }
            body = {
                "model": "openai/gpt-oss-20b",
                "messages": [{"role": "user", "content": "Hello"}],
            }
            r1 = client.post("/v1/chat/completions", headers=headers, json=body)
            r2 = client.post("/v1/chat/completions", headers=headers, json=body)
    assert r1.status_code == 200
    assert r2.status_code == 200
    assert len(calls) == 1


def test_complex_auto_selects_mini_for_short_prompt() -> None:
    async def _fake_hf(**kwargs: Any) -> str:
        assert kwargs["resolved_model"] == "openai/gpt-oss-20b"
        return "ok"

    with patch(
        "orchestration.pipeline.call_hf_chat_completions",
        new=AsyncMock(side_effect=_fake_hf),
    ):
        with TestClient(app) as client:
            r = client.post(
                "/v1/chat/completions",
                headers={
                    "Authorization": "Bearer test-token",
                    "X-HF-Authorization": "Bearer hf-test",
                    "Idempotency-Key": "k-mini",
                },
                json={
                    "model": "auto",
                    "messages": [{"role": "user", "content": "Hi"}],
                },
            )
    assert r.status_code == 200
