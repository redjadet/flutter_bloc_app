---
name: hot-reload
description: Trigger Flutter hot reload via Dart MCP (DTD). Usage /hot-reload
---

# hot-reload

If a Flutter app is running for this repo, do:

- `dtd` → `listDtdUris`
- `dtd` → `connect` (choose repo DTD)
- `dtd` → `listConnectedApps`
- `hot_reload` (use `appUri` if multiple apps)

If no app running, say so and stop (don’t fake).
