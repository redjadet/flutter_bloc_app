-- General composite index for filtered list queries: All / On only / Off only.
-- App uses PostgREST: .select().eq('toggled_on', true|false).order('id') with RLS on user_id.
-- This index supports both On-only and Off-only filtered queries; the existing partial
-- index (WHERE toggled_on = true) remains for smaller On-only index size when applicable.

CREATE INDEX IF NOT EXISTS iot_devices_user_id_toggled_on_full_idx
  ON public.iot_devices (user_id, toggled_on);

COMMENT ON INDEX public.iot_devices_user_id_toggled_on_full_idx IS
  'Supports All/On-only/Off-only filtered device list queries by user_id and toggled_on.';
