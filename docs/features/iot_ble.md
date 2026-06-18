# IoT BLE feature

Interview-grade BLE showcase on `/iot-demo` (**BLE** tab): scan, connect, GATT read/write/notify, mock peripherals, optional real BLE on mobile.

**Cloud tab** (Supabase offline-first IoT demo) is unchanged — see [`offline_first/iot_demo.md`](../offline_first/iot_demo.md).

## Hub route

`/iot-demo` → `IotDemoHubPage` (`lib/app/router/pages/iot_demo_hub_page.dart`):

| Tab | Module | Notes |
| --- | --- | --- |
| Cloud | `lib/features/iot_demo/` | Supabase-backed device list when configured |
| BLE | `lib/features/iot/` | Local BLE showcase; cubit created lazily on BLE tab |

Modularity: `iot_demo` must not import `features/iot/` — composition stays in app router layer.

## Modes

| Mode | Platforms | Implementation |
| --- | --- | --- |
| Mock (default) | All | `MockBleRepository` + device catalog |
| Real | Android, iOS | `ReactiveBleRepository` + `flutter_reactive_ble` |
| Real (blocked) | Desktop, Web | `UnsupportedBleRepository`; mock toggle only |

Dart define: `IOT_BLE_MOCK_DEFAULT` — unset or `true` starts in mock on mobile (`IotBleRuntimeConfig`).

## Mock devices

| Name | Service | Notes |
| --- | --- | --- |
| ESP32 Sensor | `0xFFE0` | temp/humidity notify |
| Heart Rate Monitor | `0x180D` / `0x2A37` | BPM notify |
| Smart Thermometer | `0x1809` / `0x2A1C` | read/indicate |
| Smart Lock | `0xFF10` | PIN write → status notify (PIN `1234`) |

Classic Bluetooth section uses `MockClassicBluetoothRepository` (paired devices + messages UI only; no RFCOMM v1).

## Architecture (summary)

- **Domain:** `BleRepository`, `BleSessionCoordinator`, `BlePermissionGateway`, entities, `IotBleErrorCode`
- **Data:** `MockBleRepository`, `ReactiveBleRepository`, `BleRadioClient` (FRB seam), mappers
- **Presentation:** `IotBleCubit` (part files under `presentation/cubit/`), `IotBleSection` widgets
- **DI:** `lib/core/di/register_iot_services.dart` (from `register_demo_services.dart`)

Errors: `Result<T>` in repositories; `IotBleErrorCode` + l10n in UI.

## Permissions

See [iot_ble_permissions.md](iot_ble_permissions.md).

## Device testing (manual)

See [iot_ble_device_test_checklist.md](iot_ble_device_test_checklist.md).

## Tests

```bash
flutter test test/features/iot/ test/app/router/iot_demo_hub_page_test.dart
```

Integration (extended tier): `integration_test/iot_demo_ble_tab_flow_test.dart` via `registerIotDemoBleTabIntegrationFlow()`.

## Related docs

- Feature README: [`lib/features/iot/README.md`](../../lib/features/iot/README.md)
- Plan / change log: [`plans/iot_ble_feature_brief.md`](../plans/iot_ble_feature_brief.md), [`changes/2026-06-18_iot-ble-feature.md`](../changes/2026-06-18_iot-ble-feature.md)
