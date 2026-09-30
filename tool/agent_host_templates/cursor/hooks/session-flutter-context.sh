#!/usr/bin/env bash
# sessionStart: inject a short Flutter cross-platform reminder (fail-open).
set -euo pipefail

# Consume stdin (session payload) so the pipe does not block
cat >/dev/null || true

cat <<'EOF'
{
  "additional_context": "Flutter cross-platform session: prefer repo AGENTS.md + docs over vendor skills. Keep Dart MCP connected for analyze/hot_reload/get_runtime_errors. After .dart edits use ./bin/format before finish. Targets: iOS/Android, tablet, web, macOS desktop — avoid dart:io in presentation."
}
EOF
exit 0
