"""FastAPI entrypoint: Render chat orchestration demo (v1)."""

from __future__ import annotations

import logging
import uuid
from contextlib import asynccontextmanager
from typing import Any, Optional, Union

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
from settings import FROZEN_ALLOW_HEADERS, get_settings, parse_cors_origins

logger = logging.getLogger(__name__)


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
    settings = get_settings()
    cl = request.headers.get("content-length")
    if cl is not None:
        try:
            if int(cl) > settings.max_body_bytes:
                rid = str(uuid.uuid4())
                return JSONResponse(
                    status_code=413,
                    content=ErrorBody(
                        code="invalid_request",
                        message="Request body too large.",
                        request_id=rid,
                        retryable=False,
                    ).model_dump(),
                )
        except ValueError:
            pass
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
async def health() -> dict:
    return {"status": "ok"}


@app.post("/v1/chat/completions", response_model=None)
async def chat_completions(
    request: Request,
    body: ChatCompletionRequest,
    authorization: Optional[str] = Header(default=None),
    x_hf_authorization: Optional[str] = Header(default=None, alias="X-HF-Authorization"),
    x_render_demo_secret: Optional[str] = Header(default=None, alias="X-Render-Demo-Secret"),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
) -> Union[JSONResponse, dict]:
    settings: Any = request.app.state.settings
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id

    verify_demo_secret(
        settings=settings,
        x_render_demo_secret=x_render_demo_secret,
    )

    client_ip = request.client.host if request.client else "unknown"
    if not request.app.state.rate_ip.check(client_ip):
        return JSONResponse(
            status_code=429,
            content=ErrorBody(
                code="rate_limited",
                message="Too many requests from this IP.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
        )

    uid = verify_caller_uid(settings=settings, authorization=authorization)

    if not request.app.state.rate_uid.check(uid):
        return JSONResponse(
            status_code=429,
            content=ErrorBody(
                code="rate_limited",
                message="Too many requests for this user.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
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
        )

    if not x_hf_authorization or not x_hf_authorization.lower().startswith("bearer "):
        return JSONResponse(
            status_code=401,
            content=ErrorBody(
                code="auth_required",
                message="Missing X-HF-Authorization bearer token.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
        )
    hf_token = x_hf_authorization.split(" ", 1)[1].strip()
    if not hf_token:
        return JSONResponse(
            status_code=401,
            content=ErrorBody(
                code="auth_required",
                message="Empty Hugging Face token.",
                request_id=request_id,
                retryable=False,
            ).model_dump(),
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
    return result
