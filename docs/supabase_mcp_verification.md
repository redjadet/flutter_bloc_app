# Supabase MCP Verification Report

**Date:** 2026-03-10
**Project:** flutter_bloc_app

## Plugin MCP Server (plugin-supabase-supabase)

The **Supabase Cursor plugin** provides an MCP server with identifier `plugin-supabase-supabase` (display name: **supabase**).

| Item | Detail |
| ------ | -------- |
| **Source** | Cursor plugin: `cursor-public/supabase` (v0.1.3) |
| **Plugin config** | `.cursor/settings.json` → `"supabase": { "enabled": true }` |
| **MCP definition** | `~/.cursor/plugins/cache/cursor-public/supabase/release_v0.1.3/mcp.json` |
| **Endpoint** | `https://mcp.supabase.com/mcp` (HTTP; project context via params or auth) |
| **Tools** | 30 tools (same DB/edge/branch tools as user-supabase **plus** org/project management) |

### Plugin-only tools (vs user-supabase)

- `list_projects` — lists all Supabase projects for the user
- `get_project` — project details (requires `id`)
- `list_organizations`, `get_organization`
- `confirm_cost`, `get_cost` — for branching cost confirmation
- `create_project`, `pause_project`, `restore_project`

### Plugin MCP status

- **Working:** `list_projects`, `get_project` (with `id: "gtkoawccyzppgdsyjsjd"`).
- **Same as user-supabase:** DB/docs/edge/advisors/logs tools work; `list_branches` fails with same error when called with `project_id` (branching not enabled).

### User MCP config (project-scoped)

In `~/.cursor/mcp.json` the entry **"supabase"** is configured with a fixed project ref:

- **Server identifier:** `user-supabase` (when resolved in this project)
- **URL:** `https://mcp.supabase.com/mcp?project_ref=gtkoawccyzppgdsyjsjd`
- **Tools:** 20 (no `list_projects` / `get_project`; project is implicit from URL)

So you have two ways to talk to Supabase MCP: **plugin** (more tools, pass `project_id` where needed) and **user** (project baked in, fewer tools).

---

## user-supabase (project-scoped) tool summary

| Status | Count |
| -------- | ------- |
| Working | 14 |
| Failing | 1 (branch-related) |
| Not tested (modifies state) | 5 |

## Working Tools

| Tool | Description |
| ------ | ------------- |
| `list_tables` | Lists tables; tested with `schemas: ['public']`, `verbose: true/false` |
| `list_migrations` | Lists all applied migrations (11 found) |
| `list_extensions` | Lists Postgres extensions (available + installed) |
| `get_project_url` | Returns project API URL |
| `get_publishable_keys` | Returns anon + publishable keys |
| `execute_sql` | Executes raw SQL (e.g. `SELECT 1`) |
| `get_advisors` | Security and performance advisors (type: `security` \| `performance`) |
| `get_logs` | Fetches logs by service (api, postgres, auth, etc.) |
| `search_docs` | GraphQL search of Supabase documentation |
| `list_edge_functions` | Lists Edge Functions (e.g. hello-world, sync-graphql-countries) |
| `get_edge_function` | Retrieves Edge Function source by slug (`function_slug`) |
| `deploy_edge_function` | Deploys an Edge Function (used for sync-graphql-countries with `verify_jwt: false`) |
| `generate_typescript_types` | Generates TypeScript types for the schema |

## Failing Tools

| Tool | Error |
| ------ | ----- |
| `list_branches` | `InternalServerErrorException: Project reference is missing when validating permissions` |

**Likely cause:** Supabase branching may not be enabled for this project, or the MCP project reference is not configured for branched workflows.

## Tested (Modifies State)

| Tool | Result |
| ------ | -------- |
| `deploy_edge_function` | Used to redeploy `sync-graphql-countries` with `verify_jwt: false`; params: `name`, `files`, `verify_jwt`. |

## Not Tested (Would Modify State)

| Tool | Reason |
| ------ | -------- |
| `apply_migration` | DDL; would add migration record. Same backend as `execute_sql`, expected to work. |
| `create_branch` | Requires `confirm_cost_id`; branching appears unavailable. |
| `delete_branch` | Branching not available. |
| `merge_branch` | Branching not available. |
| `rebase_branch` | Branching not available. |
| `reset_branch` | Branching not available. |

## Recommendations

1. **Branch tools:** Enable [Supabase branching](https://supabase.com/docs/guides/platform/branching) if you need branch workflows via MCP.
2. **Advisors:** Current security advisor suggests enabling leaked password protection (Dashboard → Authentication → Providers → Email).
3. **Performance advisors:** Unused indexes on `iot_devices`; safe to ignore at low row counts or remove later.
