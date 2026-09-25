# Render / FastAPI chat — ops (W12)

Operational runbook for the chat orchestration demo under
[`demos/render_chat_api/`](../../demos/render_chat_api/). Product freezes and
Flutter client wiring stay in
[`render_fastapi_chat_demo.md`](render_fastapi_chat_demo.md).

## Canonical deployment targets

| Target | Role | Public origin (typical) |
| --- | --- | --- |
| **FastAPI Cloud** | **Canonical** live demo | `https://render-chat-api.fastapicloud.dev` |
| **Render** (Docker blueprint) | Intentionally supported dual target | `https://flutter-bloc-render-chat-api.onrender.com` |

Both run the same tree (`demos/render_chat_api`). Drift ownership: prefer FastAPI
Cloud for day-to-day demos; keep Render blueprint + Dockerfile in sync when
changing runtime config. Flutter `CHAT_FASTAPICLOUD_*` / legacy `CHAT_RENDER_*`
defines must point at the chosen origin.

## Provenance

| Signal | Source | Where exposed |
| --- | --- | --- |
| Git commit | Set `GIT_SHA` at deploy (or rely on Render inject `RENDER_GIT_COMMIT`) | `GET /ready` → `git_sha` when present |
| Build id | Optional `BUILD_ID` | `GET /ready` → `build_id` |
| Image / deploy | Platform dashboard (FastAPI Cloud / Render deploy list) | Platform UI + deploy scripts |

Record the commit you deploy from (dirty trees are not provenance). Scripts:

- FastAPI Cloud: [`tool/deploy_fastapi_cloud_chat_api.sh`](../../tool/deploy_fastapi_cloud_chat_api.sh)
- Render trigger: [`tool/trigger_render_chat_api_deploy.sh`](../../tool/trigger_render_chat_api_deploy.sh)

Suggested local export before deploy:

```bash
export GIT_SHA="$(git rev-parse HEAD)"
# Platform-specific: also set BUILD_ID / service env GIT_SHA in Dashboard or MCP.
```

## Environment inventory

| Variable | Required | Notes |
| --- | --- | --- |
| `CALLER_AUTH_MODE` | Yes (prod: `firebase`) | `test_bypass` only with `ALLOW_TEST_AUTH_BYPASS=1` (never prod) |
| `FIREBASE_PROJECT_ID` | When firebase | Missing → auth failures / not ready |
| `HUGGINGFACE_API_KEY` | Yes for chat | Server-only; never Flutter dart-define |
| `DEMO_SHARED_SECRET` | Optional | Matches `X-Render-Demo-Secret` when set |
| `CORS_ORIGINS` | Recommended | Comma-separated browser origins |
| `GIT_SHA` / `BUILD_ID` | Recommended | Provenance on `/ready` |
| `RENDER_API_KEY` | Operator shell only | Deploy trigger / MCP — never Flutter |
| `MAX_BODY_BYTES` | Optional (default 256000) | Body guard |
| `MAX_CORRELATION_ID_LEN` | Optional (default 128) | Header bound |
| `MAX_IDEMPOTENCY_KEY_LEN` | Optional (default 128) | Header bound |
| `RATE_LIMIT_PER_UID_PER_MINUTE` | Optional | In-process counter |
| `MAX_CONCURRENT_120B` | Optional | Semaphore for large model |

Flutter compile-time routing (non-secret): see
[`render_fastapi_chat_demo.md`](render_fastapi_chat_demo.md) § Flutter client.

## Health vs readiness

| Path | Meaning | Fail |
| --- | --- | --- |
| `GET /health` | **Liveness** — process up | Rare (process down) |
| `GET /ready` | **Readiness** — HF key present; Firebase project when `caller_auth_mode=firebase` | **503** `not_ready` + `checks` |

Render blueprint `healthCheckPath` remains `/health` (liveness). Use `/ready`
after deploy and before claiming the service can serve chat.

## Pre-deploy smoke

From repo root (or `demos/render_chat_api`):

```bash
./tool/check_pyright_python.sh
cd demos/render_chat_api && python -m pytest
```

Post-deploy (authenticated request against the live origin):

```bash
# Replace TOKEN / ORIGIN. Expect 2xx with _render_meta, or intentional 4xx/5xx codes.
curl -sS -o /tmp/chat_smoke.json -w "%{http_code}\n" \
  -X POST "$ORIGIN/v1/chat/completions" \
  -H "Authorization: Bearer $FIREBASE_ID_TOKEN" \
  -H "Idempotency-Key: smoke-$(date +%s)" \
  -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"ping"}]}'
curl -sS "$ORIGIN/ready"
```

## Deploy observation + rollback

1. Trigger deploy (Cloud script or Render trigger script / Dashboard).
2. Watch platform deploy status until live.
3. Hit `/health` then `/ready`; confirm `git_sha` matches intended commit when set.
4. Run one authenticated smoke POST; grep logs for `server_request_id` /
   `X-Client-Correlation-Id` (see log correlation in the freezes doc).
5. **Rollback:** redeploy previous known-good commit/image from the platform
   history (FastAPI Cloud previous deploy / Render deploy rollback). Do not
   “fix forward” secrets mid-incident without rotation notes below.

## Cold start

Scale-to-zero plans can take tens of seconds on first request. Measurement
checklist + evidence table live in
[`render_fastapi_chat_demo.md`](render_fastapi_chat_demo.md) § Cold-start vs Flutter Dio.
Do not invent wall times — append measured rows only.

## Secret rotation

Human-owned. Never put rotated values in Flutter artifacts, Remote Config, or
chat transcripts.

| Secret | Where it lives | Rotate |
| --- | --- | --- |
| `HUGGINGFACE_API_KEY` | FastAPI Cloud + Render service env | Platform secret manager / Dashboard env → redeploy or restart → smoke POST → revoke old HF token in provider console |
| `DEMO_SHARED_SECRET` | Service env (+ optional mobile **dev** define) | Update server first; update local `.envrc` for debug only; never store/release builds |
| `RENDER_API_KEY` | Operator shell / Cursor MCP | Dashboard → Account API keys → create new → update `.envrc` / MCP → revoke old |
| Firebase caller tokens | Client SDK | User re-auth; no long-lived server cache of ID tokens |

If a secret was pasted into chat, logs, or a mobile build: treat as compromised
and rotate immediately. See also [`docs/security_and_secrets.md`](../security_and_secrets.md).

## Failure drill (manual)

| Drill | Steps | Pass |
| --- | --- | --- |
| Missing HF key | Unset service `HUGGINGFACE_API_KEY`, hit `/ready` + chat POST | `/ready` 503; POST `server_misconfigured` |
| Bad bearer | POST with `Authorization: Bearer not-a-token` | 401 `auth_required` |
| Oversized body | `Content-Length` > `MAX_BODY_BYTES` | 413 `invalid_request` |
| Upstream timeout | (staging) lower `HF_UPSTREAM_TIMEOUT_SECONDS` or block egress | Retryable upstream error codes per freezes |

## Threat-model hardening table

| Boundary | Abuse / failure | Current control | Required change or accepted risk | Test | Owner |
| --- | --- | --- | --- | --- | --- |
| HTTP body | Oversized / streamed body without `Content-Length` | Middleware enforces `MAX_BODY_BYTES` for CL and for streamed POST/PUT/PATCH | Done (W12) | `test_chat_rejects_oversized_content_length` | Agent / maintainer |
| Caller auth | Missing / malformed / expired Firebase token | `verify_firebase_bearer`; test bypass gated | Done; blocking verify runs via `asyncio.to_thread` | `test_chat_rejects_missing_auth` + live negative | Agent / maintainer |
| Auth provider | Google cert fetch hang | Sync verify in thread pool | Accepted residual: thread can still block a worker under extreme load | Manual / staging | Human |
| Client IP | Spoofed `X-Forwarded-For` | **Ignored** — rate limit uses direct peer only | Accepted: multi-proxy accuracy needs trusted proxy config (out of v1) | Code review `_client_ip` | Human |
| Rate limit / cache | Restart or multi-worker loss of in-memory state | Single uvicorn worker (STOP #11); in-process TTL cache | Accepted while no Redis; do not raise `--workers` | STOP #11 + ops note | Human |
| Idempotency | Duplicate sends / long keys | Required `Idempotency-Key` + length bound + response cache | Accepted: cache is in-memory (lost on restart) | `test_cache_hit_second_call_no_second_hf` | Agent |
| Correlation header | Huge / log-injection style header | `MAX_CORRELATION_ID_LEN` | Done (W12) | `test_chat_rejects_long_correlation_id` | Agent |
| Host / CORS | Browser cross-origin abuse | `CORS_ORIGINS` allowlist; fixed HF upstream URL (no user host) | Accepted: no TrustedHost middleware in v1 demo | CORS preflight manual | Human |
| Upstream HF | Timeout / non-JSON / oversized text | Timeouts + JSON parse + truncated error text | Accepted: assistant content size not hard-capped beyond HF | `test_upstream.py` | Agent |
| Secrets | Leak into Flutter / Remote Config | Release denylist + server-owned HF key | Keep rotation table above | `check_tracked_secret_literals` + release guards | Human |
| Logs | Tokens / prompts / PII | Auth failures log reason codes only; no bearer dump | Accepted: ensure future debug logs stay sanitized | Code review | Human |
| Dependency scan | Vulnerable wheels | Pinned `requirements.txt`; CI/pyright lane | Prefer Dependabot/renovate on Python deps | CI | Human |

## Links

- Freezes + Flutter client: [`render_fastapi_chat_demo.md`](render_fastapi_chat_demo.md)
- Demo README: [`demos/render_chat_api/README.md`](../../demos/render_chat_api/README.md)
- Security overview: [`docs/security_and_secrets.md`](../security_and_secrets.md)
