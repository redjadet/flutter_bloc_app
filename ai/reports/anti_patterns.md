# Anti-patterns (repo-specific)

Actionable smells observed in this codebase. Pair with [`docs/CODE_QUALITY.md`](../../docs/CODE_QUALITY.md).

| ID | Pattern | Evidence | Risk | Mitigation |
| --- | --- | --- | --- | --- |
| AP-01 | Cross-feature domain imports | `case_study_demo` imports `camera_gallery` / `supabase_auth` domain ([dependency_map.md](dependency_map.md)) | Hidden coupling; harder extraction | Extract shared contract to `lib/shared/` or invert dependency |
| AP-02 | Missing feature barrels | `case_study_demo`, `staff_app_demo`, `igaming_demo`, `library_demo` | Inconsistent public API surface | Add `<feature>.dart` export when touching feature |
| AP-03 | Large part files (>300 LOC) | `case_study_session_cubit_actions.part.dart` (385), walletconnect/todo/iot parts | Agent context blow-up; review fatigue | Split by use-case; link ARCH-### in audit |
| AP-04 | Duplicate exception mappers | Multiple `ChatRemoteFailureException` mappers in `chat/data/` | Divergent error UX | Consolidate mapper behind single entry |
| AP-05 | State type name collisions | `CounterState` in validator + feature | Confusing grep / agent search | Prefix feature-specific states or import hides |
| AP-06 | God-route demo hubs | `example` hub routes many deferred demos | Navigation graph hard to scan | Keep catalog in `docs/feature_overview.md`; avoid new hub deps |
| AP-07 | Offline-first without doc link | IoT, todo, chat, search repos | Agents miss queue semantics | Point Feature Brief to [`docs/offline_first/adoption_guide.md`](../../docs/offline_first/adoption_guide.md) |
| AP-08 | Settings as integration junk drawer | Diagnostics + theme + entry points | Touch blast radius | New integrations get own feature or doc section |
| AP-09 | Generated-code noise in search | `.freezed.dart` / `.g.dart` in broad ripgrep | Wasted agent tokens | Exclude globs in search (see `ai/README.md`) |
| AP-10 | Metrics-only cross-feature list truncated | modular_metrics truncates long edge list | Miss new coupling | Re-run `--cross-feature-only` before large refactors |

## Not anti-patterns here

- **Clean Architecture layering** — domain has no router/DI imports (verified).
- **Cubit-first state** — aligns with [`docs/state_management_choice.md`](../../docs/state_management_choice.md).
- **Deferred routes** — intentional bundle strategy ([`docs/feature_overview.md`](../../docs/feature_overview.md)).
