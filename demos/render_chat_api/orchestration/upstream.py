"""Hugging Face OpenAI-compatible chat completions (fixed host; STOP SSRF posture)."""

from __future__ import annotations

import json
import logging
from typing import Any

import httpx

logger = logging.getLogger(__name__)

HF_CHAT_COMPLETIONS_URL = "https://router.huggingface.co/v1/chat/completions"


class HuggingFaceUpstreamError(Exception):
    def __init__(
        self,
        *,
        status_code: int,
        code: str,
        message: str,
        retryable: bool,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.code = code
        self.retryable = retryable


async def call_hf_chat_completions(
    *,
    client: httpx.AsyncClient,
    hf_token: str,
    resolved_model: str,
    messages: list[dict[str, Any]],
    timeout: float,
) -> str:
    """Return assistant text from choices[0].message.content."""
    headers = {
        "Authorization": f"Bearer {hf_token}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": resolved_model,
        "messages": messages,
        "stream": False,
    }
    try:
        resp = await client.post(
            HF_CHAT_COMPLETIONS_URL,
            headers=headers,
            content=json.dumps(payload),
            timeout=timeout,
        )
    except httpx.TimeoutException as e:
        raise HuggingFaceUpstreamError(
            status_code=504,
            code="upstream_timeout",
            message="Hugging Face request timed out.",
            retryable=True,
        ) from e
    except httpx.RequestError as e:
        raise HuggingFaceUpstreamError(
            status_code=503,
            code="upstream_unavailable",
            message="Could not reach Hugging Face.",
            retryable=True,
        ) from e

    if resp.status_code == 429:
        raise HuggingFaceUpstreamError(
            status_code=429,
            code="rate_limited",
            message="Upstream rate limited.",
            retryable=False,
        )
    if resp.status_code >= 500:
        raise HuggingFaceUpstreamError(
            status_code=503,
            code="upstream_unavailable",
            message="Upstream server error.",
            retryable=True,
        )
    if resp.status_code >= 400:
        raise HuggingFaceUpstreamError(
            status_code=resp.status_code,
            code="invalid_request",
            message=resp.text[:512] if resp.text else "Upstream rejected request.",
            retryable=False,
        )

    try:
        data = resp.json()
    except json.JSONDecodeError as e:
        raise HuggingFaceUpstreamError(
            status_code=502,
            code="invalid_request",
            message="Upstream returned non-JSON.",
            retryable=False,
        ) from e

    choices = data.get("choices")
    if not isinstance(choices, list) or not choices:
        raise HuggingFaceUpstreamError(
            status_code=502,
            code="invalid_request",
            message="Missing choices in upstream response.",
            retryable=False,
        )
    first = choices[0]
    if not isinstance(first, dict):
        raise HuggingFaceUpstreamError(
            status_code=502,
            code="invalid_request",
            message="Invalid choice shape.",
            retryable=False,
        )
    message = first.get("message")
    if not isinstance(message, dict):
        raise HuggingFaceUpstreamError(
            status_code=502,
            code="invalid_request",
            message="Missing message in choice.",
            retryable=False,
        )
    content = message.get("content")
    if isinstance(content, str) and content.strip():
        return content
    raise HuggingFaceUpstreamError(
        status_code=502,
        code="invalid_request",
        message="Empty assistant content.",
        retryable=False,
    )
