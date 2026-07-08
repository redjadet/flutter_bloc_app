#!/usr/bin/env bash
# Check for auth-refresh retry anti-patterns that can reintroduce 401 races.

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$APP_ROOT"

echo "🔍 Checking auth refresh flow for single-flight safety..."

CLIENT_FILE="lib/app/http/app_dio.dart"
MANAGER_FILE="lib/app/http/auth/auth_token_manager.dart"

if [ ! -f "$MANAGER_FILE" ]; then
  echo "❌ Missing auth token manager at $MANAGER_FILE"
  exit 1
fi

# Anti-pattern: refreshToken() followed by forceRefresh: true in same flow.
DOUBLE_REFRESH_PATTERN='(?s)refreshToken\(\).*?forceRefresh:\s*true'
if [ -f "$CLIENT_FILE" ]; then
  if command -v rg &>/dev/null; then
    if rg -nP "$DOUBLE_REFRESH_PATTERN" "$CLIENT_FILE" >/dev/null 2>&1; then
      echo "❌ Found potential double-refresh anti-pattern in $CLIENT_FILE"
      rg -nP "$DOUBLE_REFRESH_PATTERN" "$CLIENT_FILE" || true
      echo "   Use refreshToken() + regular token injection on retry (no forceRefresh)."
      exit 1
    fi
  elif command -v perl &>/dev/null; then
    if perl -0777 -e '$_=<>; exit(/refreshToken\(\).*?forceRefresh:\s*true/s ? 0 : 1)' \
      "$CLIENT_FILE" 2>/dev/null; then
      echo "❌ Found potential double-refresh anti-pattern in $CLIENT_FILE"
      perl -0777 -e '$_=<>; print if /refreshToken\(\).*?forceRefresh:\s*true/s' "$CLIENT_FILE" || true
      echo "   Use refreshToken() + regular token injection on retry (no forceRefresh)."
      exit 1
    fi
  else
    echo "⚠️  Skipping double-refresh pattern check (install ripgrep or perl)"
  fi
fi

# Guard: serialized refresh gate should remain in AuthTokenManager.
if command -v rg &>/dev/null; then
  if ! rg -n "_refreshCompleter" "$MANAGER_FILE" >/dev/null 2>&1; then
    echo "❌ Missing serialized refresh gate (_refreshCompleter) in $MANAGER_FILE"
    exit 1
  fi
elif ! grep -q "_refreshCompleter" "$MANAGER_FILE" 2>/dev/null; then
  echo "❌ Missing serialized refresh gate (_refreshCompleter) in $MANAGER_FILE"
  exit 1
fi

echo "✅ Auth refresh single-flight checks passed"
exit 0
