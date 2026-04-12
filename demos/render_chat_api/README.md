# Render Chat API (FastAPI orchestration demo)

OpenAI-compatible `POST /v1/chat/completions` for the Flutter [`HuggingFaceResponseParser`](../../lib/features/chat/data/huggingface_response_parser.dart) path.

## IDE (Pyright / Basedpyright)

Create `.venv` and install deps (see below). The repo root [`pyrightconfig.json`](../../pyrightconfig.json) pins **`demos/render_chat_api/.venv`** so imports like `fastapi` and `httpx` resolve in Cursor/VS Code without using the system Python.

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
| `X-Render-Demo-Secret` | Optional; must match `DEMO_SHARED_SECRET` when set |

## Tests

```bash
cd demos/render_chat_api
pip install -r requirements.txt
python -m pytest
```

Shared JSON fixtures live at [`../../test/fixtures/render_chat_contract/`](../../test/fixtures/render_chat_contract/).

## Docker / Render

See `Dockerfile` and `render.yaml`. Use a **single** uvicorn worker when relying on in-process cache ([STOP #11](../../docs/plans/render_fastapi_chat_demo_plan.md)).
