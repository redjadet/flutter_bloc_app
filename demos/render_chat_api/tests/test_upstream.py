"""Upstream Hugging Face adapter status mapping tests."""

from __future__ import annotations

import pytest
import httpx

from orchestration.upstream import (
    HuggingFaceUpstreamError,
    call_hf_chat_completions,
)


def _mock_client(status_code: int) -> httpx.AsyncClient:
    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(
            status_code=status_code,
            json={"error": "nope"},
            request=request,
        )

    transport = httpx.MockTransport(handler)
    return httpx.AsyncClient(transport=transport)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("status_code", "expected_code", "expected_retryable"),
    [
        (401, "auth_required", False),
        (403, "forbidden", False),
        (504, "upstream_timeout", True),
    ],
)
async def test_call_hf_chat_completions_maps_status_codes(
    status_code: int,
    expected_code: str,
    expected_retryable: bool,
) -> None:
    async with _mock_client(status_code) as client:
        with pytest.raises(HuggingFaceUpstreamError) as exc:
            await call_hf_chat_completions(
                client=client,
                hf_token="hf-test",
                resolved_model="openai/gpt-oss-20b",
                messages=[{"role": "user", "content": "hi"}],
                timeout=5.0,
            )

    assert exc.value.code == expected_code
    assert exc.value.retryable is expected_retryable
