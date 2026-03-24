#!/usr/bin/env python3
"""Resolve integration test target from changed file paths using integration_selective_map.json.

Reads changed paths from stdin (one per line).

Default: prints one JSON object:
  {"reason": <str>, "target": "<path>|FULL_SUITE"}

With --lines: prints two lines (target, then reason) for robust shell parsing.

Reason values:
  ambiguous_rules — multiple distinct targets matched
  force_full_suite_prefix — a changed file matches force_full_suite_prefixes
  mapped:<rule_ids> — one target matched (comma-separated rule ids if several rules hit)
  no_changed_files — stdin was empty
  no_rules_matched — no rule path_prefix matched any changed file
"""
from __future__ import annotations

import json
import sys
from pathlib import Path


def _matches_prefix(path: str, prefix: str) -> bool:
    p = prefix.replace("\\", "/").rstrip("/")
    if not p:
        return False
    return path == p or path.startswith(f"{p}/")


def _coerce_str_list(raw: object, field: str) -> list[str]:
    if raw is None:
        return []
    if isinstance(raw, str):
        msg = f"{field} must be a JSON array of strings, not a string"
        raise ValueError(msg)
    if not isinstance(raw, list):
        msg = f"{field} must be a JSON array, got {type(raw).__name__}"
        raise ValueError(msg)
    out: list[str] = []
    for item in raw:
        if not isinstance(item, str):
            msg = f"{field} entries must be strings"
            raise ValueError(msg)
        out.append(item)
    return out


def resolve_paths(
    changed: list[str],
    *,
    force_prefixes: list[str],
    rules: list[dict],
) -> tuple[str, str]:
    if not changed:
        return "FULL_SUITE", "no_changed_files"

    for path in changed:
        for prefix in force_prefixes:
            if _matches_prefix(path, prefix):
                return "FULL_SUITE", "force_full_suite_prefix"

    matched_targets: set[str] = set()
    matched_ids: list[str] = []
    for rule in rules:
        rid = str(rule.get("id", "rule"))
        target = str(rule.get("target", ""))
        if not target:
            continue
        prefixes = _coerce_str_list(rule.get("path_prefixes"), "rules[].path_prefixes")
        if not any(
            _matches_prefix(path, pref) for path in changed for pref in prefixes
        ):
            continue
        matched_targets.add(target)
        matched_ids.append(rid)

    if not matched_targets:
        return "FULL_SUITE", "no_rules_matched"
    if len(matched_targets) > 1:
        return "FULL_SUITE", "ambiguous_rules"
    merged = ",".join(matched_ids)
    return next(iter(matched_targets)), f"mapped:{merged}"


def _load_map(map_path: Path) -> tuple[list[str], list[dict]]:
    raw = json.loads(map_path.read_text(encoding="utf-8"))
    force_prefixes = _coerce_str_list(
        raw.get("force_full_suite_prefixes"),
        "force_full_suite_prefixes",
    )
    rules_raw = raw.get("rules", [])
    if rules_raw is None:
        return force_prefixes, []
    if not isinstance(rules_raw, list):
        msg = "rules must be a JSON array"
        raise ValueError(msg)
    for index, entry in enumerate(rules_raw):
        if not isinstance(entry, dict):
            msg = f"rules[{index}] must be a JSON object"
            raise ValueError(msg)
    return force_prefixes, rules_raw


def main() -> None:
    lines_mode = len(sys.argv) > 1 and sys.argv[1] == "--lines"
    repo_root = Path(__file__).resolve().parent.parent
    map_path = repo_root / "tool" / "integration_selective_map.json"
    try:
        force_prefixes, rules = _load_map(map_path)
    except FileNotFoundError:
        print("integration_selective_map.json not found", file=sys.stderr)
        sys.exit(2)
    except json.JSONDecodeError as exc:
        print(f"invalid JSON in {map_path}: {exc}", file=sys.stderr)
        sys.exit(2)
    except ValueError as exc:
        print(f"invalid map schema in {map_path}: {exc}", file=sys.stderr)
        sys.exit(2)

    changed = [ln.strip().replace("\\", "/") for ln in sys.stdin if ln.strip()]

    target, reason = resolve_paths(changed, force_prefixes=force_prefixes, rules=rules)

    if lines_mode:
        print(target)
        print(reason)
    else:
        sys.stdout.write(
            json.dumps({"reason": reason, "target": target}, sort_keys=True) + "\n"
        )


if __name__ == "__main__":
    main()
