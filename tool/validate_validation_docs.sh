#!/bin/bash
# Ensures validation_scripts router + shards stay in sync with CHECK_SCRIPTS in tool/delivery_checklist.sh.
# Run from project root. Exit 0 if doc lists all checklist scripts; exit 1 and print missing entries.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKLIST="$PROJECT_ROOT/tool/delivery_checklist.sh"
DOC_ROUTER="$PROJECT_ROOT/docs/validation_scripts.md"
DOC_DIR="$PROJECT_ROOT/docs/validation_scripts"

if [ ! -f "$CHECKLIST" ] || [ ! -f "$DOC_ROUTER" ] || [ ! -d "$DOC_DIR" ]; then
  echo "validate_validation_docs.sh: missing $CHECKLIST, $DOC_ROUTER, or $DOC_DIR"
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
  if ! grep -qF -- "$script" "$DOC_ROUTER" "$DOC_DIR"/*.md 2>/dev/null; then
    missing+=("$script")
  fi
done

if [ -z "${missing[*]-}" ]; then
  exit 0
fi

echo "validation_scripts docs are out of sync with tool/delivery_checklist.sh CHECK_SCRIPTS."
echo "Missing script(s) in doc: ${missing[*]}"
echo "Add entries under docs/validation_scripts/ (or the router) or remove them from CHECK_SCRIPTS."
exit 1
