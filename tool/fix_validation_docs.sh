#!/bin/bash
# Auto-syncs docs/validation_scripts/checklist_index.md with CHECK_SCRIPTS in tool/delivery_checklist.sh.
# Adds/updates an auto-generated index block so validation_docs check passes.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKLIST="$PROJECT_ROOT/tool/delivery_checklist.sh"
DOC="$PROJECT_ROOT/docs/validation_scripts/checklist_index.md"

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
    if not doc_text.endswith("\n"):
        doc_text += "\n"
    new_text = f"{doc_text}\n{generated_block}\n"

if new_text != doc_text:
    doc.write_text(new_text, encoding="utf-8")
    print("Updated docs/validation_scripts/checklist_index.md auto-generated block.")
else:
    print("checklist_index.md already in sync (auto-generated block unchanged).")

project_root = checklist.resolve().parent.parent
disk_count = sum(
    1
    for p in (project_root / "tool").glob("check_*.sh")
    if p.name != "check_helpers.sh"
)
checklist_count = len(scripts)
disk_claim = f"**{disk_count}**"
checklist_claim = f"**{checklist_count}**"

catalog_path = project_root / "docs/validation_scripts/catalog.md"
overview_path = project_root / "docs/validation_scripts/overview.md"


def refresh_counts(text: str, *, table_disk: bool) -> str:
    if table_disk:
        text = re.sub(
            r"(\| `tool/check_\*\.sh` on disk \| )\*\*\d+\*\*",
            rf"\g<1>{disk_claim}",
            text,
            count=1,
        )
        text = re.sub(
            r"(\| `CHECK_SCRIPTS` in `tool/delivery_checklist\.sh` \| )\*\*\d+\*\*",
            rf"\g<1>{checklist_claim}",
            text,
            count=1,
        )
        return text

    text = re.sub(
        r"(\*\*)\d+(\*\* `check_\*\.sh` scripts on disk)",
        rf"\g<1>{disk_count}\g<2>",
        text,
        count=1,
    )
    text = re.sub(
        r"(\*\*)\d+(\*\* in `\./bin/checklist`)",
        rf"\g<1>{checklist_count}\g<2>",
        text,
        count=1,
    )
    return text


def count_anchors_present(text: str, *, table_disk: bool) -> bool:
    if table_disk:
        return (
            "| `tool/check_*.sh` on disk |" in text
            and "| `CHECK_SCRIPTS` in `tool/delivery_checklist.sh` |" in text
        )
    return (
        "check_*.sh` scripts on disk" in text
        and "in `./bin/checklist`" in text
    )


for path, table_disk in ((catalog_path, True), (overview_path, False)):
    if not path.is_file():
        print(
            f"warn|fix_validation_docs|missing {path.relative_to(project_root)}",
            file=sys.stderr,
        )
        continue
    original = path.read_text(encoding="utf-8")
    if not count_anchors_present(original, table_disk=table_disk):
        print(
            f"warn|fix_validation_docs|count anchors missing in "
            f"{path.relative_to(project_root)} (update doc or refresh_counts regex)",
            file=sys.stderr,
        )
    updated = refresh_counts(original, table_disk=table_disk)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        print(f"Updated {path.relative_to(project_root)} count claims.")
PY

echo "✅ validation docs auto-fix complete."
