#!/usr/bin/env bash
# Shared helpers: find the Flutter SDK `dart` binary when `flutter` on PATH may
# be a repo wrapper (e.g. tool/direnv/bin/flutter) that is not <sdk>/bin/flutter.

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

# Prints absolute path to the SDK `dart` executable, or exits 1 with a message.
resolve_flutter_dart() {
  local flutter_bin
  local flutter_root
  local dart_bin
  local wrapper_dir
  local stripped_path
  local real_flutter

  flutter_bin="$(command -v flutter || true)"
  if [ -z "$flutter_bin" ]; then
    echo "❌ 'flutter' command not found in PATH." >&2
    return 1
  fi

  flutter_root="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
  dart_bin="$flutter_root/bin/dart"

  if [ ! -x "$dart_bin" ]; then
    wrapper_dir="$(cd "$(dirname "$flutter_bin")" && pwd)"
    stripped_path="$(strip_path_dir_from_path "$wrapper_dir" "${PATH:-}")"
    real_flutter="$(PATH="$stripped_path" command -v flutter || true)"
    if [ -n "$real_flutter" ]; then
      flutter_root="$(cd "$(dirname "$real_flutter")/.." && pwd)"
      dart_bin="$flutter_root/bin/dart"
    fi
  fi

  if [ ! -x "$dart_bin" ]; then
    echo "❌ Flutter-managed Dart SDK not found at: $dart_bin" >&2
    return 1
  fi

  printf '%s\n' "$dart_bin"
}
