# IoT BLE feature

## Summary

Local BLE showcase tab on `/iot-demo`: mock GATT simulator (ESP32, HRM, thermometer, smart lock), optional real BLE on mobile via `flutter_reactive_ble`, Classic mock section. Hub keeps `iot_demo` free of `features/iot` imports.

## Files

- `lib/features/iot/**` — domain / data / presentation (part splits for file-length lint)
- `lib/app/router/pages/iot_demo_hub_page.dart` — Cloud | BLE tabs
- `lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart` — extracted cloud UI
- `lib/core/di/register_iot_services.dart`, `lib/core/config/iot_ble_runtime_config.dart`
- `pubspec.yaml` — `flutter_reactive_ble`, `permission_handler`
- Platform: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`
- `docs/features/iot_ble*.md`, [`plans/iot_ble_feature_brief.md`](../plans/iot_ble_feature_brief.md)
- Catalog/index: [`feature_overview.md`](../feature_overview.md), [`README.md`](../README.md), [`architecture/reference_features.md`](../architecture/reference_features.md)

## Tests

- Unit/widget: `test/features/iot/`, `test/app/router/iot_demo_hub_page_test.dart`
- Integration: `integration_test/iot_demo_ble_tab_flow_test.dart` (`registerIotDemoBleTabIntegrationFlow`, extended tier)

## Verification

```bash
flutter analyze
flutter test test/features/iot/ test/app/router/iot_demo_hub_page_test.dart
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
CHECKLIST_INTEGRATION_DEVICE=<ios-sim-udid> INTEGRATION_TESTS_RUN_COVERAGE=false \
  ./bin/integration_tests integration_test/iot_demo_flow_test.dart \
  integration_test/iot_demo_ble_tab_flow_test.dart
```
