# Offline-first documentation

Local-first storage, synchronization, conflicts, and remote-data recovery.
Start with [adoption_guide.md](adoption_guide.md). The accepted cross-feature
decision is [ADR 0002](../adr/0002-offline-first-data.md).

| Need | Read |
| --- | --- |
| Adopt or review a feature | [adoption_guide.md](adoption_guide.md) |
| Preserve newer local state | [dont_overwrite_guide.md](dont_overwrite_guide.md) |
| Hive schema changes | [hive_schema_migrations.md](hive_schema_migrations.md) |
| Supabase migrations | [supabase_migrations.md](supabase_migrations.md) |
| Feature examples | [counter.md](counter.md), [chat.md](chat.md), [profile.md](profile.md) |
| Historical audit evidence | [ANALYSIS_AND_IMPROVEMENTS.md](ANALYSIS_AND_IMPROVEMENTS.md) |

Daily invariants come from the adoption and don't-overwrite guides. Feature
docs may choose cache-first, online-first, or feature-specific status surfaces,
but must not weaken newer-local protection, remote-read failure handling, or
data-layer ownership.
