-- Performance: index for get_iot_devices(p_toggled_on_only=true) and filtered selects.
-- RLS filters by user_id; when filtering by toggled_on, this composite index helps.

CREATE INDEX IF NOT EXISTS iot_devices_user_id_toggled_on_idx
  ON public.iot_devices (user_id, toggled_on)
  WHERE toggled_on = true;

COMMENT ON INDEX public.iot_devices_user_id_toggled_on_idx IS
  'Supports On-only filtered queries such as get_iot_devices(toggled_on_only=true).';
