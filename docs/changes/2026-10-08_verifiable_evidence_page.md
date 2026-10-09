# Verifiable evidence page for hiring reviewers

**Date:** 2026-10-08; reviewed 2026-10-09

**PR:** [#1012](https://github.com/redjadet/flutter_bloc_app/pull/1012)

## Intent and result

Make a reviewer follow one concrete problem to a design decision, an exact
regression, and a passing run. The README now leads with that route before the
badge groups. Its contribution statement identifies İlker Sevim's design,
review, and validation responsibility while acknowledging AI-assisted work.
The evidence page is indexed from the documentation hub and interview showcase.

The first case explains why a late remote snapshot must not overwrite newer
local counter state. Its adversarial regression advances local state during a
remote pull and asserts that the newer unsynchronized value survives.

## Review corrections

- Correct the architecture command's working directory: app tests run in a
  subshell so the root-level folder-contract script remains runnable.
- Describe CounterCubit persistence, diagnostics, and time dependencies accurately.
- Distinguish mocked channels and the separate secure-messaging injected FFI
  gateway from actual native runtime execution; macOS uses real FFI symbols.
- Replace exactly-once/distributed-counter implications with the tested snapshot
  reconciliation and queue replay contract.
- Distinguish a passing maintenance checklist from app test execution; a green
  run that skipped app coverage is not evidence for the named app regressions.

## Scope and responsibility

Six reviewer-facing documentation files changed: README.md, docs/EVIDENCE.md,
docs/README.md, docs/interview_showcase.md, this note, and docs/changes/README.md.
The required freshness gate also refreshed ten existing `ai/` discovery/index
files through the canonical generator (metadata and bounded metrics only).
No runtime implementation or CI policy changed. Current `origin/main` (`946b1c4`) was
integrated before validation. Codex performed this review and evidence audit in
an isolated managed worktree under the user's requested portfolio goals; the
repository owner retains the merge decision. Local task planning is gitignored.

## Proof commands

From the repository root:

```bash
bash tool/workspace_pub_get.sh
(cd apps/mobile && flutter test --no-pub --reporter expanded \
  test/features/counter/data/background_sync_counter_flow_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart \
  test/counter_cubit_test.dart \
  test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart \
  test/features/native_platform_showcase/data/method_channel_native_security_showcase_service_test.dart \
  test/features/native_platform_showcase/data/native_security_channel_reply_mapper_test.dart \
  test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart \
  test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart \
  test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart \
  test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart)
bash tool/check_feature_folder_contract.sh
bash tool/check_docs_gardening.sh --paths README.md docs/EVIDENCE.md docs/README.md docs/interview_showcase.md docs/changes/2026-10-08_verifiable_evidence_page.md docs/changes/README.md
AGENT_MEMORY_AUTO_MAINTAIN=0 bash tool/check_agent_knowledge_base.sh
bash tool/refresh_ai_reports.sh
bash tool/check_ai_snapshot_freshness.sh --strict-head
DART_DATA_HOME=/tmp/pr-1012-dart-data ./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```

All ten linked Dart test files passed locally: **115 tests** (2026-10-09).
Docs gardening, feature-folder contract, knowledge-base checks, strict snapshot
freshness, fast checklist, and agent closeout also passed.
The initial fast checklist failed because the host's cached Dart MCP executable
was missing; the task-local `DART_DATA_HOME` above provides a clean tool cache
without changing the repository's gates or the host's existing installation.

Format and analyze are N/A for this documentation-only diff. Native device
behavior, production traffic/scale, and additional professional platform years
are outside the claims. Recorded hosted results and their proof boundaries live
in [EVIDENCE.md](../EVIDENCE.md).
