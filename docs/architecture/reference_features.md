# Reference Features (Gold Layout)

Agents need in-repo examples that match
[`feature_structure_contract.md`](feature_structure_contract.md). Copy these
layouts — not legacy demos listed under [Legacy drift](#legacy-drift).

## Gold references

| Feature | Why copy it | Key paths |
| --- | --- | --- |
| `remote_config` | Full Clean Architecture stack, offline-first data, Freezed state, `presentation/cubit/` | `lib/features/remote_config/domain/`, `data/`, `presentation/cubit/`, `presentation/widgets/` |
| `case_study_demo` | Smaller feature with standard cubit folder + pages | `lib/features/case_study_demo/presentation/cubit/` |
| `iot_demo` | Cubit + domain/data split without extra legacy folders | `lib/features/iot_demo/presentation/cubit/` |
| `profile` | Straightforward cubit + page feature | `lib/features/profile/presentation/cubit/` |
| `todo_list` | Larger cubit split across part files — still under `presentation/cubit/` | `lib/features/todo_list/presentation/cubit/` |
| `native_platform_showcase` | Educational demo: use case + repository + **platform service ports** (MethodChannel / FFI behind data adapters); cubit depends on use case only | `lib/features/native_platform_showcase/domain/use_cases/`, `domain/native_showcase_*_service.dart`, `data/*_service.dart`, [`README.md`](../../lib/features/native_platform_showcase/README.md) |

Scaffold output (no runtime code) matches the same shape:
[`feature_brief_scaffold_example.md`](feature_brief_scaffold_example.md).

## Do not copy

| Feature / path | Reason |
| --- | --- |
| `counter` | Cubit at `presentation/` root; predates folder contract ([`CODEMAP.md`](../../CODEMAP.md)) |
| `settings/presentation/cubits/` | Legacy plural folder; new code uses `presentation/cubit/` only |
| `playlearn`, `graphql_demo`, `scapes`, `deeplink`, `chat` | Root-level cubit/state files (some also have `presentation/cubit/` — do not extend root pattern) |
| `staff_app_demo/presentation/<flow>/` | Flow subfolders with cubit at subfolder root — migrate to `presentation/cubit/` when touched |

## Legacy drift

Default scan warns but does not fail CI until legacy features migrate:

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
