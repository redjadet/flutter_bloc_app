# FCM shared contract extraction — 2026-08-05

## Summary

Moved shared pure-Dart FCM messaging contracts out of
`features/fcm_demo/domain/` into `package:utilities` so
`production_readiness` no longer imports another feature. **No FCM, DI,
routing, Firebase, or UI behavior change.**

## Public contract (now on `package:utilities/utilities.dart`)

- `FcmDemoMode`
- `FcmPermissionState`
- `FcmMessagingService`
- `FcmSimulationController`
- `PushMessage` / `PushMessageSource`

`fcm_demo` keeps data adapters and presentation only. Feature barrel no longer
re-exports the moved contracts.

## Tests

- `packages/utilities/test/fcm/push_message_test.dart` — equality, `copyWith`,
  default source via public barrel
- Existing `fcm_demo` + `production_readiness` + `register_fcm_demo_services`
  suites (imports only)

## Validation

```bash
cd packages/utilities && dart test
cd apps/mobile && flutter test \
  test/app/composition/register_fcm_demo_services_test.dart \
  test/features/fcm_demo/data \
  test/features/fcm_demo/presentation \
  test/features/production_readiness/presentation
./tool/analyze.sh
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_folder_contract.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/check_package_dependency_dag.sh
bash tool/modular_metrics.sh --cross-feature-only   # 0 from_feature rows
./bin/router_feature_validate
```

## Explicit non-goals

- QG-D04 / QG-D03 / MQ-B2 / coverage / MQ-N01–N02 unchanged
- No `apps/mobile/lib/shared/**`
- No compatibility re-exports under `fcm_demo/domain/`
