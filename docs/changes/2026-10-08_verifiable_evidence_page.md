# Verifiable evidence page for hiring reviewers

**Date:** 2026-10-08  
**Branch:** `cursor/verifiable-evidence-page-d7c2`

## Intent

Make the strongest portfolio claims **immediately checkable**: one page with
problem → design → source links → named tests → commands, plus CI verification
on `main`. Add an honest first-person contribution / AI-assisted workflow note
in the README without inventing production scale claims.

## Scope

- In: `docs/EVIDENCE.md`, README links + role/scope sections, pointer from
  `docs/interview_showcase.md`, changes index entry.
- Out: New features, CI/test weakening, Gemfile.lock, Claude-specific config.

## Proof

```bash
bash tool/check_docs_gardening.sh --paths README.md docs/EVIDENCE.md docs/interview_showcase.md docs/changes/2026-10-08_verifiable_evidence_page.md
cd apps/mobile && flutter test \
  test/features/counter/data/background_sync_counter_flow_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart \
  test/counter_cubit_test.dart \
  test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart \
  test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart \
  test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart
gh run view 37781041928 --json conclusion,workflowName
```
