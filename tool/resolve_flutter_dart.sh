#!/usr/bin/env bash
# Shared helpers: find the Flutter SDK `dart` binary when `flutter` on PATH may
# be a repo wrapper (e.g. tool/direnv/bin/flutter) that is not <sdk>/bin/flutter.

RESOLVE_FLUTTER_DART_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE_FLUTTER_DART_ROOT="$(cd "$RESOLVE_FLUTTER_DART_TOOL_DIR/.." && pwd)"

# Remove one PATH directory so `command -v` can find the real SDK binary.
strip_path_dir_from_path() {
  local remove_dir="$1"
  local path_in="${2:-}"
  local out=""
  local IFS=':'
  local entry
  for entry in $path_in; do
    if [ "$entry" = "$remove_dir" ]; then
      continue
    fi
    if [ -z "$out" ]; then
      out="$entry"
    else
      out="$out:$entry"
    fi
  done
  printf '%s' "$out"
}

path_flutter_kind() {
  local flutter_bin="$1"
  local flutter_dir
  local flutter_root

  if [ -z "$flutter_bin" ]; then
    printf 'missing\n'
    return
  fi

  flutter_dir="$(cd "$(dirname "$flutter_bin")" && pwd)"
  flutter_root="$(cd "$flutter_dir/.." && pwd)"

  if [ "$flutter_dir" = "$RESOLVE_FLUTTER_DART_ROOT/tool/direnv/bin" ]; then
    printf 'repo-wrapper\n'
  elif [ -x "$flutter_root/bin/dart" ]; then
    printf 'sdk\n'
  else
    printf 'non-sdk-wrapper\n'
  fi
}

resolve_flutter_sdk_flutter() {
  local flutter_bin
  local flutter_dir
  local flutter_root
  local stripped_path
  local real_flutter
  local real_flutter_root

  flutter_bin="$(command -v flutter || true)"
  if [ -z "$flutter_bin" ]; then
    return 1
  fi

  flutter_dir="$(cd "$(dirname "$flutter_bin")" && pwd)"
  flutter_root="$(cd "$flutter_dir/.." && pwd)"
  if [ -x "$flutter_root/bin/dart" ]; then
    printf '%s\n' "$flutter_bin"
    return 0
  fi

  stripped_path="$(strip_path_dir_from_path "$flutter_dir" "${PATH:-}")"
  real_flutter="$(PATH="$stripped_path" command -v flutter || true)"
  if [ -z "$real_flutter" ]; then
    return 1
  fi

  real_flutter_root="$(cd "$(dirname "$real_flutter")/.." && pwd)"
  if [ ! -x "$real_flutter_root/bin/dart" ]; then
    return 1
  fi

  printf '%s\n' "$real_flutter"
}

print_flutter_resolution_report() {
  local flutter_bin
  local flutter_kind
  local sdk_flutter
  local sdk_root
  local sdk_dart

  flutter_bin="$(command -v flutter || true)"
  flutter_kind="$(path_flutter_kind "$flutter_bin")"

  echo "flutter_resolution|path_flutter|${flutter_bin:-missing}"
  echo "flutter_resolution|path_flutter_kind|$flutter_kind"

  if sdk_flutter="$(resolve_flutter_sdk_flutter)"; then
    sdk_root="$(cd "$(dirname "$sdk_flutter")/.." && pwd)"
    sdk_dart="$sdk_root/bin/dart"
    echo "flutter_resolution|sdk_flutter|$sdk_flutter"
    echo "flutter_resolution|sdk_dart|$sdk_dart"
    if [ "$flutter_kind" != "sdk" ]; then
      echo "flutter_resolution|note|PATH flutter is $flutter_kind; SDK tools resolve through sdk_flutter"
    fi
    return 0
  fi

  echo "flutter_resolution|sdk_flutter|missing"
  echo "flutter_resolution|sdk_dart|missing"
  echo "flutter_resolution|error|Could not resolve Flutter SDK after PATH wrapper stripping"
  return 1
}

# Prints absolute path to the SDK `dart` executable, or exits 1 with a message.
resolve_flutter_dart() {
  local flutter_bin
  local flutter_kind
  local sdk_flutter
  local flutter_root
  local dart_bin

  flutter_bin="$(command -v flutter || true)"
  if [ -z "$flutter_bin" ]; then
    echo "❌ 'flutter' command not found in PATH." >&2
    return 1
  fi

  flutter_kind="$(path_flutter_kind "$flutter_bin")"
  sdk_flutter="$(resolve_flutter_sdk_flutter || true)"
  if [ -z "$sdk_flutter" ]; then
    echo "❌ Flutter SDK binary not found." >&2
    echo "   PATH flutter: $flutter_bin ($flutter_kind)" >&2
    echo "   Expected SDK flutter after stripping wrapper path from PATH." >&2
    return 1
  fi

  flutter_root="$(cd "$(dirname "$sdk_flutter")/.." && pwd)"
  dart_bin="$flutter_root/bin/dart"

  if [ ! -x "$dart_bin" ]; then
    echo "❌ Flutter-managed Dart SDK not found at: $dart_bin" >&2
    echo "   PATH flutter: $flutter_bin ($flutter_kind)" >&2
    echo "   SDK flutter: $sdk_flutter" >&2
    return 1
  fi

  printf '%s\n' "$dart_bin"
}
