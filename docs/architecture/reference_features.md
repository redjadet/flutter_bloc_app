# Reference Features (Gold Layout)

Agents need in-repo examples that match
[`feature_structure_contract.md`](feature_structure_contract.md). Copy these
layouts — not legacy demos listed under [Legacy drift](#legacy-drift).

## Gold references

Semantic grades (P3–P6): G/Y/R — detail in
[`senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md).
Pattern guide: [`reduce_surprise_patterns.md`](reduce_surprise_patterns.md).

| Feature | Why copy it | P3 | P4 | P5 | P6 | Key paths |
| --- | --- | --- | --- | --- | --- | --- |
| `remote_config` | Full stack, offline-first, sealed Freezed state | G | G | G | Y | `lib/features/remote_config/` |
| `profile` | Sealed lifecycle + typed `ProfileFailure` | G | G | G | G | `lib/features/profile/presentation/cubit/` |
| `todo_list` | DTO sync boundary, domain merge policy, AppError | G | Y | G | G | `data/todo_item_dto.dart`, `domain/todo_merge_policy.dart` |
| `native_platform_showcase` | Platform ports; command `MethodChannel`, streaming `EventChannel`, FFI; cubit → use cases only | G | G | G | G | `domain/use_cases/`, `data/*_service.dart` |
| `deeplink` | Sealed deep-link state | G | G | G | G | `presentation/cubit/deep_link_state.dart` |
| `calculator` | Pure domain payment rules | G | G | G | G | `domain/payment_calculator.dart` |
| `counter` | Offline-first + `CounterError` | Y | Y | G | G | `presentation/cubit/`, `domain/counter_error.dart` |
| `case_study_demo` | Smaller standard cubit folder | G | Y | G | G | `presentation/cubit/` |
| `iot_demo` | Cubit + domain/data split | G | Y | G | G | `presentation/cubit/` |
| `iot` | BLE mappers + phased connection state | G | Y | G | G | `lib/features/iot/` |

Scaffold output (no runtime code) matches the same shape:
[`feature_brief_scaffold_example.md`](feature_brief_scaffold_example.md).

## Do not copy

| Feature / path | Reason |
| --- | --- |
| `ai_decision_demo` (state) | Equatable bag state — copy DTO boundary only until state migrates |
| `staff_app_demo` Firestore maps | `Map<String,dynamic>?` contract — deferred; copy submit validator pattern only |

## Legacy drift

Default scan warns but does not fail CI until legacy features migrate.
Known legacy paths are listed in
[`tool/config/legacy_feature_folder_allowlist.txt`](../../tool/config/legacy_feature_folder_allowlist.txt);
the default `lib/features` scan suppresses those entries. New drift fails the gate.

```bash
bash tool/check_feature_folder_contract.sh
```

Strict mode (fixtures, pre-migration PRs, or `--paths` on new code):

```bash
bash tool/check_feature_folder_contract.sh --strict
```

New features and new cubits must pass without warnings. Touching legacy files
may keep local layout only until a deliberate migration PR moves cubits under
`presentation/cubit/`.

## Validation

| Step | Command |
| --- | --- |
| Preview layout | `bash tool/scaffold_feature_contract.sh --name <feature>` |
| Folder shape | `bash tool/check_feature_folder_contract.sh` |
| Import boundaries | `bash tool/check_clean_architecture_imports.sh` |
| Modularity | `bash tool/check_feature_modularity_leaks.sh` |
