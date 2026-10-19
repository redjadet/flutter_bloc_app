# Repair `tool/bloc_codegen` for analyzer 14 + package annotations

## Why

MCP/CLI analysis (P1) showed `tool/bloc_codegen` broken: a deep relative import
pointed at `/workspace/lib/...` instead of app annotations, and the generator
stack lagged the workspace `analyzer: 14.5.0` APIs.

## What landed

- New workspace package `packages/bloc_annotations` owns the annotation types.
- `tool/bloc_codegen` joins the Melos workspace, depends on that package, and
  upgrades to `analyzer` 14 / `source_gen` 4 / `build` 4.
- Generators updated: `library.classes`, `formalParameters`,
  `ConstantReader` for transition fields, nullable `Element.name`.
- Added missing `builder.dart` + `build.yaml` builder registrations.
- App `bloc_annotations.dart` re-exports the package; workspace analyze/test
  scripts include `tool/bloc_codegen`.
- List `bloc_annotations` in `tool/check_package_dependency_dag.sh` ALLOWED map
  (leaf package, no path deps).

## Verification

- `cd tool/bloc_codegen && dart analyze lib test` — No issues found
- `cd packages/bloc_annotations && dart analyze lib test` — No issues found
- `cd tool/bloc_codegen && dart test` — pass
- `cd packages/bloc_annotations && dart test` — pass
- `bash tool/check_package_dependency_dag.sh` — package-dag|pass
