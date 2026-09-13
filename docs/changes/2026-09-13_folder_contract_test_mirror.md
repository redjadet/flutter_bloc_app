# Folder contract test mirroring + audit refresh

Lib cubits for chat/scapes/settings already under `presentation/cubit/`
(2026-06-27). This slice mirrors tests and refreshes the stale June audit.

## What landed

- Move `chat_list_cubit_test`, `scapes_cubit_test`, `app_info_cubit_test` under
  `test/features/*/presentation/cubit/`
- Refresh [`architecture_review_2026-06.md`](../audits/architecture_review_2026-06.md) §7

## Verification

```bash
bash tool/check_feature_folder_contract.sh
```
