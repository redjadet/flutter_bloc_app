-- Migration: Add get_iot_devices RPC for server-side filtering by toggled_on.
-- Prerequisite: public.iot_devices with toggled_on column.
-- Safe to re-run (CREATE OR REPLACE).

CREATE OR REPLACE FUNCTION public.get_iot_devices(p_toggled_on_only boolean DEFAULT false)
RETURNS SETOF public.iot_devices
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT * FROM public.iot_devices
  WHERE (NOT p_toggled_on_only OR toggled_on = true)
  ORDER BY id;
$$;

COMMENT ON FUNCTION public.get_iot_devices(boolean) IS
  'Returns IoT devices for the current user. When p_toggled_on_only is true, returns only devices with toggled_on = true. False returns all devices. RLS applies.';

GRANT EXECUTE ON FUNCTION public.get_iot_devices(boolean) TO anon;
GRANT EXECUTE ON FUNCTION public.get_iot_devices(boolean) TO authenticated;
