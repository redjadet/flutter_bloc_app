---
generated: 2026-05-21
evidence: tool/modular_metrics.sh, ai/reports/*
---

# Architecture audit (`ARCH-###`)

Ranked issues for Phase 4 work. Target shape: [`docs/clean_architecture.md`](../clean_architecture.md).

| ID | Severity | Problem | Impact | Recommendation | Migration | Tests |
| --- | --- | --- | --- | --- | --- | --- |
| ARCH-001 | High | ~~`case_study_demo` imports `camera_gallery` and `supabase_auth` domain types~~ **Resolved** (2026-05-21) | Was cross-feature coupling | `MediaPickResult` / `MediaPickErrorKeys` in `lib/shared/media/`; `RemoteBackendAuthPort` in `lib/core/auth/` | M | `flutter test test/features/case_study_demo`; `modular_metrics.sh --cross-feature-only` (no `case_study_demo` edges) |
| ARCH-002 | High | `case_study_session_cubit_actions.part.dart` (~385 LOC) | Hard reviews; agent context overflow | Split actions into mixins/files by flow step | M | Existing cubit tests + new action unit tests |
| ARCH-003 | Medium | ~~Four features lack barrel~~ **Resolved** (2026-05-21 branch) | Was inconsistent import surfaces | `igaming_demo`, `case_study_demo`, `staff_app_demo`, `library_demo` barrels + tests | S | `test/features/*/*_barrel_test.dart` |
| ARCH-004 | Medium | Top features (`chat`, `todo_list`, `online_therapy_demo`) >4k LOC each | High change risk | Enforce Feature Brief + CONTEXT_MAP before edits | L | Integration tests per feature |
| ARCH-005 | Medium | `example` hub aggregates many demo routes | Accidental deps on hub | Route new demos independently when possible | S | Router tests |
| ARCH-006 | Medium | Multiple chat failure mappers | Divergent error mapping | Single mapper module | M | Mapper unit tests |
| ARCH-007 | Low | `walletconnect_auth` large part files (page + repo) | Same as ARCH-002 pattern | Decompose presentation/repository parts | M | Widget + repo tests |
| ARCH-008 | Low | `iot_demo` repository impl part >300 LOC | Sync path hard to follow | Extract Supabase vs persistent branches | M | Repository tests |
| ARCH-009 | Low | `online_therapy_demo` shell split across parts | Navigation/messaging unclear | Document flows in feature README (exists) | S | Existing demo tests |
| ARCH-010 | Low | Cross-feature list may grow beyond 11 edges | Metrics truncation hides deps | Run `--cross-feature-only` in CI doc refresh | S | N/A (metrics) |
| ARCH-011 | Info | Domain layer clean (no router/DI imports) | Positive baseline | Maintain guard in reviews | — | `modular_metrics.sh` |

## Cross-feature evidence (sample)

```text
case_study_demo → camera_gallery (domain)
case_study_demo → supabase_auth (domain)
```

Full: `bash tool/modular_metrics.sh --cross-feature-only`.

## Hotspot evidence

See [`ai/reports/context_hotspots.md`](../../ai/reports/context_hotspots.md) ranks 1–9.

## Target module shape (reference)

```text
lib/features/<feature>/
  <feature>.dart          # barrel (preferred)
  domain/                 # contracts, models
  data/                   # implementations
  presentation/           # cubit, pages, widgets
```

Do not start Phase 4 without linked Feature Brief and RED test.
