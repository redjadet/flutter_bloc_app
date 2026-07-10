# Maintainability baseline — 2026-07-10

Point-in-time evidence for
[`docs/plans/2026-07-10_maintainability_program.md`](../plans/2026-07-10_maintainability_program.md).
Re-run after Phase 0 rebase onto current `origin/main`.

## Commands

```bash
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/modular_metrics.sh --cross-feature-only
bash tool/check_feature_folder_contract.sh
bash tool/check_feature_barrel_exports.sh
rg -n "getIt\.|GetIt\." apps/mobile/lib/features --glob '*.dart' -g '!*_test.dart'
```

## Results (worktree `codex/maintainability-program` @ `c324e1e5`, pre-rebase)

| Check | Result |
| --- | --- |
| Clean Architecture imports | Pass |
| Feature modularity leaks | Pass |
| Cross-feature imports | **0** edges |
| Feature folder contract | Pass |
| App → feature deep imports | **0** |
| Presentation GetIt soft seams | `chat_page.dart`, `iot_demo_cloud_tab.dart` (`BackendAvailability`) |

## Ranking decision

Hard seams empty → Slice 1 = inject `BackendAvailability` into chat + IoT cloud
presentation (remove GetIt from those call sites).

## Soft-scan GetIt hits (presentation-relevant)

- `apps/mobile/lib/features/chat/presentation/pages/chat_page.dart`
- `apps/mobile/lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart`
- `apps/mobile/lib/features/chat/data/chat_render_orchestration_diagnostics.dart` (data layer — out of Slice 1)

Update this file after rebase if any row changes.
