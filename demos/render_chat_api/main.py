"""FastAPI entrypoint: Render chat orchestration demo (v1)."""

from __future__ import annotations

import asyncio
import logging
import uuid
from contextlib import asynccontextmanager
from typing import Any, Optional

import httpx
from fastapi import FastAPI, Header, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from auth import CallerAuthError, verify_caller_uid, verify_demo_secret
from orchestration.concurrency_gate import ConcurrencyGate
from orchestration.pipeline import OrchestrationError, run_pipeline
from orchestration.rate_limit import SlidingWindowCounter
from orchestration.response_cache import ResponseCache
from schemas import ChatCompletionRequest, ErrorBody
from settings import FROZEN_ALLOW_HEADERS, get_settings, parse_cors_origins, resolve_deploy_sha

logger = logging.getLogger(__name__)


def _telemetry_headers(
    *,
    server_request_id: str,
    client_correlation_id: str | None,
) -> dict[str, str]:
    """Headers so the Flutter client can match logs to server_request_id."""
    out: dict[str, str] = {"X-Server-Request-Id": server_request_id}
    if client_correlation_id:
        out["X-Client-Correlation-Id"] = client_correlation_id
    return out


def _render_meta_payload(
    *,
    server_request_id: str,
    client_correlation_id: str | None,
) -> dict[str, str]:
    """JSON alongside chat completion so clients still correlate if proxies strip headers."""
    meta: dict[str, str] = {"server_request_id": server_request_id}
    if client_correlation_id:
        meta["client_correlation_id"] = client_correlation_id
    return meta


def _error_response(
    *,
    status_code: int,
    code: str,
    message: str,
    request_id: str,
    retryable: bool,
) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content=ErrorBody(
            code=code,
            message=message,
            request_id=request_id,
            retryable=retryable,
        ).model_dump(),
    )


def _client_ip(request: Request) -> str:
    """Direct peer address only. Do not trust X-Forwarded-For (spoofable)."""
    return request.client.host if request.client else "unknown"


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    if settings.caller_auth_mode == "test_bypass" and not settings.allow_test_auth_bypass:
        raise RuntimeError("CALLER_AUTH_MODE=test_bypass requires ALLOW_TEST_AUTH_BYPASS=1")
    app.state.settings = settings
    app.state.cache = ResponseCache(
        ttl_seconds=settings.response_cache_ttl_seconds,
        max_entries=settings.response_cache_max_entries,
    )
    app.state.http = httpx.AsyncClient()
    app.state.gate_120b = ConcurrencyGate(settings.max_concurrent_120b)
    app.state.rate_uid = SlidingWindowCounter(
        limit=settings.rate_limit_per_uid_per_minute,
    )
    app.state.rate_ip = SlidingWindowCounter(
        limit=max(60, settings.rate_limit_per_uid_per_minute * 2),
    )
    yield
    await app.state.http.aclose()


app = FastAPI(title="Render Chat Orchestration API", lifespan=lifespan)


@app.middleware("http")
async def max_body_guard(request: Request, call_next):
    """Enforce MAX_BODY_BYTES for Content-Length and for streamed bodies without it."""
    settings = get_settings()
    max_bytes = settings.max_body_bytes
    cl = request.headers.get("content-length")
    if cl is not None:
        try:
            length = int(cl)
        except ValueError:
            rid = str(uuid.uuid4())
            return _error_response(
                status_code=400,
                code="invalid_request",
                message="Invalid Content-Length header.",
                request_id=rid,
                retryable=False,
            )
        if length > max_bytes:
            rid = str(uuid.uuid4())
            return _error_response(
                status_code=413,
                code="invalid_request",
                message="Request body too large.",
                request_id=rid,
                retryable=False,
            )
        return await call_next(request)

    if request.method in {"POST", "PUT", "PATCH"}:
        body = bytearray()
        async for chunk in request.stream():
            body.extend(chunk)
            if len(body) > max_bytes:
                rid = str(uuid.uuid4())
                return _error_response(
                    status_code=413,
                    code="invalid_request",
                    message="Request body too large.",
                    request_id=rid,
                    retryable=False,
                )
        cached = bytes(body)

        async def receive() -> dict[str, Any]:
            return {"type": "http.request", "body": cached, "more_body": False}

        request = Request(request.scope, receive)
    return await call_next(request)


def _attach_cors(application: FastAPI) -> None:
    settings = get_settings()
    application.add_middleware(
        CORSMiddleware,
        allow_origins=parse_cors_origins(settings.cors_origins),
        allow_credentials=True,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=list(FROZEN_ALLOW_HEADERS),
        expose_headers=["*"],
    )


_attach_cors(app)


@app.exception_handler(OrchestrationError)
async def orchestration_handler(_: Request, exc: OrchestrationError) -> JSONResponse:
    rid = str(uuid.uuid4())
    return JSONResponse(
        status_code=exc.http_status,
        content=ErrorBody(
            code=exc.code,
            message=str(exc),
            request_id=rid,
            retryable=exc.retryable,
        ).model_dump(),
    )


@app.exception_handler(CallerAuthError)
async def caller_auth_handler(request: Request, exc: CallerAuthError) -> JSONResponse:
    rid = getattr(request.state, "request_id", None) or str(uuid.uuid4())
    logger.info(
        "auth_failure",
        extra={"request_id": rid, "auth_failure_reason": exc.reason},
    )
    return JSONResponse(
        status_code=401,
        content=ErrorBody(
            code="auth_required",
            message="Caller authentication failed.",
            request_id=rid,
            retryable=False,
        ).model_dump(),
    )


@app.exception_handler(RequestValidationError)
async def validation_handler(_: Request, __: RequestValidationError) -> JSONResponse:
    rid = str(uuid.uuid4())
    return JSONResponse(
        status_code=422,
        content=ErrorBody(
            code="invalid_request",
            message="Invalid request body.",
            request_id=rid,
            retryable=False,
        ).model_dump(),
    )


@app.get("/health")
async def health() -> dict[str, str]:
    """Liveness: process is up. Does not imply upstream credentials are configured."""
    return {"status": "ok"}


@app.get("/ready")
async def ready(request: Request) -> JSONResponse:
    """Readiness: required config present for serving chat completions."""
    settings: Any = request.app.state.settings
    sha = resolve_deploy_sha(settings)
    build_id = (settings.build_id or "").strip() or None
    checks: dict[str, bool] = {
        "settings_loaded": True,
        "hf_credential_configured": bool((settings.hf_api_key or "").strip()),
    }
    if settings.caller_auth_mode == "firebase":
        checks["firebase_project_configured"] = bool(
            (settings.firebase_project_id or "").strip()
        )
    else:
        checks["firebase_project_configured"] = True
        checks["test_bypass_enabled"] = bool(settings.allow_test_auth_bypass)

    ready_ok = all(checks.values())
    payload: dict[str, Any] = {
        "status": "ready" if ready_ok else "not_ready",
        "checks": checks,
    }
    if sha:
        payload["git_sha"] = sha
    if build_id:
        payload["build_id"] = build_id
    return JSONResponse(status_code=200 if ready_ok else 503, content=payload)


@app.post("/v1/chat/completions", response_model=None)
async def chat_completions(
    request: Request,
    body: ChatCompletionRequest,
    authorization: Optional[str] = Header(default=None),
    x_render_demo_secret: Optional[str] = Header(default=None, alias="X-Render-Demo-Secret"),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
    x_client_correlation_id: Optional[str] = Header(
        default=None,
        alias="X-Client-Correlation-Id",
    ),
) -> JSONResponse:
    settings: Any = request.app.state.settings
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    client_correlation_id = (x_client_correlation_id or "").strip() or None
    if client_correlation_id and len(client_correlation_id) > settings.max_correlation_id_len:
        return JSONResponse(
            status_code=422,
            content=ErrorBody(
                code="invalid_request",
                message="X-Client-Correlation-Id is too long.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
            headers=_telemetry_headers(
                server_request_id=request_id,
                client_correlation_id=None,
            ),
        )

    verify_demo_secret(
        settings=settings,
        x_render_demo_secret=x_render_demo_secret,
    )

    client_ip = _client_ip(request)
    logger.info(
        "chat_completions_begin server_request_id=%s client_correlation_id=%s client_ip=%s",
        request_id,
        client_correlation_id or "",
        client_ip,
    )
    if not request.app.state.rate_ip.check(client_ip):
        return JSONResponse(
            status_code=429,
            content=ErrorBody(
                code="rate_limited",
                message="Too many requests from this IP.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
            headers=_telemetry_headers(
                server_request_id=request_id,
                client_correlation_id=client_correlation_id,
            ),
        )

    # Firebase verification is sync/blocking; run off the event loop.
    uid = await asyncio.to_thread(
        verify_caller_uid,
        settings=settings,
        authorization=authorization,
    )

    if not request.app.state.rate_uid.check(uid):
        return JSONResponse(
            status_code=429,
            content=ErrorBody(
                code="rate_limited",
                message="Too many requests for this user.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
            headers=_telemetry_headers(
                server_request_id=request_id,
                client_correlation_id=client_correlation_id,
            ),
        )

    if not idempotency_key or not idempotency_key.strip():
        return JSONResponse(
            status_code=422,
            content=ErrorBody(
                code="invalid_request",
                message="Idempotency-Key header is required.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
            headers=_telemetry_headers(
                server_request_id=request_id,
                client_correlation_id=client_correlation_id,
            ),
        )
    idem = idempotency_key.strip()
    if len(idem) > settings.max_idempotency_key_len:
        return JSONResponse(
            status_code=422,
            content=ErrorBody(
                code="invalid_request",
                message="Idempotency-Key is too long.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
            headers=_telemetry_headers(
                server_request_id=request_id,
                client_correlation_id=client_correlation_id,
            ),
        )

    hf_token = (settings.hf_api_key or "").strip()
    if not hf_token:
        return JSONResponse(
            status_code=503,
            content=ErrorBody(
                code="server_misconfigured",
                message="Hugging Face upstream credential is not configured.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
            headers=_telemetry_headers(
                server_request_id=request_id,
                client_correlation_id=client_correlation_id,
            ),
        )

    result = await run_pipeline(
        body=body,
        uid=uid,
        idempotency_key=idem,
        hf_token=hf_token,
        request_id=request_id,
        settings=settings,
        cache=request.app.state.cache,
        client=request.app.state.http,
        gate_120b=request.app.state.gate_120b,
    )
    logger.info(
        "chat_completions_ok server_request_id=%s client_correlation_id=%s uid=%s",
        request_id,
        client_correlation_id or "",
        uid,
    )
    enriched = {
        **result,
        "_render_meta": _render_meta_payload(
            server_request_id=request_id,
            client_correlation_id=client_correlation_id,
        ),
    }
    return JSONResponse(
        content=enriched,
        headers=_telemetry_headers(
            server_request_id=request_id,
            client_correlation_id=client_correlation_id,
        ),
    )
