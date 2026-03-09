-- Enforce app value range [0, 50] on public.iot_devices.value (thermostat/sensor etc.).
-- Matches lib/features/iot_demo/domain/iot_demo_value_range.dart (iotDemoValueMin/Max).
-- Idempotent: drop then add constraint.

ALTER TABLE public.iot_devices
  DROP CONSTRAINT IF EXISTS iot_devices_value_range;

ALTER TABLE public.iot_devices
  ADD CONSTRAINT iot_devices_value_range
  CHECK (value >= 0 AND value <= 50);
