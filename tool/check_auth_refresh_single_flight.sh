#!/usr/bin/env bash
# Check for auth-refresh retry anti-patterns that can reintroduce 401 races.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking auth refresh flow for single-flight safety..."

CLIENT_FILE="lib/shared/http/resilient_http_client.dart"
MANAGER_FILE="lib/shared/http/auth_token_manager.dart"

# Anti-pattern: refreshToken() followed by forceRefresh: true in same flow.
DOUBLE_REFRESH_PATTERN='(?s)refreshToken\(\).*?forceRefresh:\s*true'
if rg -nP "$DOUBLE_REFRESH_PATTERN" "$CLIENT_FILE" >/dev/null 2>&1; then
  echo "❌ Found potential double-refresh anti-pattern in $CLIENT_FILE"
  rg -nP "$DOUBLE_REFRESH_PATTERN" "$CLIENT_FILE" || true
  echo "   Use refreshToken() + regular token injection on retry (no forceRefresh)."
  exit 1
fi

# Guard: serialized refresh gate should remain in AuthTokenManager.
if ! rg -n "_refreshCompleter" "$MANAGER_FILE" >/dev/null 2>&1; then
  echo "❌ Missing serialized refresh gate (_refreshCompleter) in $MANAGER_FILE"
  exit 1
fi

echo "✅ Auth refresh single-flight checks passed"
exit 0
