# Supabase migrations log

All Supabase schema changes are documented here. Apply migrations via MCP
(`user-supabase` → `apply_migration`) when adding or changing schema.

## Migrations in this repo

| File | MCP name (when applied) | Purpose | Prerequisites |
| ------ | -------------------------- | --------- | --------------- |
| `supabase/migrations/20260309100000_iot_demo_user_id_rls_connection_enum.sql` | `iot_demo_connection_state_enum_and_realtime` | Add `user_id` (FK to `auth.users`), index, RLS policies, enum `public.iot_connection_state` for `connection_state`, add `iot_devices` to `supabase_realtime`. | Table `public.iot_devices` must exist. If column has default, migration includes DROP DEFAULT before type change and SET DEFAULT after. |
| `supabase/migrations/20260309160000_iot_demo_value_range_check.sql` | `iot_demo_value_range_check` | CHECK constraint on `value`: must be between 0 and 50 (matches app `iotDemoValueMin` / `iotDemoValueMax` for thermostat/sensor). | Table `public.iot_devices` with column `value` (double precision). |
| `supabase/migrations/20260309170000_iot_devices_rls_fixes.sql` | `iot_devices_rls_fixes` | Drop permissive anon SELECT policy "Allow anon read iot_devices"; recreate own policies using `(SELECT auth.uid())` for better RLS performance. | RLS policies on `public.iot_devices` from earlier migrations. |
| `supabase/migrations/20260309180000_iot_devices_get_function.sql` | `iot_devices_get_function` | Add `get_iot_devices(p_toggled_on_only boolean)` RPC for optional On-only server-side filtering. RLS applies. App uses PostgREST `.select().eq('toggled_on', true or false)` for All / On only / Off only, not this RPC. | Table `public.iot_devices` with column `toggled_on`. |
| `supabase/migrations/20260309200000_iot_devices_toggled_on_index.sql` | `iot_devices_toggled_on_index` | Partial index on `(user_id, toggled_on)` WHERE `toggled_on = true` for On-only queries. | Table `public.iot_devices`. |
| `supabase/migrations/20260309210000_iot_devices_user_id_toggled_on_full_index.sql` | `iot_devices_user_id_toggled_on_full_index` | Composite index on `(user_id, toggled_on)` for All/On-only/Off-only filtered list queries used by the app. | Table `public.iot_devices`. |
| `supabase/migrations/20260310120000_graphql_countries_tables.sql` | `graphql_countries_tables` | Add `public.graphql_continents` / `public.graphql_countries` for the GraphQL demo. Synced from `countries.trevorblades.com` via Edge Function `sync-graphql-countries` (source: `supabase/functions/sync-graphql-countries/`, deployed with `verify_jwt: false`). App calls Edge first when signed in, then table fallback; see [GraphQL demo](graphql_demo.md). | None. |

- Doc copy (first migration): `docs/offline_first/supabase_iot_demo_user_id_migration.sql`.
- Idempotent: safe to re-run (IF NOT EXISTS, DROP IF EXISTS, conditional publication add).

## Remote-only migrations (applied via Dashboard/CLI or MCP earlier)

These may appear in `list_migrations` on the linked project; they are not
versioned in this repo as separate files.

| Version (example) | Name | Purpose |
| ----------------- | ---- | ------- |
| 20260309142227 | create_iot_devices | Create table `public.iot_devices`. |
| 20260309142255 | iot_devices_rls_policies | RLS policies for `iot_devices`. |
| 20260309153933 | add_iot_devices_user_id_rls | Add `user_id` and RLS. |
| 20260309154253 | iot_devices_user_id_not_null | Set `user_id` NOT NULL. |
| 20260309155324 | drop_permissive_iot_devices_anon_policies | Drop permissive anon policies. |
| (applied via MCP) | iot_demo_connection_state_enum_and_realtime | Same as repo migration above (enum + realtime). |
| (applied via MCP) | iot_demo_value_range_check | CHECK value in [0, 50]. |
| (applied via MCP) | iot_devices_rls_fixes | Drop anon read policy; optimize RLS with (SELECT auth.uid()). |
| (applied via MCP) | iot_devices_user_id_toggled_on_full_index | Composite index (user_id, toggled_on) for filtered list queries. |

When adding a new migration: add a row to "Migrations in this repo" and, if
applied via MCP with a distinct name, add that name to the table so agents
can avoid duplicate application.
