# IoT BLE tab lifecycle fix (2026-06-20)

## Problem

Leaving `/iot-demo`'s BLE tab stopped BLE scanning and disconnected its GATT
session, but left the tab's mock Classic Bluetooth session connected.

## Change

- Await BLE notification and connection subscription cancellation during
  session teardown.
- Disconnect the Classic Bluetooth repository when `IotBleCubit` closes.
- Cover Cloud ↔ BLE switching with a widget regression test that observes scan
  stop and both session disconnects.

## Proof

```bash
flutter test test/app/router/iot_demo_hub_page_test.dart
bash tool/analyze.sh
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
```
