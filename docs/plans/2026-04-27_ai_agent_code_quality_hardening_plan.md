# AI-Agent Code Quality Hardening Plan

## Summary

This plan prepares Cursor agents to harden AI-agent guidance and scan/fix
AI-generated-code risk patterns without broad rewrites.

Execution rule: build this in small slices, in the order below. Do not expand
scope beyond the named docs, validation helper, and confirmed backend/demo
hardening candidates.

## Status

Implemented in-repo (2026-04-27):

- `docs/ai_code_review_protocol.md` includes AI-generated-code risk matrix.
- `tool/check_ai_generated_code_smells.sh` exists, has fixture coverage via
  `tool/run_harness_fixtures.sh`, and is wired into `tool/delivery_checklist.sh`.
- `supabase/functions/sync-graphql-countries/index.ts` request handling hardened.
- `demos/ai_decision_api` request validation tightened (length bounds + forbid unknown fields) with tests.
- `tool/check_pyright_python.sh` covers `demos/ai_decision_api` in addition to Render demo + `tool/`.

## Goal / Non-goals

**Goal**: make repo guidance + validation paths catch common AI-generated-code
failure modes early (before PR), and harden two known request surfaces without
rewriting architecture.

**Non-goals**:

- broad refactors, style churn, l10n/codegen changes, dependency upgrades
- turning demo surfaces into production services (unless explicitly requested)
- building a full static analyzer; helper stays high-signal + low-noise

Keep [`AGENTS.md`](../../AGENTS.md) short. Add at most one compact pointer for
AI-generated code risk scanning, then put durable detail in source docs:

- [`ai_code_review_protocol.md`](../ai_code_review_protocol.md)
- [`agent_knowledge_base.md`](../agent_knowledge_base.md)
- [`agents_quick_reference.md`](../agents_quick_reference.md)
- [`validation_scripts.md`](../validation_scripts.md)
- repo-managed Codex/Cursor host templates under `tool/agent_host_templates/`

The hardening should target concrete risks from the PDF and repo scan:
parameterized data access, secret handling, edge inputs, deprecated APIs,
swallowed errors, auth/ownership, concurrency, N+1 I/O, dependency provenance,
and adversarial tests.

## Build Contract (what “ready to start” means)

Work proceeds in **slices**. Each slice must end with:

- updated docs/scripts committed together (doc + code drift avoided)
- the narrowest honest validation lane run (see Test Plan)
- a short report note in the PR/commit description: commands + outcomes + residual risk

If a step discovers a **confirmed** issue outside this write set: stop, record it
under “Risks/Findings”, do not expand scope silently.

## Implementation Order

1. **Docs source of truth**: update
   [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) first, then
   add only routing pointers in
   [`agent_knowledge_base.md`](../agent_knowledge_base.md) and
   [`agents_quick_reference.md`](../agents_quick_reference.md).
2. **Validation helper**: create a `tool/` shell script named
   `check_ai_generated_code_smells.sh` with fixture coverage and document it in
   [`validation_scripts.md`](../validation_scripts.md).
3. **Host parity**: update repo-managed Codex/Cursor host templates only after
   source docs are correct, then run asset dry-run/drift checks.
4. **Code hardening**: fix `sync-graphql-countries` request handling and
   `demos/ai_decision_api` request validation.
5. **Python validation**: extend existing Python validation to include
   `demos/ai_decision_api` without weakening Render chat API checks.

## Concrete File Touch List (per step)

### Step 1 (Docs source of truth)

- Update:
  - [`ai_code_review_protocol.md`](../ai_code_review_protocol.md)
- Add routing pointers (small diffs only):
  - [`agent_knowledge_base.md`](../agent_knowledge_base.md)
  - [`agents_quick_reference.md`](../agents_quick_reference.md)
  - optionally [`AGENTS.md`](../../AGENTS.md) (one pointer max; no duplication)

### Step 2 (Validation helper)

- Add:
  - `tool/check_ai_generated_code_smells.sh`
  - fixtures directory for deterministic tests:
    - `tool/fixtures/ai_generated_code_smells/`
  - fixture harness (existing repo harness):
    - `tool/run_harness_fixtures.sh`
- Update:
  - [`validation_scripts.md`](../validation_scripts.md)

### Step 3 (Host parity)

- Update only repo-managed templates:
  - `tool/agent_host_templates/**` (exact files chosen by where review/checklist hooks live)
- Run:
  - `./tool/check_agent_asset_drift.sh` and `./tool/sync_agent_assets.sh --dry-run`

### Step 4 (Code hardening)

- Update:
  - `supabase/functions/sync-graphql-countries/index.ts`
  - `demos/ai_decision_api/**` (request schema + validation + tests)

### Step 5 (Python validation)

- Update the existing python validation script(s) that already cover `demos/render_chat_api`
  so `demos/ai_decision_api` gets comparable checks. Do not broaden beyond demos.

## Key Changes

- Update [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) with a
  compact AI-generated-code risk matrix. It must cover SQL/string concatenation
  and XSS-style injection, hardcoded secrets, missing edge cases, deprecated
  APIs/libraries, swallowed exceptions, missing auth/ownership checks, race
  conditions, excessive I/O, hallucinated dependencies, and weak tests that
  mirror code instead of behavior.
- Update [`agent_knowledge_base.md`](../agent_knowledge_base.md) and
  [`agents_quick_reference.md`](../agents_quick_reference.md)
  only where needed to route agents to the new review matrix and validation
  helper. Do not duplicate the full matrix in multiple files.
- Update [`validation_scripts.md`](../validation_scripts.md) when adding a new
  validation helper, and keep validation routing aligned with existing fast/full
  guidance.
- Sync shared behavior into Codex/Cursor host templates after source docs are
  updated. Host templates stay thin and point back to repo canon.
- Add a `tool/` shell script named `check_ai_generated_code_smells.sh`. Scope it
  to high-signal checks only: secret-looking literals, broad swallowed
  exceptions, obvious SQL/string interpolation, and risky auth/endpoint patterns.
  Support explicit allowlist comments with required reasons.
- Make helper output stable and greppable:
  - one finding per line
  - include file path + line + rule id
  - exit non-zero on findings unless allowlisted
- Harden `supabase/functions/sync-graphql-countries/index.ts` to match
  `sync-chart-trending` request handling: `POST`/`OPTIONS` only, CORS headers,
  invalid JSON handling, request type allowlist, and stable error responses.
- Harden `demos/ai_decision_api` request validation by adding bounded lengths
  for `CreateDecisionRequest.operator_note` and `CreateActionRequest.note`, plus
  tests for oversized, empty, malformed, and unknown-case payloads.
- Treat AI Decision API auth as a product decision: default is to document the
  API as demo-open by design. Add optional shared-secret auth only if existing
  Flutter/cloud config supports it cleanly and docs are updated in the same
  slice.
- Extend Python validation so `demos/ai_decision_api` gets the same import/type
  and test sanity attention currently focused on `demos/render_chat_api`.
- Do not touch unrelated app features, styling, generated localization, or broad
  architecture docs unless a listed change requires it.

## Acceptance Criteria

- Cursor can start from this plan without choosing files, defaults, or command
  lanes.
- [`AGENTS.md`](../../AGENTS.md) remains a compact map and does not duplicate the
  new matrix.
- New review guidance exists once, in
  [`ai_code_review_protocol.md`](../ai_code_review_protocol.md); other
  docs/templates only route to it.
- New smell helper has true-positive and allowlist fixture coverage before it
  is wired into checklist paths.
- Smell helper does not spam: baseline run should be clean or near-clean with
  explicit allowlists and required reasons.
- `sync-graphql-countries` rejects non-`POST`/`OPTIONS` methods and invalid
  request bodies predictably.
- AI Decision API rejects oversized notes and still passes existing happy-path
  decision/action tests.
- No auth requirement is added to AI Decision API unless the same slice updates
  Flutter/cloud configuration and docs. Default remains demo-open by design.
- Final report lists exact commands, results, blockers, and residual risk.

## Test Plan

- Agent/docs validation:
  - `./tool/check_agent_knowledge_base.sh`
  - `./tool/check_agent_asset_drift.sh`
  - `./tool/sync_agent_assets.sh --dry-run`
  - `./bin/checklist-fast`
- New smell guard:
  - Add fixture tests for true positives and allowlisted intentional patterns.
  - Run the new helper standalone.
  - Wire it into the smallest existing checklist path that matches its scope.
- Python demos:
  - `cd demos/ai_decision_api && python -m pytest`
  - `cd demos/render_chat_api && python -m pytest`
  - `./tool/check_pyright_python.sh` after extending Python validation scope.
- Supabase:
  - Add pure helper tests if request parsing is factored into testable helpers;
    otherwise run the closest available TypeScript/source validation.
  - If Deno is unavailable locally, report that validation boundary and rely on
    focused source review plus any repo-supported TypeScript checks.
  - Confirm `chat-complete` keeps `verify_jwt = true`; do not copy no-JWT
    public-sync behavior to sensitive endpoints.
- Final proof:
  - `git diff --check`
  - smallest honest repo command for the touched surface
  - final self-review against request, changed files, validation output,
    blockers, and residual risk

## Assumptions

- `README*.md` files stay out of agent-doc compression scope.
- [`AGENTS.md`](../../AGENTS.md) remains compact; detailed checklist content
  belongs in source docs.
- AI Decision API remains an MVP/demo surface unless the user explicitly asks
  for production auth.
- Existing user changes, including `.gitignore`, must not be reverted or folded
  into this work unless directly required.
- The implementation should be surgical: every changed line traces to this plan,
  a required validation/doc update, or a confirmed code hardening candidate.
- If implementation reveals a confirmed security issue outside this write set,
  stop and report the specific issue instead of broadening silently.

## Risks / Decisions to Record (don’t block start)

- **Smell helper false positives**: mitigate via fixtures + allowlist-with-reason.
- **Deno/Supabase function validation boundary**: if local Deno tooling absent,
  keep change small, add pure helper tests where possible, and rely on repo-supported checks.
- **AI Decision API auth**: keep demo-open unless explicitly asked; if adding shared-secret,
  update docs + config in the same slice, or do not add it.
