#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

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

package_config=".dart_tool/package_config.json"
needs_pub_get=0
if [ ! -f "$package_config" ]; then
  needs_pub_get=1
elif [ "pubspec.yaml" -nt "$package_config" ] || [ "pubspec.lock" -nt "$package_config" ]; then
  needs_pub_get=1
fi

if [ "$needs_pub_get" -eq 1 ]; then
  echo "ide-preflight|flutter-pub-get|run"
  flutter pub get
else
  echo "ide-preflight|flutter-pub-get|skip|up-to-date"
fi

echo "ide-preflight|dart-defines|begin"
"$PROJECT_ROOT/tool/flutter_dart_defines_from_env.sh" |
  tr ' ' '\n' |
  sed -n 's/^--dart-define=\([^=]*\)=.*/ide-preflight|dart-define|\1/p'
echo "ide-preflight|dart-defines|end"

"$PROJECT_ROOT/tool/check_tracked_secret_literals.sh"

if [ "$(uname -s)" = "Darwin" ] && [ -f "ios/Podfile" ] && [ ! -d "ios/Pods" ]; then
  echo "ide-preflight|ios-pods|missing|run: cd ios && pod install"
fi

echo "ide-preflight|ok"
