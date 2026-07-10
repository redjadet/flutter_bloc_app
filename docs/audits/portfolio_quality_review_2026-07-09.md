# Portfolio Quality Review — 2026-07-09

ADR-0005 scoped review after Engineering Quality scorecard rollout (Waves 0–5).

## Overall

| Dimension | Score | Evidence |
| --- | ---: | --- |
| Agent measurement honesty | 5/5 | Engineering scorecard + badge + `check_engineering_quality_scorecard_gate.sh` wired; Harness ≠ Engineering documented |
| Architecture / modularity | 5/5 | Clean-arch + modularity scripts green; 0 cross-feature edges |
| Pattern program (showcase) | 4.5/5 | Tier B `ai_decision_demo` P4 fixed (`@freezed` state); `staff_app_demo` P3 explicitly out-of-scorecard |
| Quality gates backlog | 4.5/5 | No bare `defer` rows; QG-D04 promoted warn with fixtures |
| Doc / validation honesty | 4.5/5 | Showcase stale numbers removed; README Observability aligned to ADR-0005 |
| Measured coverage | 5/5 | Filtered **85.33%** (≥85%); app shell **76.04%** (≥75%) — Wave 2 closed |
| Delivery proof | 5/5 | `./bin/checklist` exit 0; Delivery + Coverage scorecard areas 10/10 |

**Weighted overall (showcase scope): ~4.8/5** — Engineering **10/10** claim gate met when scorecard gate + proofs hold.

## Engineering scorecard snapshot

- Badge: **10/10** (min of areas)
- All areas at 10: Delivery, Coverage, Architecture, Quality gates honesty, Pattern program, Doc honesty, Validation honesty, Portfolio scope
- Wave 5 closeout: [`docs/changes/2026-07-10_portfolio_quality_wave5_closeout.md`](../changes/2026-07-10_portfolio_quality_wave5_closeout.md)

## Open items (in scope)

None for Waves 0–5. Further work is out of ADR-0005 interview scope unless a new wave is opened.

## Out of scope (explicit)

- Production auth roles/claims, Sentry/Mixpanel/Patrol, full PR iOS integration — per ADR-0005.

## Proof commands

```bash
bash tool/check_engineering_quality_scorecard_gate.sh
bash tool/update_engineering_quality_badge.sh --check
COVERAGE_THRESHOLD=85 dart run tool/update_coverage_summary.dart --enforce-threshold
bash tool/check_engineering_core_coverage.sh
./bin/checklist
./bin/integration_tests
bash tool/check_context_read_watch.sh --paths tool/fixtures/context_read_watch/presentation/
```
