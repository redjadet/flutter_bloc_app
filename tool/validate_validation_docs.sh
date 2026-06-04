#!/bin/bash
# Ensures validation_scripts router + shards stay in sync with on-disk check scripts
# and CHECK_SCRIPTS in tool/delivery_checklist.sh.
# Run from project root. Exit 0 if docs list every check script and counts match.

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
  if [[ ! "$line" =~ \"(tool/[^\"]+\.sh)\" ]]; then
    continue
  fi
  script_path="${BASH_REMATCH[1]}"
  case "$script_path" in
    tool/*.sh) scripts_in_checklist+=("$(basename "$script_path")") ;;
  esac
done < <(sed -n '/^CHECK_SCRIPTS=(/,/^)/p' "$CHECKLIST")

scripts_on_disk=()
while IFS= read -r script_path; do
  scripts_on_disk+=("$(basename "$script_path")")
done < <(
  find "$PROJECT_ROOT/tool" -maxdepth 1 -type f -name 'check_*.sh' \
    ! -name 'check_helpers.sh' -print | LC_ALL=C sort
)

missing=()
for script in "${scripts_on_disk[@]-}"; do
  if [ -z "$script" ]; then
    continue
  fi
  if ! grep -qF -- "$script" "$DOC_ROUTER" "$DOC_DIR"/*.md 2>/dev/null; then
    missing+=("$script")
  fi
done

failed=0

if [ -n "${missing[*]-}" ]; then
  echo "validation_scripts docs are out of sync with on-disk tool/check_*.sh inventory."
  echo "Missing script(s) in doc: ${missing[*]}"
  echo "Add entries under docs/validation_scripts/ (or the router), or remove obsolete scripts."
  failed=1
fi

disk_count="${#scripts_on_disk[@]}"
checklist_count="${#scripts_in_checklist[@]}"
catalog_count_claim="**${disk_count}** scripts"
overview_disk_count_claim="**${disk_count}** \`check_*.sh\` scripts"
checklist_count_claim="**${checklist_count}** scripts in \`./bin/checklist\`"
overview_checklist_count_claim="**${checklist_count}** in \`./bin/checklist\`"

if ! grep -qF -- "$catalog_count_claim" "$DOC_DIR/catalog.md"; then
  echo "validation_scripts catalog disk count is stale: expected '$catalog_count_claim'."
  failed=1
fi
if ! grep -qF -- "$overview_disk_count_claim" "$DOC_DIR/overview.md"; then
  echo "validation_scripts overview disk count is stale: expected '$overview_disk_count_claim'."
  failed=1
fi
if ! grep -qF -- "$checklist_count_claim" "$DOC_DIR/catalog.md"; then
  echo "validation_scripts catalog checklist count is stale: expected '$checklist_count_claim'."
  failed=1
fi
if ! grep -qF -- "$overview_checklist_count_claim" "$DOC_DIR/overview.md"; then
  echo "validation_scripts overview checklist count is stale: expected '$overview_checklist_count_claim'."
  failed=1
fi

exit "$failed"
