"""Structured usage logging (no PII, no tokens)."""

from __future__ import annotations

import hashlib
import json
import logging
from typing import Any

logger = logging.getLogger("render_chat.usage")


def _hash_idempotency_key(raw: str) -> str:
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()[:16]


def log_usage(
    *,
    request_id: str,
    resolved_model: str,
    cache_hit: bool,
    upstream_invocation: bool,
    latency_ms: float,
    upstream_http_status: int | None,
    idempotency_key: str | None,
    approx_tokens_in: int | None = None,
    approx_tokens_out: int | None = None,
    extra: dict[str, Any] | None = None,
) -> None:
    payload: dict[str, Any] = {
        "event": "chat_orchestration",
        "request_id": request_id,
        "resolved_model": resolved_model,
        "cache_hit": cache_hit,
        "upstream_invocation": upstream_invocation,
        "latency_ms": round(latency_ms, 2),
        "upstream_http_status": upstream_http_status,
        "idempotency_key_sha256_16": _hash_idempotency_key(idempotency_key)
        if idempotency_key
        else None,
        "approx_tokens_in": approx_tokens_in,
        "approx_tokens_out": approx_tokens_out,
    }
    if extra:
        payload.update(extra)
    logger.info(json.dumps(payload, separators=(",", ":")))
