# Checklist quality gates (MVP)

**Date:** 2026-05-20

## Summary

Wired four quality-theme scripts into `tool/delivery_checklist.sh`, added
`CHECK_SCRIPT_THEMES` (59 entries), path-triggered `./bin/router_feature_validate`
from checklist, and documented baseline + routing.

## Changes

- **Fail:** `check_navigation_outside_presentation.sh`, `check_sync_io_in_presentation.sh`
- **Warn (exit 0) at MVP ship:** `check_remote_image_cache_hints.sh`, `check_cubit_subscription_cancel.sh` — promoted to **fail** 2026-06-03 ([`2026-06-03_checklist_warn_gates_promoted.md`](2026-06-03_checklist_warn_gates_promoted.md))
- **Fixtures** + presentation `existsSync` fixes (staff demo, case study compute)
- **Regression:** `background_sync_coordinator_test.dart` in `check_regression_guards.sh`
- **Docs:** [`plans/checklist_quality_gates_baseline.md`](../plans/checklist_quality_gates_baseline.md), [`plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md), theme section in [`validation_scripts.md`](../validation_scripts.md), routing matrix update

## Verification

```bash
bash tool/check_navigation_outside_presentation.sh
bash tool/check_sync_io_in_presentation.sh
bash tool/fix_validation_docs.sh
bash tool/validate_validation_docs.sh
bash -n tool/delivery_checklist.sh
flutter test test/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit_test.dart
CHECKLIST_SKIP_ROUTER_VALIDATE=1 ./bin/checklist
```

**Proof (2026-05-20):**

- Gates on `lib/`: pass (navigation, sync-io presentation, warn-only image cache + cubit subscription).
- Fixture matrix: documented in [`validation_scripts/catalog.md`](../validation_scripts/catalog.md) (Quality theme gates).
- `./bin/checklist` with coverage: pass (~4.3 min); coverage summary **71.22%** (README badge).
- Optional faster local run: `CHECKLIST_RUN_COVERAGE=0 CHECKLIST_SKIP_ROUTER_VALIDATE=1 ./bin/checklist` (~62s).
- Router trigger precision: `TP=6 FP=0 FN=0 TN=4` (`tool/check_router_trigger_precision.sh`).
- Staff proof cubit: 5 tests (duplicate submit, offline queue, validation overlap, missing signature/photo).

**Implementation notes:** Stray commas removed from `CHECK_SCRIPTS`/`CHECK_MESSAGES`; router auto-trigger parses multiline `.cursor/rules/router-feature-validation.mdc` globs; `CHECKLIST_EXPLAIN_THEMES=1` prints after metadata arrays are defined.

**Plan closure:** M0–M4 complete; optional `check_presentation_build_method_size.sh` cancelled. **Deferred / rejected** work: [`docs/plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md) (QG-D01–D10). MVP baseline: [`docs/plans/checklist_quality_gates_baseline.md`](../plans/checklist_quality_gates_baseline.md).

**Codex plan review:** Three delegate runs were aborted; no external review merged (not blocking MVP).
