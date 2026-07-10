# IoT BLE showcase

Local **BLE** tab on `/iot-demo` (Cloud | BLE). Mock simulator works on every
supported platform; real BLE uses `flutter_reactive_ble` on Android and iOS.

## Structure

- `domain/` — `BleRepository`, `BleSessionCoordinator`, `BlePermissionGateway`, entities, `IotBleFailureMapper`
- `data/` — `MockBleRepository`, `ReactiveBleRepository`, `BleRadioClient`, `UnsupportedBleRepository`, permission gateway
- `presentation/` — `IotBleCubit` (+ `.part.dart` splits), `IotBleSection` widgets

Large files use `part` splits (`mock_ble_repository_*`, `reactive_ble_repository_*`, `iot_ble_cubit_*`) for the 225-line lint cap.

## Composition

`lib/app/router/pages/iot_demo_hub_page.dart` — lazy `IotBleCubit` on BLE tab. No `iot_demo` → `iot` imports.

## DI

`registerIotServices()` lives in
`lib/app/composition/features/register_iot_services.dart` and is called from
`lib/app/composition/groups/register_demo_services.dart`.

## Dart define

- `IOT_BLE_MOCK_DEFAULT=true` (default) — start in mock mode on mobile (`IotBleRuntimeConfig`)

## Docs

- [`docs/features/iot_ble.md`](../../../../../docs/features/iot_ble.md)
- Permissions: [`docs/features/iot_ble_permissions.md`](../../../../../docs/features/iot_ble_permissions.md)
- Manual device QA: [`docs/features/iot_ble_device_test_checklist.md`](../../../../../docs/features/iot_ble_device_test_checklist.md)
