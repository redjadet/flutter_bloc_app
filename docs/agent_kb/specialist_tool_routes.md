# Specialist tool routes

Back: [Agent quick reference](../agents_quick_reference.md)

Load only for matching operation. Run tool router first; these are exact
commands and owner docs, not another cold-start checklist.

| Trigger | Route |
| --- | --- |
| iOS simulator / CocoaPods embed | `flutter build ios --simulator --debug`; `tool/check_ios_pod_framework_embed.sh --require-built-app` |
| Apple Keychain `-34018` / corrupted Hive box | [`apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md); `bash tool/check_apple_debug_hive_storage.sh`; cold-restart simulator |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Existing-code graph | `./tool/refresh_code_review_graph.sh --status-only` or `--if-needed`; [`code_review_graph.md`](../code_review_graph.md) |
| PR / CI / issue evidence | [`github_mcp_guide.md`](../ai/github_mcp_guide.md); `gh pr view` / checks |
| Repomix context pack | `bash tool/repomix_pack.sh onboarding`; [`repomix_profiles.md`](../ai/repomix_profiles.md) |
| AI snapshot freshness | `bash tool/check_ai_snapshot_freshness.sh`; `bash tool/refresh_ai_reports.sh` |
| Feature / app / package diff guard | `bash tool/check_ai_change_contract.sh [--base origin/main]` |
| Root design brief | `./tool/check_design_md.sh` |
| IDE-open preflight | `.vscode/tasks.json` → `./tool/local_ide_open_preflight.sh` when automatic tasks are allowed |
| Cross-host review, explicit only | `./tool/request_codex_feedback.sh`; plan: `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |
| Transcript budgets | `CURSOR_AGENT_TRANSCRIPTS_ROOT=... ./tool/check_transcript_budgets.sh` or `./bin/checklist-fast` |
| Hive shape change | `dart run tool/generate_hive_schema_fingerprints.dart --check-generated`; `bash tool/check_hive_schema_fingerprints.sh`; strict: `HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh` |
| Store release | Both: `./tool/release_both_stores.sh preflight` then deploy; Android: `./tool/release_android_play.sh preflight` / `upload_internal`; Fastlane: `./tool/fastlane.sh` |
| Workspace setup / codegen | `bash tool/workspace_pub_get.sh`; after dependency/member change: `dart run melos bootstrap` |
| Run, analyze, test Flutter app | `cd apps/mobile && flutter run -t lib/main_dev.dart`; `./tool/analyze.sh`; narrow: `cd apps/mobile && flutter test <paths>` |
| Analyze / test package | `dart run melos run analyze`; Dart: `dart run melos run test`; Flutter: `dart run melos run test:flutter` |
| Cache cleanup / stale Git refs | `./bin/clean-build-caches` or `./bin/prune-git-stale` dry-run first; use `--apply` only with authorized scope |

Hive runtime: non-null `HiveRepositoryBase.schema` → `getBox()` calls
`ensureSchema`; shape changes need manifest, spec, fingerprint, migrator, tests.
