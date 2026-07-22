---
name: agents-shared-patterns
description: Request-id, in-flight coalesce, stream emit safety, offline don't-overwrite. Use for async repos/cubits and remote→local merge.
---

# Shared async / offline-first patterns

**Canon:** [`docs/offline_first/dont_overwrite_guide.md`](../../../../../docs/offline_first/dont_overwrite_guide.md), [`docs/engineering/REPOSITORY_LIFECYCLE.md`](../../../../../docs/engineering/REPOSITORY_LIFECYCLE.md). **Public utils:** `ilkersevim_async_utils` (request-id, in-flight coalesce); `ilkersevim_async_lifecycle` (stream emit safety). **Private:** `packages/utilities` for app-coupled helpers. **Check:** `tool/check_offline_first_remote_merge.sh`.
