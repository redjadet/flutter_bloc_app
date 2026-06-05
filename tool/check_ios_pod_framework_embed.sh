#!/usr/bin/env bash
# Validate that iOS simulator CocoaPods frameworks are embedded in Runner.app.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_INPUT_LIST="$PROJECT_ROOT/ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-input-files.xcfilelist"

usage() {
  cat <<'EOF'
Usage: tool/check_ios_pod_framework_embed.sh [options]

Checks that the built iOS simulator Runner.app embeds every CocoaPods framework
listed by Pods-Runner-frameworks-Debug-input-files.xcfilelist and every
@rpath/*.framework dependency referenced by Runner.debug.dylib.

Options:
  --require-built-app       Fail when no built simulator Runner.app exists.
  --app-path <path>         Override Runner.app path.
  --input-list <path>       Override CocoaPods framework input xcfilelist.
  --self-test               Run fixture tests for this script.
  -h, --help                Show help.
EOF
}

require_built_app=0
app_path=""
input_list="$DEFAULT_INPUT_LIST"
self_test=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --require-built-app)
      require_built_app=1
      shift
      ;;
    --app-path)
      app_path="${2:-}"
      if [ -z "$app_path" ]; then
        echo "usage-error|--app-path requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --input-list)
      input_list="${2:-}"
      if [ -z "$input_list" ]; then
        echo "usage-error|--input-list requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --self-test)
      self_test=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

resolve_default_app_path() {
  local candidate
  for candidate in \
    "$PROJECT_ROOT/build/ios/iphonesimulator/Runner.app" \
    "$PROJECT_ROOT/build/ios/Debug-iphonesimulator/Runner.app"; do
    if [ -d "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  printf '%s\n' "$PROJECT_ROOT/build/ios/iphonesimulator/Runner.app"
}

framework_names_from_input_list() {
  local list_path="$1"
  local input
  local framework_name

  while IFS= read -r input || [ -n "$input" ]; do
    case "$input" in
      *.framework)
        framework_name="${input##*/}"
        printf '%s\n' "$framework_name"
        ;;
    esac
  done < "$list_path"
}

framework_names_from_dylib() {
  local dylib_path="$1"

  if [ ! -f "$dylib_path" ] || ! command -v otool >/dev/null 2>&1; then
    return 0
  fi

  otool -L "$dylib_path" \
    | sed -nE 's|^[[:space:]]*@rpath/([^/]+\.framework)/.*|\1|p'
}

check_embed() {
  local list_path="$1"
  local runner_app="$2"
  local must_exist="$3"
  local frameworks_dir="$runner_app/Frameworks"
  local debug_dylib="$runner_app/Runner.debug.dylib"
  local missing=""
  local framework
  local checked_count=0
  local names_file

  if [ ! -f "$list_path" ]; then
    echo "ios_pod_framework_embed|skip|input-list-missing|$list_path"
    return 0
  fi

  if [ ! -d "$runner_app" ]; then
    if [ "$must_exist" -eq 1 ]; then
      echo "ios_pod_framework_embed|fail|built-app-missing|$runner_app" >&2
      echo "Run: flutter build ios --simulator --debug" >&2
      return 1
    fi
    echo "ios_pod_framework_embed|skip|built-app-missing|$runner_app"
    return 0
  fi

  names_file="$(mktemp)"
  framework_names_from_input_list "$list_path" > "$names_file"
  framework_names_from_dylib "$debug_dylib" >> "$names_file"

  while IFS= read -r framework || [ -n "$framework" ]; do
    [ -n "$framework" ] || continue
    checked_count=$((checked_count + 1))
    if [ ! -d "$frameworks_dir/$framework" ]; then
      missing+="$framework"$'\n'
    fi
  done < <(LC_ALL=C sort -u "$names_file")

  rm -f "$names_file"

  if [ -n "$missing" ]; then
    echo "❌ iOS simulator app is missing embedded CocoaPods frameworks:" >&2
    printf '%s' "$missing" | sed 's/^/  - /' >&2
    echo "Expected under: $frameworks_dir" >&2
    echo "Rebuild with: flutter build ios --simulator --debug" >&2
    return 1
  fi

  echo "ios_pod_framework_embed|ok|frameworks=$checked_count|app=$runner_app"
}

run_self_test() {
  local tmp_dir
  local list_path
  local app_dir
  local rc=0

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  list_path="$tmp_dir/Pods-Runner-frameworks-Debug-input-files.xcfilelist"
  app_dir="$tmp_dir/Runner.app"
  mkdir -p "$app_dir/Frameworks/Starscream.framework"
  printf '${BUILT_PRODUCTS_DIR}/Starscream/Starscream.framework\n${BUILT_PRODUCTS_DIR}/wallet_connect_v2/wallet_connect_v2.framework' > "$list_path"

  if check_embed "$list_path" "$app_dir" 1 >/tmp/check_ios_pod_framework_embed_unexpected_ok.log 2>&1; then
    echo "self-test|fail|missing-final-line-framework-not-detected" >&2
    cat /tmp/check_ios_pod_framework_embed_unexpected_ok.log >&2
    rc=1
  fi
  rm -f /tmp/check_ios_pod_framework_embed_unexpected_ok.log

  mkdir -p "$app_dir/Frameworks/wallet_connect_v2.framework"
  if ! check_embed "$list_path" "$app_dir" 1 >/dev/null; then
    echo "self-test|fail|expected-frameworks-not-accepted" >&2
    rc=1
  fi

  if [ "$rc" -eq 0 ]; then
    echo "self-test|ok|ios_pod_framework_embed"
  fi
  return "$rc"
}

if [ "$self_test" -eq 1 ]; then
  run_self_test
  exit $?
fi

if [ -z "$app_path" ]; then
  app_path="$(resolve_default_app_path)"
fi

check_embed "$input_list" "$app_path" "$require_built_app"
