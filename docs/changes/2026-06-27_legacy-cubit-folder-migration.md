# Legacy cubit folder migration

**Date:** 2026-06-27

## Summary

- Moved presentation cubit/state files for chat, graphql_demo, playlearn, scapes,
  settings, and staff_app_demo under `presentation/cubit/`.
- Cleared `tool/config/legacy_feature_folder_allowlist.txt`; new folder-contract
  drift fails the gate instead of warning.
- Updated barrels, routes, tests, and docs (`docs/engineering/anchors.md`,
  `docs/architecture/reference_features.md`).

## Verification

```bash
bash tool/check_feature_folder_contract.sh
flutter analyze --no-pub
flutter test test/features/chat test/features/graphql_demo test/features/playlearn test/features/scapes test/features/settings test/features/staff_app_demo
```
