# IoT BLE device test checklist (manual)

Use when validating **real** mode on hardware. CI uses mock only.

## Prerequisites

- [ ] Physical device or nRF Connect peripheral
- [ ] Bluetooth on, app has permissions
- [ ] Real mode toggle enabled (mobile)

## Scan

- [ ] Start scan — devices appear with RSSI
- [ ] Stop scan — list stops updating
- [ ] Timeout auto-stops scan

## Connect

- [ ] Connect to peripheral
- [ ] Services discovered
- [ ] Disconnect cleans state
- [ ] Reconnect works

## GATT

- [ ] Read characteristic
- [ ] Write characteristic
- [ ] Subscribe — notifications update UI

## Regression

- [ ] Switch Cloud ↔ BLE tabs — no leaked scan (BLE cubit disposed)
- [ ] Mock ↔ Real toggle tears down session

## Sign-off

| Platform | Tester | Date | Pass |
| -------- | ------ | ---- | ---- |
| Android  |        |      |      |
| iOS      |        |      |      |
