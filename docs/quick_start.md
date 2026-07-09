# Quick start

Minimal path to run and validate this repo. Full onboarding:
[new_developer_guide.md](new_developer_guide.md). Agent map:
[../AGENTS.md](../AGENTS.md).

## Toolchain

Pinned versions: [tech_stack.md](tech_stack.md) (Flutter 3.44.5 / Dart 3.12.2).

## Bootstrap

```bash
bash tool/workspace_pub_get.sh
dart run melos bootstrap
cd apps/mobile && flutter run -t lib/main_dev.dart
```

If `.envrc` has prepended `tool/direnv/bin` to `PATH`, plain `flutter run`
from the repo root is routed to `apps/mobile`.

Melos is repo-pinned in the root `pubspec.yaml`; use `dart run melos ...`
after bootstrap. A global `melos` binary is not required.

Agent host sync (optional, once per machine): [agent_environment_setup.md](agent_environment_setup.md).

## Reviewer path

For a quick technical read before cloning deeply:

- [../README.md](../README.md) — public entrypoint, live app links, and proof map.
- [interview_showcase.md](interview_showcase.md) — curated portfolio walk.
- [system_design_showcase.md](system_design_showcase.md) — architecture,
  operations, security, and production-readiness boundaries.
- [modularity.md](modularity.md) — dependency boundaries and enforcement.

## Fast validation

| Situation | Command |
| --- | --- |
| Narrow change / pre-commit | `./bin/checklist-fast` |
| Architecture import guards | `bash tool/check_clean_architecture_imports.sh` |
| Feature modularity | `bash tool/check_feature_modularity_leaks.sh` |
| Folder contract (legacy allowlisted on full scan) | `bash tool/check_feature_folder_contract.sh` |
| Analyze changed Dart | `./tool/analyze.sh` |
| Feature cubit tests | `cd apps/mobile && flutter test test/features/<feature>` |

Full gate before ship: `./bin/checklist` — routing in [engineering/validation_routing_fast_vs_full.md](engineering/validation_routing_fast_vs_full.md).

## Feature delivery pointers

- Folder shape: [architecture/feature_structure_contract.md](architecture/feature_structure_contract.md)
- Cubit/BLoC: [bloc_standards.md](bloc_standards.md), [review/bloc_checklist.md](review/bloc_checklist.md)
- Testing matrix: [testing/matrix_required_by_change.md](testing/matrix_required_by_change.md)
- Commands index: [agents_quick_reference.md](agents_quick_reference.md)
