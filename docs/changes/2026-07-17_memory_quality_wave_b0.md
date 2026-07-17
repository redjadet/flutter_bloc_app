# 2026-07-17 — Memory quality Wave B0

Report-only full-suite leak tracking dry-run:

- Opt-in `--dart-define=MEMORY_LEAK_TRACKING_DRY_RUN=true` in `flutter_test_config.dart`
- `tool/run_memory_leak_tracking_dry_run.sh` + summarizer (always exit 0)
- Audit of leak classes / harness noise under `docs/audits/memory_quality_wave_b0_review_*.md`

Boundary: default remains `withIgnoredAll()`; no checklist/CI gate; no broad fixes.
Wave A rollback boundary: <https://github.com/redjadet/flutter_bloc_app/pull/550>
