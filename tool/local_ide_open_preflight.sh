#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$WORKSPACE_ROOT/tool/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

echo "ide-preflight|start"

if command -v direnv >/dev/null 2>&1 && [ -f ".envrc" ]; then
  if direnv_export="$(direnv export bash 2>/dev/null)"; then
    # Load allowed env into this task process. Do not print values.
    eval "$direnv_export"
    echo "ide-preflight|direnv|loaded"
  else
    echo "ide-preflight|direnv|not-allowed|run: direnv allow"
  fi
else
  echo "ide-preflight|direnv|missing-or-no-envrc"
fi

package_config="$WORKSPACE_ROOT/.dart_tool/package_config.json"
needs_pub_get=0
if [ ! -f "$package_config" ]; then
  needs_pub_get=1
elif [ "$APP_ROOT/pubspec.yaml" -nt "$package_config" ] || [ "$WORKSPACE_ROOT/pubspec.lock" -nt "$package_config" ]; then
  needs_pub_get=1
fi

if [ "$needs_pub_get" -eq 1 ]; then
  echo "ide-preflight|dart-pub-get|run"
  (cd "$WORKSPACE_ROOT" && dart pub get)
else
  echo "ide-preflight|dart-pub-get|skip|up-to-date"
fi

echo "ide-preflight|dart-defines|begin"
"$WORKSPACE_ROOT/tool/flutter_dart_defines_from_env.sh" |
  tr ' ' '\n' |
  sed -n 's/^--dart-define=\([^=]*\)=.*/ide-preflight|dart-define|\1/p'
echo "ide-preflight|dart-defines|end"

"$WORKSPACE_ROOT/tool/check_tracked_secret_literals.sh"

if [ "$(uname -s)" = "Darwin" ] && [ -f "$APP_ROOT/ios/Podfile" ] && [ ! -d "$APP_ROOT/ios/Pods" ]; then
  echo "ide-preflight|ios-pods|missing|run: cd apps/mobile/ios && pod install"
fi

echo "ide-preflight|ok"
