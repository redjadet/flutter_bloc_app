-- Migration: Add user_id to iot_devices, RLS, connection_state enum, realtime.
-- Prerequisite: public.iot_devices table exists.
-- Safe to re-run (IF NOT EXISTS / DROP IF EXISTS). If iot_devices is already
-- in supabase_realtime, the last statement will error; safe to ignore.

ALTER TABLE public.iot_devices
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id);

CREATE INDEX IF NOT EXISTS iot_devices_user_id_idx ON public.iot_devices(user_id);

ALTER TABLE public.iot_devices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "iot_devices_select_own" ON public.iot_devices;
CREATE POLICY "iot_devices_select_own" ON public.iot_devices
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "iot_devices_insert_own" ON public.iot_devices;
CREATE POLICY "iot_devices_insert_own" ON public.iot_devices
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "iot_devices_update_own" ON public.iot_devices;
CREATE POLICY "iot_devices_update_own" ON public.iot_devices
  FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "iot_devices_delete_own" ON public.iot_devices;
CREATE POLICY "iot_devices_delete_own" ON public.iot_devices
  FOR DELETE USING (user_id = auth.uid());

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'iot_connection_state') THEN
    CREATE TYPE public.iot_connection_state AS ENUM (
      'disconnected',
      'connecting',
      'connected'
    );
  END IF;
END
$$;

ALTER TABLE public.iot_devices ALTER COLUMN connection_state DROP DEFAULT;

ALTER TABLE public.iot_devices
  ALTER COLUMN connection_state TYPE public.iot_connection_state
  USING (
    CASE
      WHEN TRIM(connection_state::text) IN ('connected', 'connecting', 'disconnected')
        THEN TRIM(connection_state::text)::public.iot_connection_state
      WHEN LOWER(TRIM(connection_state::text)) IN ('true', 't', '1')
        THEN 'connected'::public.iot_connection_state
      ELSE 'disconnected'::public.iot_connection_state
    END
  );

ALTER TABLE public.iot_devices ALTER COLUMN connection_state SET DEFAULT 'disconnected'::public.iot_connection_state;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'iot_devices'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.iot_devices;
  END IF;
END
$$;
