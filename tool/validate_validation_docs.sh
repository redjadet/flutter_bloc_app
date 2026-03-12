#!/bin/bash
# Ensures docs/validation_scripts.md stays in sync with CHECK_SCRIPTS in tool/delivery_checklist.sh.
# Run from project root. Exit 0 if doc lists all checklist scripts; exit 1 and print missing entries.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKLIST="$PROJECT_ROOT/tool/delivery_checklist.sh"
DOC="$PROJECT_ROOT/docs/validation_scripts.md"

if [ ! -f "$CHECKLIST" ] || [ ! -f "$DOC" ]; then
  echo "validate_validation_docs.sh: missing $CHECKLIST or $DOC"
  exit 1
fi

# Extract script basenames from CHECK_SCRIPTS=(...) in delivery_checklist.sh.
scripts_in_checklist=()
while IFS= read -r line; do
  script_path="$(printf '%s\n' "$line" | sed -n 's/^[[:space:]]*"\([^"]\+\)".*/\1/p')"
  if [ -z "$script_path" ]; then
    continue
  fi
  case "$script_path" in
    tool/*.sh) scripts_in_checklist+=("$(basename "$script_path")") ;;
  esac
done < <(sed -n '/^CHECK_SCRIPTS=(/,/^)/p' "$CHECKLIST")

missing=()
for script in "${scripts_in_checklist[@]-}"; do
  if [ -z "$script" ]; then
    continue
  fi
  if ! grep -qF "$script" "$DOC"; then
    missing+=("$script")
  fi
done

if [ -z "${missing[*]-}" ]; then
  exit 0
fi

echo "docs/validation_scripts.md is out of sync with tool/delivery_checklist.sh CHECK_SCRIPTS."
echo "Missing script(s) in doc: ${missing[*]}"
echo "Add entries for these in docs/validation_scripts.md or remove them from CHECK_SCRIPTS."
exit 1
