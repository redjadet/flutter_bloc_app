#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RULE_FILE="$PROJECT_ROOT/.cursor/rules/router-feature-validation.mdc"
BENCHMARK_FILE="$PROJECT_ROOT/analysis/agent_scorecard/router_trigger_benchmark_v1.json"

python3 - "$RULE_FILE" "$BENCHMARK_FILE" <<'PY'
import fnmatch
import json
import re
import sys
from pathlib import Path

rule_text = Path(sys.argv[1]).read_text(encoding="utf-8")
benchmark = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))


def extract_globs_from_frontmatter(text: str) -> list[str]:
    """Support `globs: a, b` and YAML list form under `globs:`."""
    lines = text.splitlines()
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith("globs:"):
            continue
        rest = stripped[len("globs:") :].strip()
        if rest:
            return [g.strip() for g in rest.split(",") if g.strip()]
        globs: list[str] = []
        j = i + 1
        while j < len(lines):
            item = lines[j].strip()
            if not item:
                j += 1
                continue
            if item.startswith("- "):
                globs.append(item[2:].strip())
                j += 1
                continue
            break
        if globs:
            return globs
        raise SystemExit("Empty globs list in router-feature-validation.mdc")
    raise SystemExit("Could not parse globs from router-feature-validation.mdc")


globs = extract_globs_from_frontmatter(rule_text)

tp = fp = tn = fn = 0

for item in benchmark:
    path = item["path"]
    expected = bool(item["should_trigger"])
    actual = any(fnmatch.fnmatch(path, pattern) for pattern in globs)
    if expected and actual:
        tp += 1
    elif not expected and actual:
        fp += 1
    elif expected and not actual:
        fn += 1
    else:
        tn += 1

precision = tp / (tp + fp) if (tp + fp) else 1.0
recall = tp / (tp + fn) if (tp + fn) else 1.0

print(f"TP={tp} FP={fp} FN={fn} TN={tn}")
print(f"precision={precision:.3f}")
print(f"recall={recall:.3f}")

min_threshold = 0.80
if precision < min_threshold or recall < min_threshold:
    raise SystemExit(
        f"Precision/recall below threshold {min_threshold:.2f} (precision={precision:.3f}, recall={recall:.3f})"
    )
PY
