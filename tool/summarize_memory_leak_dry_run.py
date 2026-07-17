#!/usr/bin/env python3
"""Summarize flutter test leak_tracker dry-run output (Wave B0 report-only)."""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

LEAK_SECTION_RE = re.compile(r"^\s*(notDisposed|notGCed|gcedLate):\s*$")
TOTAL_RE = re.compile(r"^\s*total:\s*(\d+)\s*$")
OBJECT_CLASS_RE = re.compile(r"^\s{4,}([A-Za-z_][\w.<>,\s?]*):\s*$")
TEST_FIELD_RE = re.compile(r"^\s+test:\s*(.+)\s*$")
FAILED_TEST_RE = re.compile(r"^\[([E+/-])\]\s+(.+)$")
FAILED_COMPACT_RE = re.compile(
    r"^\d+:\d+\s+\+\d+(?:\s+-\d+)?:\s+(.+?)\s+\[E\]\s*$"
)
CONTAINS_LEAKS_RE = re.compile(r"contains leaks:|Expected: leak free|Actual: <Instance of 'Leaks'>")

# Heuristic harness / framework noise (Wave B0 triage seeds — not a gate allowlist).
HARNESS_NOISE_CLASSES = {
    "Image",
    "ImageStreamCompleter",
    "ImageStreamCompleterHandle",
    "MultiFrameImageStreamCompleter",
    "_LiveImage",
    "SemanticsNode",
    "PipelineOwner",
    "Layer",
    "OffsetLayer",
    "OpacityLayer",
    "TransformLayer",
    "ClipRectLayer",
    "ClipPathLayer",
    "ClipRRectLayer",
    "PhysicalModelLayer",
    "FollowerLayer",
    "LeaderLayer",
    "AnnotatedRegionLayer",
    "BackdropFilterLayer",
    "TextureLayer",
    "PlatformViewLayer",
    "TextPainter",
    "GoRouteInformationProvider",
    "GoRouterDelegate",
    "TapGestureRecognizer",
    "PanGestureRecognizer",
    "LongPressGestureRecognizer",
    "HorizontalDragGestureRecognizer",
    "VerticalDragGestureRecognizer",
}


def parse_meta(path: Path) -> dict[str, str]:
    meta: dict[str, str] = {}
    if not path.exists():
        return meta
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            meta[key.strip()] = value.strip()
    return meta


def parse_log(text: str) -> dict:
    leak_failures: list[dict] = []
    non_leak_failures: list[str] = []
    class_counts: Counter[str] = Counter()
    type_totals: Counter[str] = Counter()
    class_by_type: dict[str, Counter[str]] = defaultdict(Counter)
    tests_with_leaks: set[str] = set()

    lines = text.splitlines()
    i = 0
    current_failed_test: str | None = None
    while i < len(lines):
        line = lines[i]
        failed = FAILED_TEST_RE.match(line)
        if failed and failed.group(1) == "E":
            current_failed_test = failed.group(2).strip()
        else:
            compact = FAILED_COMPACT_RE.match(line)
            if compact:
                current_failed_test = compact.group(1).strip()

        if CONTAINS_LEAKS_RE.search(line):
            # Walk forward for structured leak blocks.
            section = None
            objects_for_failure: dict[str, list[str]] = defaultdict(list)
            local_types: Counter[str] = Counter()
            j = i
            while j < len(lines) and j < i + 400:
                sec = LEAK_SECTION_RE.match(lines[j])
                if sec:
                    section = sec.group(1)
                    j += 1
                    if j < len(lines):
                        tot = TOTAL_RE.match(lines[j])
                        if tot:
                            local_types[section] += int(tot.group(1))
                            type_totals[section] += int(tot.group(1))
                    j += 1
                    continue
                if section and lines[j].strip() == "objects:":
                    j += 1
                    while j < len(lines):
                        cls = OBJECT_CLASS_RE.match(lines[j])
                        if not cls:
                            break
                        class_name = cls.group(1).strip()
                        class_counts[class_name] += 1
                        class_by_type[section][class_name] += 1
                        test_name = current_failed_test or "unknown"
                        j += 1
                        # Consume nested fields (test:, identityHashCode:, …).
                        while j < len(lines):
                            nested = lines[j]
                            if OBJECT_CLASS_RE.match(nested) or LEAK_SECTION_RE.match(
                                nested
                            ):
                                break
                            if nested[:1] and not nested.startswith((" ", "\t")):
                                break
                            tf = TEST_FIELD_RE.match(nested)
                            if tf:
                                test_name = tf.group(1).strip()
                            j += 1
                        objects_for_failure[class_name].append(test_name)
                        tests_with_leaks.add(test_name)
                    continue
                if FAILED_COMPACT_RE.match(lines[j]) and j > i + 5:
                    break
                if lines[j].startswith("00:") and "[E]" not in lines[j] and j > i + 5:
                    break
                j += 1

            leak_failures.append(
                {
                    "test": current_failed_test or "unknown",
                    "types": dict(local_types),
                    "classes": {
                        cls: sorted(set(tests))
                        for cls, tests in objects_for_failure.items()
                    },
                }
            )
            i = max(i + 1, j)
            continue

        i += 1

    # Second pass: failed tests without leak marker nearby.
    for idx, line in enumerate(lines):
        name: str | None = None
        failed = FAILED_TEST_RE.match(line)
        if failed and failed.group(1) == "E":
            name = failed.group(2).strip()
        else:
            compact = FAILED_COMPACT_RE.match(line)
            if compact:
                name = compact.group(1).strip()
        if not name:
            continue
        window = "\n".join(lines[idx : idx + 80])
        if CONTAINS_LEAKS_RE.search(window):
            continue
        if name not in non_leak_failures:
            non_leak_failures.append(name)

    harness_noise = {
        cls: count for cls, count in class_counts.items() if cls in HARNESS_NOISE_CLASSES
    }
    product_candidates = {
        cls: count
        for cls, count in class_counts.items()
        if cls not in HARNESS_NOISE_CLASSES
    }

    return {
        "leak_failure_count": len(leak_failures),
        "tests_with_leaks": sorted(tests_with_leaks),
        "non_leak_failures": non_leak_failures,
        "type_totals": dict(type_totals),
        "class_counts": dict(class_counts.most_common()),
        "class_by_type": {k: dict(v.most_common()) for k, v in class_by_type.items()},
        "harness_noise_classes": harness_noise,
        "product_candidate_classes": product_candidates,
        "leak_failures": leak_failures,
    }


def write_markdown(summary: dict, meta: dict[str, str], path: Path) -> None:
    lines: list[str] = []
    lines.append("# Memory leak tracking dry-run summary")
    lines.append("")
    lines.append("Report-only Wave B0 lane. Default suite still uses `withIgnoredAll()`.")
    lines.append("")
    lines.append("## Meta")
    lines.append("")
    for key in sorted(meta):
        lines.append(f"- `{key}`: `{meta[key]}`")
    lines.append("")
    lines.append("## Totals")
    lines.append("")
    lines.append(f"- Leak-shaped failures: **{summary['leak_failure_count']}**")
    lines.append(f"- Tests naming leaks: **{len(summary['tests_with_leaks'])}**")
    lines.append(f"- Non-leak failures: **{len(summary['non_leak_failures'])}**")
    lines.append(f"- Type totals: `{summary['type_totals']}`")
    lines.append("")
    lines.append("## Top leak classes")
    lines.append("")
    lines.append("| Class | Count | Bucket |")
    lines.append("| --- | ---: | --- |")
    noise = summary.get("harness_noise_classes", {})
    for cls, count in list(summary.get("class_counts", {}).items())[:40]:
        bucket = "harness-noise?" if cls in noise else "product-candidate?"
        lines.append(f"| `{cls}` | {count} | {bucket} |")
    lines.append("")
    lines.append("## Product-candidate classes (heuristic)")
    lines.append("")
    for cls, count in list(summary.get("product_candidate_classes", {}).items())[:30]:
        lines.append(f"- `{cls}` × {count}")
    lines.append("")
    lines.append("## Harness-noise classes (heuristic)")
    lines.append("")
    for cls, count in list(summary.get("harness_noise_classes", {}).items())[:30]:
        lines.append(f"- `{cls}` × {count}")
    lines.append("")
    lines.append("## Non-leak failures (sample)")
    lines.append("")
    for name in summary.get("non_leak_failures", [])[:40]:
        lines.append(f"- {name}")
    lines.append("")
    lines.append("## Next")
    lines.append("")
    lines.append("- Promote durable findings into `docs/audits/memory_quality_wave_b0_review_*.md`")
    lines.append("- Wave B1: tag stable journeys only; do not flip global ignore")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True)
    parser.add_argument("--meta", required=True)
    parser.add_argument("--json-out", required=True)
    parser.add_argument("--md-out", required=True)
    args = parser.parse_args()

    log_path = Path(args.log)
    meta = parse_meta(Path(args.meta))
    text = log_path.read_text(encoding="utf-8", errors="replace") if log_path.exists() else ""
    summary = parse_log(text)
    summary["meta"] = meta

    Path(args.json_out).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    write_markdown(summary, meta, Path(args.md_out))
    print(f"Wrote {args.json_out}")
    print(f"Wrote {args.md_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
