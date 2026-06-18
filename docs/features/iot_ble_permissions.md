# IoT BLE permissions

## Android

`AndroidManifest.xml` includes:

- `BLUETOOTH_SCAN` (neverForLocation when applicable)
- `BLUETOOTH_CONNECT`
- Legacy `BLUETOOTH` / `BLUETOOTH_ADMIN` for API &lt; 31

Runtime: `flutter_reactive_ble` `statusStream` reports `BleStatus.unauthorized`. The app escalates via `BlePermissionGateway` (`permission_handler`: Bluetooth on iOS; Bluetooth scan/connect + location on Android 12+). Implemented in `ReactiveBleRepository.ensureReady()`.

## iOS

`Info.plist`:

- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription` (legacy)

## Desktop / Web

Real BLE disabled; mock forced.
