#!/usr/bin/env bash
# Fail when a modal bottom sheet / adaptive sheet builder reads a Cubit/Bloc
# without re-providing it via BlocProvider.value (ProviderNotFound on overlay).
#
# Usage:
#   tool/check_modal_bloc_provider.sh
#   tool/check_modal_bloc_provider.sh --paths path/to/file.dart
#   tool/check_modal_bloc_provider.sh --staged
set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"
# shellcheck disable=SC1091
source "$TOOL_DIR/check_helpers.sh"

MODE="${CHECK_MODAL_BLOC_PROVIDER_MODE:-fail}"
STAGED_MODE=0
MANUAL_PATHS=()

usage() {
  cat <<'EOF'
Usage: tool/check_modal_bloc_provider.sh [--staged | --paths PATH...]

Flags modal sheet builders that likely need a page Cubit/Bloc but omit
BlocProvider.value (overlay routes drop page providers).

Triggers when the show* call:
  - reads/watches/selects a Cubit via context/sheetContext, or
  - mounts a non-layout custom widget as the sheet root
and the same call lacks BlocProvider.value.

Suppress: // modal_bloc_provider:ignore <reason> on the show* line or line above.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged)
      STAGED_MODE=1
      shift
      ;;
    --paths)
      shift
      if [[ $# -eq 0 ]]; then
        echo "❌ --paths requires at least one path" >&2
        exit 1
      fi
      while [[ $# -gt 0 && "$1" != --* ]]; do
        MANUAL_PATHS+=("$1")
        shift
      done
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

echo "🔍 Checking modal sheets re-provide Bloc/Cubit via BlocProvider.value..."

collect_default_files() {
  local -n out_ref="$1"
  out_ref=()
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ -f "$file" ] || continue
    out_ref+=("$file")
  done < <(
    if command -v rg >/dev/null 2>&1; then
      rg -l --glob '*.dart' --glob '!**/*.g.dart' --glob '!**/*.freezed.dart' \
        'showModalBottomSheet|showAdaptiveModalBottomSheet' \
        lib apps/mobile/lib 2>/dev/null || true
    else
      find lib apps/mobile/lib -name '*.dart' 2>/dev/null \
        | grep -vE '\.(g|freezed)\.dart$' \
        | while IFS= read -r f; do
            grep -qE 'showModalBottomSheet|showAdaptiveModalBottomSheet' "$f" 2>/dev/null && echo "$f"
          done
    fi
  )
}

collect_staged_files() {
  local -n out_ref="$1"
  out_ref=()
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      *.dart)
        if [ -f "$file" ] && grep -qE 'showModalBottomSheet|showAdaptiveModalBottomSheet' "$file" 2>/dev/null; then
          out_ref+=("$file")
        fi
        ;;
    esac
  done < <(git diff --cached --name-only --diff-filter=ACMRTUXB 2>/dev/null || true)
}

FILES=()
if [ "${#MANUAL_PATHS[@]}" -gt 0 ]; then
  FILES=("${MANUAL_PATHS[@]}")
elif [ "$STAGED_MODE" -eq 1 ]; then
  collect_staged_files FILES
  if [ "${#FILES[@]}" -eq 0 ]; then
    echo "ℹ️  No staged modal-sheet dart paths; skipping modal BlocProvider guard"
    exit 0
  fi
else
  collect_default_files FILES
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "✅ No modal-sheet dart files to scan"
  exit 0
fi

python3 - "$MODE" "${FILES[@]}" <<'PY'
import re
import sys
from pathlib import Path

mode = sys.argv[1]
paths = sys.argv[2:]

SHOW_RE = re.compile(
    r"(?:PlatformAdaptive\.)?show(?:Modal|AdaptiveModal)BottomSheet\s*(?:<[^>]*>)?\s*\("
)
IGNORE_RE = re.compile(r"modal_bloc_provider:ignore")
PROVIDER_RE = re.compile(r"BlocProvider(?:\.\w+|<\s*\w+\s*>)?\.value\b")
READ_RE = re.compile(
    r"(?:context|sheetContext|dialogContext|popupContext)\s*\.\s*(?:read|watch|select)\s*<"
    r"|context\s*\.\s*cubit\s*<"
    r"|\.cubit\s*<"
)
BLOC_IMPORT_RE = re.compile(
    r"package:flutter_bloc/|package:ilkersevim_type_safe_bloc/|cubit_helpers\.dart"
)
LAYOUT_ROOTS = {
    "Padding",
    "SizedBox",
    "SafeArea",
    "Center",
    "Align",
    "Container",
    "Column",
    "Row",
    "Wrap",
    "Stack",
    "ListView",
    "SingleChildScrollView",
    "CustomScrollView",
    "Material",
    "Scaffold",
    "Builder",
    "StatefulBuilder",
    "MediaQuery",
    "Theme",
    "DefaultTextStyle",
    "Text",
    "Divider",
    "CupertinoActionSheet",
    "CupertinoPicker",
}

violations = []


def line_ignored(lines, idx):
    if IGNORE_RE.search(lines[idx]):
        return True
    if idx > 0 and IGNORE_RE.search(lines[idx - 1]):
        return True
    return False


def extract_call(text, start):
    i = start
    depth = 0
    in_str = None
    escape = False
    while i < len(text):
        ch = text[i]
        if in_str:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch in ("'", '"'):
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return text[start : i + 1]
        i += 1
    return text[start:]


def builder_section(call: str) -> str | None:
    m = re.search(r"builder\s*:", call)
    if not m:
        return None
    return call[m.start() :]


def mounts_custom_root(builder: str) -> bool:
    # Forwarded builder: builder: builder,
    if re.search(r"builder\s*:\s*builder\b", builder):
        return False
    # Find first PascalCase constructor after => or { return
    m = re.search(
        r"(?:=>|return)\s*(?:const\s+)?(_?[A-Z][A-Za-z0-9_]*)\s*(?:\.|\<|\()",
        builder,
        re.DOTALL,
    )
    if not m:
        return False
    return m.group(1) not in LAYOUT_ROOTS


for path_str in paths:
    path = Path(path_str)
    if not path.is_file():
        continue
    text = path.read_text(encoding="utf-8")
    if not BLOC_IMPORT_RE.search(text):
        continue
    lines = text.splitlines()
    for match in SHOW_RE.finditer(text):
        abs_start = match.start()
        line_no = text.count("\n", 0, abs_start) + 1
        if line_ignored(lines, line_no - 1):
            continue
        call = extract_call(text, match.start())
        builder = builder_section(call)
        if builder is None:
            continue
        if PROVIDER_RE.search(call):
            continue
        risky = READ_RE.search(call) is not None or mounts_custom_root(builder)
        if not risky:
            continue
        violations.append(
            f"{path}:{line_no}: modal sheet likely needs BlocProvider.value "
            "(overlay routes drop page providers; capture cubit then wrap child)"
        )

if not violations:
    print("✅ No modal sheet BlocProvider.value violations")
    sys.exit(0)

for v in violations:
    print(v)
msg = (
    f"❌ modal BlocProvider guard found {len(violations)} issue(s)\n"
    "  Fix: final cubit = context.read<X>(); show…(builder: (_) => "
    "BlocProvider.value(value: cubit, child: …))\n"
    "  Suppress: // modal_bloc_provider:ignore <reason>"
)
print(msg, file=sys.stderr)
if mode == "warn":
    sys.exit(0)
sys.exit(1)
PY
