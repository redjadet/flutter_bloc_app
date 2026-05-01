#!/usr/bin/env bash
# Ensure macOS debug-only fallbacks cannot apply to Flutter web on macOS browsers.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking macOS debug fallback web guards..."

if ! command -v rg >/dev/null 2>&1; then
  echo "❌ ripgrep is required for macOS debug web guard checks"
  exit 1
fi

violations=""

while IFS=: read -r file line _match; do
  [ -n "${file:-}" ] || continue
  [ -n "${line:-}" ] || continue

  start=$((line - 4))
  if [ "$start" -lt 1 ]; then
    start=1
  fi
  end=$((line + 4))
  context="$(sed -n "${start},${end}p" "$file")"

  if [[ "$context" != *"!kReleaseMode"* ]]; then
    continue
  fi

  if [[ "$context" != *"!kIsWeb"* ]]; then
    violations+="${file}:${line}: macOS debug fallback missing !kIsWeb guard"$'\n'
  fi
done < <(
  rg -n "defaultTargetPlatform\s*==\s*TargetPlatform\.macOS|TargetPlatform\.macOS\s*==\s*defaultTargetPlatform" \
    lib \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart"
)

if [ -n "$violations" ]; then
  echo "❌ macOS debug fallbacks must include !kIsWeb"
  echo "$violations"
  echo "Add !kIsWeb to desktop-only debug fallback gates before defaultTargetPlatform == TargetPlatform.macOS."
  exit 1
fi

echo "✅ macOS debug fallbacks are web-guarded"
