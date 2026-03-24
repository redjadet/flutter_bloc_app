#!/bin/bash
# Auto-syncs docs/validation_scripts.md with CHECK_SCRIPTS in tool/delivery_checklist.sh.
# Adds/updates an auto-generated index block so validation_docs check passes.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKLIST="$PROJECT_ROOT/tool/delivery_checklist.sh"
DOC="$PROJECT_ROOT/docs/validation_scripts.md"

if [ ! -f "$CHECKLIST" ] || [ ! -f "$DOC" ]; then
  echo "fix_validation_docs.sh: missing $CHECKLIST or $DOC"
  exit 1
fi

python3 - "$CHECKLIST" "$DOC" <<'PY'
import re
import sys
from pathlib import Path

checklist = Path(sys.argv[1])
doc = Path(sys.argv[2])

checklist_text = checklist.read_text(encoding="utf-8")
doc_text = doc.read_text(encoding="utf-8")

block_match = re.search(r"CHECK_SCRIPTS=\((.*?)\n\)", checklist_text, re.S)
if not block_match:
    raise SystemExit("Could not locate CHECK_SCRIPTS in delivery_checklist.sh")

scripts: list[str] = []
for line in block_match.group(1).splitlines():
    m = re.search(r'"(tool/[^"]+\.sh)"', line)
    if m:
        scripts.append(m.group(1))

if not scripts:
    raise SystemExit("No scripts extracted from CHECK_SCRIPTS")

start_marker = "<!-- AUTO-GENERATED-CHECK_SCRIPTS:START -->"
end_marker = "<!-- AUTO-GENERATED-CHECK_SCRIPTS:END -->"

generated_lines = [
    start_marker,
    "## Checklist Script Index (Auto-generated)",
    "",
    "The list below is generated from `tool/delivery_checklist.sh` `CHECK_SCRIPTS`.",
    "",
]
generated_lines.extend([f"- `{Path(s).name}`" for s in scripts])
generated_lines.extend(["", end_marker])
generated_block = "\n".join(generated_lines)

if start_marker in doc_text and end_marker in doc_text:
    pattern = re.compile(
        rf"{re.escape(start_marker)}.*?{re.escape(end_marker)}",
        re.S,
    )
    new_text = pattern.sub(generated_block, doc_text)
else:
    anchor = "## Keeping This Doc in Sync"
    if anchor in doc_text:
        new_text = doc_text.replace(anchor, f"{generated_block}\n\n{anchor}", 1)
    else:
        if not doc_text.endswith("\n"):
            doc_text += "\n"
        new_text = f"{doc_text}\n{generated_block}\n"

if new_text != doc_text:
    doc.write_text(new_text, encoding="utf-8")
    print("Updated docs/validation_scripts.md auto-generated checklist index.")
else:
    print("docs/validation_scripts.md already in sync (auto-generated block unchanged).")
PY

echo "✅ validation docs auto-fix complete."
