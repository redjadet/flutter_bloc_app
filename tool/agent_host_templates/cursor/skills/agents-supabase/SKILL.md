---
name: agents-supabase
description: Supabase MCP + migrations for this repo. Use for schema, RLS, apply_migration/list_migrations.
---

# Supabase

**MCP:** **`user-supabase`** (project ref in `~/.cursor/mcp.json`) for SQL/migrations/advisors. **`plugin-supabase-supabase`** only for org discovery (`list_projects`, etc.).

**RLS / safety:** skill `ai-safe-supabase-workflow`.

## Migration flow

1. Add `supabase/migrations/YYYYMMDDHHMMSS_name.sql` — idempotent SQL (`IF NOT EXISTS`, etc.)
2. Log in `docs/offline_first/supabase_migrations.md` (file, MCP snake_case name, purpose)
3. `list_migrations` if unsure applied; `apply_migration` on `user-supabase` with `name` + full `query`
4. CLI/dashboard alt: `supabase/README.md`

**SQL tips:** drop default before type change, re-add after; boolean text via `LOWER(TRIM(...)) IN ('true','t','1')` not `IS TRUE`.
