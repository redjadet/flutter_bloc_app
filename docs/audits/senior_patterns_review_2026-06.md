# Senior Patterns Review — June 2026

Evidence for the reduce-surprise program. Import/folder gates:
[`architecture_review_2026-06.md`](architecture_review_2026-06.md). Canonical guide:
[`../architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md).

**Grade key:** G Green · Y Yellow · R Red · — not scored

**Last updated:** 2026-06-19 (program implementation)

## Tier A

| Feature | P3 Boundaries | P4 States | P5 Decisions | P6 Errors | Notes |
| --- | --- | --- | --- | --- | --- |
| `remote_config` | G | G | G | Y | Skip code — sealed state reference |
| `counter` | Y | Y | G | G | Skip — document acceptable |
| `todo_list` | G | Y | G | G | PR-1A sync DTO; PR-3 merge + AppError |
| `native_platform_showcase` | G | G | G | G | Reference only |
| `iot` | G | Y | G | G | PR-2C-i connection phase sealed |
| `calculator` | G | G | G | G | Pattern 5 reference |
| `deeplink` | G | G | G | G | Skip |
| `profile` | G | G | G | G | PR-2A sealed state + ProfileFailure |

## Tier B (in scope)

| Feature | P3 | P4 | P5 | P6 | Notes |
| --- | --- | --- | --- | --- | --- |
| `chat` | G | G | Y | Y | PR-1C domain boundary; PR-2B sealed state |
| `ai_decision_demo` | G | R | Y | Y | PR-1B DTOs; state Equatable legacy |
| `graphql_demo` | G | Y | G | G | PR-1B DTOs |
| `scapes` | G | Y | Y | G | PR-3B typed load failure |
| `staff_app_demo` | R | Y | G | Y | PR-3B submit validator; Firestore maps deferred |

## Heuristic appendix (baseline grep)

Commands used at program start:

```bash
bash tool/check_clean_architecture_imports.sh
rg -n "fromJson|toJson" apps/mobile/lib/features/*/domain -g '*.dart'
rg -n "ViewStatus|Object\\? error|e\\.toString\\(" apps/mobile/lib/features -g '*.dart'
```

Findings driving PR backlog:

| Location | Issue | PR |
| --- | --- | --- |
| `todo_list/data/todo_payload_builder.dart` | `item.toJson()` on domain entity | PR-1A — **Fixed** (`TodoItemDto.fromDomain`) |
| `ai_decision_demo/domain/ai_decision_models.dart` | API `fromJson` in domain | PR-1B — **Fixed** (`data/ai_decision_dto.dart`) |
| `graphql_demo/domain/graphql_country.dart` | json_serializable in domain | PR-1B — **Fixed** (`data/graphql_country_dto.dart`) |
| `chat/domain/chat_repository.dart` | Vendor transport in domain | PR-1C — **Fixed** (`domain/chat_remote_path.dart`) |
| `profile/presentation/cubit/profile_state.dart` | ViewStatus + nullable user | PR-2A — **Fixed** (sealed union + `ProfileFailure`) |
| `chat/presentation/chat_state.dart` | Dual loading channels | PR-2B — **Fixed** |
| `iot/presentation/cubit/iot_ble_state.dart` | Flag soup | PR-2C-i — **Fixed** (connection lifecycle slice) |
| `todo_list/data/todo_merge_policy.dart` | Policy in data layer | PR-3 — **Fixed** (`domain/todo_merge_policy.dart`) |
| `scapes/presentation/scapes_cubit.dart` | `e.toString()` | PR-3B — **Fixed** |
| `staff_app_demo/.../staff_demo_proof_cubit_submit.part.dart` | Inline eligibility | PR-3B — **Fixed** (`domain/staff_demo_proof_submit_eligibility.dart`) |

## Program success criteria

1. Tier A: no **R** on P3–P6 — **met**
2. Tier B in-scope: no **R** on P3 or P6 — **met for program PRs**; `staff_app_demo` P3 stays **R** (Firestore `Map<String,dynamic>?` contract **deferred** per plan hard boundary — copy submit validator only)
3. [`CODE_QUALITY.md`](../CODE_QUALITY.md) todo_list AppError slice closed — **met**
4. AP-11…17 accurate in [`flutter-anti-patterns.md`](../flutter-anti-patterns.md) — **met**
