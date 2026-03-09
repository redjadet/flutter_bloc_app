-- Security: remove permissive anon SELECT that allowed reading all rows.
-- Performance: use (select auth.uid()) in RLS so it is evaluated once per query.
-- See: https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select

DROP POLICY IF EXISTS "Allow anon read iot_devices" ON public.iot_devices;

DROP POLICY IF EXISTS "iot_devices_select_own" ON public.iot_devices;
CREATE POLICY "iot_devices_select_own" ON public.iot_devices
  FOR SELECT USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "iot_devices_insert_own" ON public.iot_devices;
CREATE POLICY "iot_devices_insert_own" ON public.iot_devices
  FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "iot_devices_update_own" ON public.iot_devices;
CREATE POLICY "iot_devices_update_own" ON public.iot_devices
  FOR UPDATE USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "iot_devices_delete_own" ON public.iot_devices;
CREATE POLICY "iot_devices_delete_own" ON public.iot_devices
  FOR DELETE USING (user_id = (SELECT auth.uid()));
