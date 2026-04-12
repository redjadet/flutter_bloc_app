"""Orchestration pipeline entrypoint."""

from __future__ import annotations

import time
from typing import Any

import httpx

from exceptions import Saturation
from schemas import ChatCompletionRequest, stable_openai_response
from settings import Settings

from .complexity import is_complex_request
from .concurrency_gate import ConcurrencyGate
from .filter_output import filter_output
from .memory_policy import apply_memory_window
from .response_cache import ResponseCache
from usage import log_usage

from .upstream import HuggingFaceUpstreamError, call_hf_chat_completions

MINI_MODEL = "openai/gpt-oss-20b"
FULL_MODEL = "openai/gpt-oss-120b"
ALLOWLIST = {MINI_MODEL, FULL_MODEL, "auto"}


class OrchestrationError(Exception):
    def __init__(
        self,
        *,
        http_status: int,
        code: str,
        message: str,
        retryable: bool,
    ) -> None:
        super().__init__(message)
        self.http_status = http_status
        self.code = code
        self.retryable = retryable


async def run_pipeline(
    *,
    body: ChatCompletionRequest,
    uid: str,
    idempotency_key: str,
    hf_token: str,
    request_id: str,
    settings: Settings,
    cache: ResponseCache,
    client: httpx.AsyncClient,
    gate_120b: ConcurrencyGate,
) -> dict[str, Any]:
    if body.model not in ALLOWLIST:
        raise OrchestrationError(
            http_status=422,
            code="invalid_request",
            message="Model not allowlisted.",
            retryable=False,
        )

    messages_dicts = [m.model_dump() for m in body.messages]

    t0 = time.perf_counter()

    cached = cache.get(uid, idempotency_key, messages_dicts, body.model)
    if cached is not None:
        log_usage(
            request_id=request_id,
            resolved_model=str(cached.get("model", "")),
            cache_hit=True,
            upstream_invocation=False,
            latency_ms=(time.perf_counter() - t0) * 1000,
            upstream_http_status=None,
            idempotency_key=idempotency_key,
        )
        return cached

    windowed = apply_memory_window(body.messages)
    resolved_model: str
    if body.model == "auto":
        resolved_model = FULL_MODEL if is_complex_request(windowed) else MINI_MODEL
    else:
        resolved_model = body.model

    messages_for_upstream = [m.model_dump() for m in windowed]

    try:
        if resolved_model == FULL_MODEL:
            try:
                async with gate_120b.slot():
                    assistant = await call_hf_chat_completions(
                        client=client,
                        hf_token=hf_token,
                        resolved_model=resolved_model,
                        messages=messages_for_upstream,
                        timeout=settings.hf_upstream_timeout_seconds,
                    )
            except Saturation:
                raise OrchestrationError(
                    http_status=503,
                    code="upstream_unavailable",
                    message="Server busy; retry later.",
                    retryable=True,
                ) from None
        else:
            assistant = await call_hf_chat_completions(
                client=client,
                hf_token=hf_token,
                resolved_model=resolved_model,
                messages=messages_for_upstream,
                timeout=settings.hf_upstream_timeout_seconds,
            )
    except HuggingFaceUpstreamError as e:
        log_usage(
            request_id=request_id,
            resolved_model=resolved_model,
            cache_hit=False,
            upstream_invocation=True,
            latency_ms=(time.perf_counter() - t0) * 1000,
            upstream_http_status=e.status_code,
            idempotency_key=idempotency_key,
            extra={"error_code": e.code},
        )
        raise OrchestrationError(
            http_status=502 if e.status_code >= 500 else e.status_code,
            code=e.code,
            message=e.args[0],
            retryable=e.retryable,
        ) from e

    filtered = filter_output(assistant)
    created = int(time.time())
    success = stable_openai_response(
        request_id=request_id,
        created_ts=created,
        resolved_model=resolved_model,
        assistant_text=filtered,
    )
    cache.set(uid, idempotency_key, messages_dicts, body.model, success)

    log_usage(
        request_id=request_id,
        resolved_model=resolved_model,
        cache_hit=False,
        upstream_invocation=True,
        latency_ms=(time.perf_counter() - t0) * 1000,
        upstream_http_status=200,
        idempotency_key=idempotency_key,
    )
    return success
