-- Migration: Add user_id to iot_devices and enforce RLS (per-user data).
-- Apply via: supabase/README.md (CLI: npx supabase db push | or Dashboard SQL editor).
-- Prerequisite: public.iot_devices table exists.
--
-- First-time only: if the table has existing shared rows, uncomment and run
-- once: DELETE FROM public.iot_devices;
-- Then run the rest. Re-running this migration is safe (IF NOT EXISTS / DROP IF EXISTS).

-- Add user_id column (nullable first so existing rows are allowed).
ALTER TABLE public.iot_devices
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id);

-- After backfilling or deleting old rows, enforce NOT NULL (run once):
-- DELETE FROM public.iot_devices WHERE user_id IS NULL;
-- ALTER TABLE public.iot_devices ALTER COLUMN user_id SET NOT NULL;

-- Index for per-user queries.
CREATE INDEX IF NOT EXISTS iot_devices_user_id_idx ON public.iot_devices(user_id);

-- RLS: each user sees and modifies only their own rows.
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

-- connection_state as enum: disconnected | connecting | connected.
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
-- Drop default before type change (required if column has default).
ALTER TABLE public.iot_devices ALTER COLUMN connection_state DROP DEFAULT;
-- Use the enum for the column. Converts from text or boolean-like values.
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

-- Realtime: so app reflects DB changes from other devices/dashboard (two-way sync).
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
