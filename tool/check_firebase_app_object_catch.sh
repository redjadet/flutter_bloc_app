#!/usr/bin/env bash
# Fail when Firebase.app() is inside a try that catches Exception (or
# Firebase*Exception) without also catching Object. On web/dart2js, missing
# default apps often throw a raw JS Error, which is not a Dart Exception —
# that escaped catch blanked GitHub Pages after splash (2026-09-07).
#
# Usage:
#   tool/check_firebase_app_object_catch.sh
#   tool/check_firebase_app_object_catch.sh --paths tool/fixtures/firebase_app_object_catch/bad.dart
#   tool/check_firebase_app_object_catch.sh --self-test

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$TOOL_DIR/check_firebase_app_object_catch.sh"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
cd "$APP_ROOT"
# shellcheck disable=SC1091
source "$TOOL_DIR/check_helpers.sh"

SCAN_PATHS=("lib")
SELF_TEST=0

usage() {
  sed -n '1,14p' "$SCRIPT_PATH" | tail -n +2
}

resolve_scan_path() {
  local p="$1"
  if [[ "$p" = /* ]]; then
    printf '%s\n' "$p"
  elif [[ -e "$WORKSPACE_ROOT/$p" ]]; then
    printf '%s\n' "$WORKSPACE_ROOT/$p"
  elif [[ -e "$APP_ROOT/$p" ]]; then
    printf '%s\n' "$APP_ROOT/$p"
  else
    printf '%s\n' "$WORKSPACE_ROOT/$p"
  fi
}

scan_paths() {
  python3 - "$@" <<'PY'
import pathlib
import re
import sys

app_call = re.compile(r"Firebase\.app\s*\(")
on_clause = re.compile(r"\}\s*on\s+([A-Za-z0-9_.<>,\s]+?)(?:\s+catch|\s*\{)")
ignore_re = re.compile(r"check-ignore|firebase-app-object-catch-ignore")

def strip_strings_and_comments(text: str) -> str:
    """Replace comments/strings with spaces so indices stay aligned with original."""
    out = [" "] * len(text)
    i = 0
    n = len(text)
    while i < n:
        if text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            end = n if end < 0 else end + 2
            i = end
            continue
        ch = text[i]
        if ch in "'\"":
            quote = ch
            i += 1
            while i < n:
                if text[i] == "\\":
                    i = min(n, i + 2)
                    continue
                if text[i] == quote:
                    i += 1
                    break
                i += 1
            continue
        if ch == "r" and i + 1 < n and text[i + 1] in "'\"":
            quote = text[i + 1]
            i += 2
            while i < n and text[i] != quote:
                i += 1
            i = min(n, i + 1)
            continue
        out[i] = ch
        i += 1
    return "".join(out)

def line_of(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1

def find_enclosing_try(text: str, index: int):
    depth = 0
    i = index
    while i >= 0:
        if text.startswith("try", i) and (
            i == 0 or not (text[i - 1].isalnum() or text[i - 1] == "_")
        ):
            j = i + 3
            while j < len(text) and text[j].isspace():
                j += 1
            if j < len(text) and text[j] == "{" and depth == 0:
                return i
        ch = text[i]
        if ch == "}":
            depth += 1
        elif ch == "{":
            if depth > 0:
                depth -= 1
        i -= 1
    return None

def catch_types_after_try(text: str, try_index: int):
    """Return (catch_type_names, try_body_end_index) or ([], -1)."""
    brace = text.find("{", try_index)
    if brace < 0:
        return [], -1
    depth = 0
    i = brace
    end = -1
    while i < len(text):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i
                break
        i += 1
    if end < 0:
        return [], -1
    region = text[end : min(len(text), end + 1200)]
    types = []
    pos = 0
    cont_on = re.compile(
        r"\s*on\s+([A-Za-z0-9_.<>,\s]+?)(?:\s+catch|\s*\{)"
    )
    while True:
        if not types:
            m = on_clause.search(region, pos)
            if not m:
                break
            if region[pos : m.start()].strip():
                break
            type_raw = m.group(1)
            match_end = m.end()
        else:
            m = cont_on.match(region, pos)
            if not m:
                break
            type_raw = m.group(1)
            match_end = m.end()
        raw = re.sub(r"\s+", " ", type_raw).strip()
        types.append(raw)
        block_start = region.find("{", match_end - 1)
        if block_start < 0:
            break
        d = 0
        j = block_start
        while j < len(region):
            if region[j] == "{":
                d += 1
            elif region[j] == "}":
                d -= 1
                if d == 0:
                    pos = j + 1
                    break
            j += 1
        else:
            break
    return types, end

def is_object_catch(type_name: str) -> bool:
    return type_name == "Object" or type_name.startswith("Object ")

def is_narrow_catch(type_name: str) -> bool:
    if is_object_catch(type_name):
        return False
    return (
        type_name == "Exception"
        or type_name.startswith("Exception ")
        or "Exception" in type_name
    )

violations = []
missing = []
for path_str in sys.argv[1:]:
    path = pathlib.Path(path_str)
    if not path.exists():
        missing.append(path_str)
        continue
    if path.is_dir():
        files = sorted(path.rglob("*.dart"))
    else:
        files = [path]
    for dart in files:
        if any(part in dart.name for part in (".g.dart", ".freezed.dart", ".gr.dart")):
            continue
        original = dart.read_text(encoding="utf-8")
        text = strip_strings_and_comments(original)
        lines = original.splitlines()
        for m in app_call.finditer(text):
            idx = m.start()
            lineno = line_of(original, idx)
            line_text = lines[lineno - 1] if 0 < lineno <= len(lines) else ""
            if ignore_re.search(line_text):
                continue
            try_idx = find_enclosing_try(text, idx)
            if try_idx is None:
                continue
            types, try_body_end = catch_types_after_try(text, try_idx)
            if try_body_end < 0 or not (try_idx < idx < try_body_end):
                continue
            if not types:
                continue
            if any(is_object_catch(t) for t in types):
                continue
            if any(is_narrow_catch(t) for t in types):
                violations.append(
                    f"{dart}:{lineno}: Firebase.app() catch must include on Object "
                    f"(found: {', '.join(types)}; JS Error on web is not Exception)"
                )

for path in missing:
    print(f"missing|{path}")
for v in violations:
    print(v)
PY
}

run_self_test() {
  local FIXTURE_DIR="$WORKSPACE_ROOT/tool/fixtures/firebase_app_object_catch"
  local bad_out good_out

  bad_out="$(scan_paths "$FIXTURE_DIR/bad.dart" || true)"
  if ! printf '%s\n' "$bad_out" | grep -q 'Firebase.app() catch must include on Object'; then
    echo "❌ self-test: expected bad.dart to fail"
    printf '%s\n' "$bad_out"
    return 1
  fi

  good_out="$(scan_paths "$FIXTURE_DIR/good.dart" || true)"
  if [[ -n "$good_out" ]]; then
    echo "❌ self-test: expected good.dart to pass"
    printf '%s\n' "$good_out"
    return 1
  fi

  echo "✅ firebase_app_object_catch self-test passed"
  return 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths)
      shift
      if [[ $# -eq 0 ]]; then
        echo "❌ --paths requires at least one path" >&2
        exit 1
      fi
      SCAN_PATHS=()
      while [[ $# -gt 0 && "$1" != --* ]]; do
        SCAN_PATHS+=("$(resolve_scan_path "$1")")
        shift
      done
      ;;
    --self-test)
      SELF_TEST=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "❌ Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$SELF_TEST" -eq 1 ]]; then
  run_self_test
  exit $?
fi

# Always exercise fixtures before production scan so CI catches guard regressions.
run_self_test

echo "🔍 Checking Firebase.app() catches use on Object (web JS Error safe)..."

mapfile -t _scan_args < <(printf '%s\n' "${SCAN_PATHS[@]}")
RAW_VIOLATIONS="$(scan_paths "${_scan_args[@]}")"
if printf '%s\n' "$RAW_VIOLATIONS" | grep -q '^missing|'; then
  echo "❌ Firebase.app() object-catch: missing scan path(s)"
  printf '%s\n' "$RAW_VIOLATIONS" | sed -n 's/^missing|/  /p'
  exit 1
fi
VIOLATIONS="$(filter_ignored "$RAW_VIOLATIONS")"

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored:"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "❌ Firebase.app() object-catch: ${count} violation(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d'
  echo "Use on Object (after optional FirebaseException) so web JS Errors cannot escape startup DI."
  exit 1
fi

echo "✅ Firebase.app() catches include on Object"
exit 0
