# Agents Appendix (Workspace + Tooling Facts)

This file holds detailed workspace specifics and tooling facts referenced by
[`AGENTS.md`](../AGENTS.md). Keep `AGENTS.md` lean; put long lists here.

## Local Lessons

User prefs:

- Keep `.cursorignore` local-only.
- Standalone plans/docs not built on feature branch -> branch from `main` /
  `origin/main`.
- Prefer reusable `.cursor/commands/*.md` over copy/paste prompt templates.
- External emails/messages: generic examples; no repo paths or “in this repo”.
- `docs/agents_quick_reference.md` = command cheat sheet, not policy source.
- Improve local dev workflows by changing repo directly when allowed.
- Long scroll pages: keep validation/status feedback pinned above scroll body.
- Prefer `./tool/run_codex_plan_review.sh` for Codex review of markdown plans.
- When shrinking canon, keep authority order + invariants + validation routing + review gate explicit.
- Run repo scripts/validation in agent session when shell exists.
- Globally available Cursor skill must exist under `~/.cursor/skills/<skill>/SKILL.md`.

## Workspace

- Case studies: `docs/case_studies/`, start `docs/case_studies/README.md`.
- Dentists demo: `lib/features/case_study_demo/`, route `/case-study-demo`.
- Staff app demo: `lib/features/staff_app_demo/`, routes `/staff-app-demo`;
  router `lib/core/router/app_routes.dart`; walkthrough
  `docs/staff_app_demo_walkthrough.md`.
- Shell exposes `StaffDemoSitesCubit` from `staffDemoSites`; pages pick from
  list, no free-text IDs.
- Parsing must match seed/admin docs:
  `lib/features/staff_app_demo/data/staff_demo_site_firestore_map.dart`,
  `functions/tool/seed_staff_demo.js`,
  `test/features/staff_app_demo/data/staff_demo_seed_document_fixtures.dart`,
  `test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart`.
  Focused guards: `tool/check_regression_guards.sh`.

## Checks / Platform

- Never async `setState` callback. Do async first, `if (!mounted) return;`,
  then `setState(() { ... })`. Enforced by `tool/check_setstate_async.sh` and
  case-study regression test.
- `SecretConfig` tests: after `SecretConfig.resetForTest()`, set
  `SecretConfig.debugEnvironment = <String, dynamic>{}` when host
  `--dart-define` must not leak. Non-null `debugEnvironment` is only env tier.
- No `Isolate.run(` under `lib/**/presentation/**`; use `compute` or
  top-level/static worker. Enforced by
  `tool/check_no_isolate_run_in_presentation.sh`.
- Dialog overlay has separate subtree. Capture shell cubit before `showDialog`
  and wrap `BlocProvider.value`, or pass deps explicitly.
- Checklist flags unguarded `!`; prefer nullable trim + branch.
- Cursor Plan mode edits only plan/markdown-style files.
- Run integration tests one at time; concurrent runs conflict over Xcode/sims.
- Integration runner defaults to iOS simulator unless explicitly overridden.
- Dart2JS: avoid `1 << 32` as `Random.nextInt` max; use smaller chunking.
- Flutter web isolate demos can hang if `Isolate.spawn` never delivers; guard
  with `kIsWeb` fallback.

## Supabase / Hugging Face

- Plan: `docs/plans/supabase_proxy_huggingface_chat_plan.md`.
- Supabase `chat-complete`: keep `verify_jwt = true`.
- Dashboard **Verify JWT with legacy secret** disabled unless intentionally
  using legacy JWT-secret path.
- Align error codes: `401 -> auth_required`, `403 -> forbidden`,
  `429 -> rate_limited`, timeout -> `upstream_timeout`, transport/5xx ->
  `upstream_unavailable`, request/model `4xx` like `404` -> `invalid_request`.

## Tooling Facts

- `.cursor/*`, `tasks/*`, `.code-review-graph/` ignored.
- Host templates: see Host sync + Validation Routing.
- `./tool/refresh_code_review_graph.sh` refreshes local graph after large changes.
- Integration tests fail on warning/error logs unless narrowly allowlisted in
  `integration_test/test_harness.dart`.
- Markdownlint ignores task trackers via `.markdownlintignore` and
  `.markdownlint-cli2ignore`.
- `tool/check_dialog_text_controller_lifecycle.sh` / `.py` runs in checklist;
  flags local `TextEditingController(` inside async blocks in dialog files.
  Prefer Stateful dialog content with controllers in `initState` + `dispose()`.
- `tool/normalize_doc_links.py` preserves `#fragment`; test
  `tool/normalize_doc_links_test.py`.
- Plan-only Codex review: `./tool/run_codex_plan_review.sh` +
  `tool/codex_plan_review_template.md`; `request_codex_feedback.sh` reviews
  git diffs only.
- Render FastAPI chat: plan
  `docs/plans/render_fastapi_chat_demo_plan.md`; contract fixtures
  `test/fixtures/render_chat_contract/` and `demos/render_chat_api`.
- Render chat ops: add `CHAT_RENDER_*` defines in
  `tool/flutter_dart_defines_from_env.sh`; `_render_meta` body fields may
  exist; redeploy with `./tool/trigger_render_chat_api_deploy.sh`.
- Python/Pyright: `./tool/check_pyright_python.sh` expects Python >= 3.10.
  Pyright root config needs top-level `venvPath`/`venv`; exclude `**/.venv`.
  Demo editor config: `demos/render_chat_api/pyrightconfig.json` + README.
