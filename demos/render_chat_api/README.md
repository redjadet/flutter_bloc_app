# Render Chat API (FastAPI orchestration demo)

OpenAI-compatible `POST /v1/chat/completions` for the Flutter [`HuggingFaceResponseParser`](../../lib/features/chat/data/huggingface_response_parser.dart) path.

## FastAPI Cloud (current deployment)

- **Live URL**: `https://render-chat-api.fastapicloud.dev`
- **Docs**: `https://render-chat-api.fastapicloud.dev/docs`
- **Health**: `https://render-chat-api.fastapicloud.dev/health`

### Quick deploy (FastAPI Cloud)

From the repo root:

```bash
./tool/deploy_fastapi_cloud_chat_api.sh
```

### FastAPI Cloud required environment

When running with `CALLER_AUTH_MODE=firebase`, the server must know which Firebase project to validate tokens against:

- `CALLER_AUTH_MODE=firebase`
- `FIREBASE_PROJECT_ID=<your firebase project id>`

If `FIREBASE_PROJECT_ID` is missing, the service returns **401** on `POST /v1/chat/completions` and logs `FIREBASE_PROJECT_ID missing while caller_auth_mode=firebase`.

## IDE (Pyright / Basedpyright)

Create `.venv` and install deps (see below). This directory’s [`pyrightconfig.json`](./pyrightconfig.json) plus the repo root [`pyrightconfig.json`](../../pyrightconfig.json) point Pyright/Basedpyright at **`demos/render_chat_api/.venv`** so imports like `fastapi` and `httpx` resolve in Cursor/VS Code without using the system Python. **`../../tool/check_pyright_python.sh`** runs the same Pyright pass (and creates `.venv` if missing); it is part of **`./tool/delivery_checklist.sh`** / **`./bin/checklist`** so import and typing regressions fail early in CI and locally.

## Run locally

```bash
cd demos/render_chat_api
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export CALLER_AUTH_MODE=test_bypass ALLOW_TEST_AUTH_BYPASS=1
uvicorn main:app --reload --host 0.0.0.0 --port 8787
```

Production-style caller auth (Firebase ID tokens):

```bash
export CALLER_AUTH_MODE=firebase
export FIREBASE_PROJECT_ID=your-project-id
unset ALLOW_TEST_AUTH_BYPASS
uvicorn main:app --host 0.0.0.0 --port 8787
```

## Headers (frozen)

| Header | Purpose |
| --- | --- |
| `Authorization` | `Bearer <Firebase ID token>` |
| `X-HF-Authorization` | `Bearer <Hugging Face read token>` |
| `Idempotency-Key` | Required; stable per logical send |
| `X-Client-Correlation-Id` | Optional; echoed in logs and in success JSON **`_render_meta`** for Flutter ↔ server correlation |
| `X-Render-Demo-Secret` | Optional; must match `DEMO_SHARED_SECRET` when set |

Successful **`POST /v1/chat/completions`** responses merge OpenAI-shaped JSON with **`_render_meta`**: `server_request_id` (UUID) and `client_correlation_id` when the client sent the header. The same values are also set on response headers when intermediaries pass them through. See **Log correlation** in [`docs/integrations/render_fastapi_chat_demo.md`](../../docs/integrations/render_fastapi_chat_demo.md).

## Tests

```bash
cd demos/render_chat_api
pip install -r requirements.txt
python -m pytest
```

Shared JSON fixtures live at [`../../test/fixtures/render_chat_contract/`](../../test/fixtures/render_chat_contract/).

## Docker / Render

See `Dockerfile` and `render.yaml`. The blueprint sets **`plan: free`** so Hobby workspaces validate without defaulting to paid **starter**. Use a **single** uvicorn worker when relying on in-process cache ([STOP #11](../../docs/plans/render_fastapi_chat_demo_plan.md)).

**Manual deploy from your machine:** with **`RENDER_API_KEY`** in the environment (for example `direnv`), run [`../../tool/trigger_render_chat_api_deploy.sh`](../../tool/trigger_render_chat_api_deploy.sh) from the repo root; hosted Render MCP cannot start deploys. The live image follows the **branch/commit** Render is pinned to, not uncommitted local edits alone.
