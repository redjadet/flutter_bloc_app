#!/usr/bin/env bash
# Resolve workspace + app dependencies and run Flutter codegen (l10n, flutter_gen).
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workspace_paths.sh"

if [[ "$APP_ROOT" != "$WORKSPACE_ROOT" ]]; then
  echo "workspace_pub_get|melos|dart pub get at workspace root"
  (cd "$WORKSPACE_ROOT" && dart pub get)
  echo "workspace_pub_get|melos|flutter pub get at APP_ROOT=$APP_ROOT"
  (cd "$APP_ROOT" && flutter pub get)
else
  echo "workspace_pub_get|single-package|flutter pub get at $APP_ROOT"
  (cd "$APP_ROOT" && flutter pub get)
fi
