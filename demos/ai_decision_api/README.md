# AI Decision API

Local FastAPI backend for the Flutter AI Decision Workbench at
`/ai-decision-demo`.

This is an MVP backend, not a production service. It exists to prove that the
app can select seeded cases, create decisions, show proof, persist decisions,
and record operator actions.

## Run Locally

```bash
cd demos/ai_decision_api
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
python -m seed_data --reset
uvicorn main:app --reload --host 127.0.0.1 --port 8008
```

The backend creates the local SQLite database at:

```text
demos/ai_decision_api/.data/ai_decision_demo.sqlite3
```

The `.data/` directory is runtime state and should not be committed.

## Seeded Cases

`python -m seed_data --reset` creates six demo cases:

| Case ID | Risk shape |
| --- | --- |
| `case_low_001` | Stable revenue, long history |
| `case_low_002` | Excellent credit, strong revenue |
| `case_med_001` | Medium credit, growth-stage business |
| `case_med_002` | Seasonality, moderate revenue |
| `case_high_001` | Prior default, low revenue |
| `case_high_002` | Multiple defaults, young business |

Use `case_high_001` and `case_low_001` in demos to show the score and proof
changing visibly.

## Endpoints

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/health` | Backend status and similar-case mode. |
| `GET` | `/cases` | Seeded case queue. |
| `GET` | `/cases/{case_id}` | Case context, latest decision, and action history. |
| `POST` | `/cases/{case_id}/decision` | Create and persist a decision with proof. |
| `POST` | `/cases/{case_id}/actions` | Record an operator action. |

## Quick Manual Checks

```bash
curl -s http://127.0.0.1:8008/health | python -m json.tool
curl -s http://127.0.0.1:8008/cases | python -m json.tool
curl -s http://127.0.0.1:8008/cases/case_high_001 | python -m json.tool
curl -s -X POST http://127.0.0.1:8008/cases/case_high_001/decision \
  -H 'content-type: application/json' \
  -d '{"operator_note":"Check seasonality"}' | python -m json.tool
curl -s -X POST http://127.0.0.1:8008/cases/case_high_001/actions \
  -H 'content-type: application/json' \
  -d '{"action_type":"request_docs","note":"Need bank statements"}' | python -m json.tool
```

## Decision Proof

`POST /cases/{case_id}/decision` returns and persists:

- `risk_score`
- `risk_band`
- `recommended_action`
- `rationale`
- `signals`
- `proof.input_snapshot`
- `proof.base_score`
- `proof.final_score`
- `proof.rule_trace`
- `proof.band_thresholds`
- `proof.evidence`
- `proof.similar_case`
- `proof.confidence`

`GET /cases/{case_id}` returns `latest_decision` with the same proof payload so
Flutter can reopen a case and still show the decision evidence.

## Optional Similar Cases

Rules-only mode is the default and is the canonical MVP path. The MiniLM
feature can be enabled with environment variables, but the matcher does nothing
unless `ENABLE_SIMILAR_CASES=true`.

### Local MiniLM (sentence-transformers)

Enable local MiniLM similar-case support:

```bash
cd demos/ai_decision_api
source .venv/bin/activate
ENABLE_SIMILAR_CASES=true uvicorn main:app --reload --host 127.0.0.1 --port 8008
```

The default model is `sentence-transformers/all-MiniLM-L6-v2`, using
`reference_cases.json` as the local reference set. If the model fails to load,
the API falls back to rules-only decisions instead of failing the workbench.

### FastAPI Cloud MiniLM (HF Inference router)

On FastAPI Cloud, this demo uses **Hugging Face Inference Providers** (HF
Inference) via the router endpoint. This avoids loading `sentence-transformers`
in a small cloud runtime and still produces a real similar-case signal.

You must set these environment variables in FastAPI Cloud:

- `ENABLE_SIMILAR_CASES=true`
- `HUGGINGFACE_API_KEY` (secret)

Then redeploy.

To verify the signal is actively used (not just enabled), run:

```bash
curl -s -X POST https://ai-decision-api.fastapicloud.dev/cases/case_high_001/decision \
  -H 'content-type: application/json' \
  -d '{"operator_note":"Check seasonality"}' | python -m json.tool
```

Look for:

- `meta.similar_cases_used = true`
- `proof.confidence = "complete"`
- `proof.similar_case.used = true`
- `proof.similar_case.contribution` is non-zero

Useful environment variables:

| Variable | Default |
| --- | --- |
| `SQLITE_PATH` | `.data/ai_decision_demo.sqlite3` under this folder |
| `ALLOW_SEED_ON_STARTUP` | `true` |
| `ENABLE_SIMILAR_CASES` | `false` |
| `SIMILAR_CASES_PROVIDER` | `local` (best-effort; cloud may auto-fallback to HF if available) |
| `SIMILAR_CASES_MODEL` | `sentence-transformers/all-MiniLM-L6-v2` |
| `REFERENCE_CASES_PATH` | `reference_cases.json` under this folder |

## Tests

```bash
cd demos/ai_decision_api
source .venv/bin/activate
python -m seed_data --reset
python -m pytest
```

## Flutter Pairing

Run the Flutter app from the repo root. All platforms default to the hosted
FastAPI Cloud deployment:

```bash
flutter run -d chrome
```

For local backend development, pass the local backend explicitly:

```bash
flutter run --dart-define=AI_DECISION_API_BASE_URL=http://127.0.0.1:8008
```

Then open the Example hub and choose **AI Decision Workbench**.

## FastAPI Cloud Preview

The current web app default expects this backend on FastAPI Cloud. Deploy this
folder with:

```bash
cd demos/ai_decision_api
source .venv/bin/activate
fastapi login
fastapi deploy
```

To enable MiniLM on FastAPI Cloud, add environment variables (dashboard is the
most reliable):

```bash
fastapi cloud env set ENABLE_SIMILAR_CASES true .
fastapi cloud env set --secret HUGGINGFACE_API_KEY "hf_..." .
fastapi deploy
```

Verify the deployed backend before running Flutter web:

```bash
curl -s https://ai-decision-api.fastapicloud.dev/health | python -m json.tool
```

Expected MiniLM-enabled health shape:

```json
{
  "status": "ok",
  "similar_cases_enabled": true,
  "model": "sentence-transformers/all-MiniLM-L6-v2"
}
```

To test a different FastAPI Cloud app, override the base URL:

```bash
flutter run --dart-define=AI_DECISION_API_BASE_URL=https://YOUR_APP.fastapicloud.dev
```
