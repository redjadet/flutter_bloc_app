#!/usr/bin/env python3
"""Print markdown list lines for $SUMMARY_JSON (GitHub Actions step summary helper)."""
from __future__ import annotations

import json
import os
import sys

_PATH = os.environ.get("SUMMARY_JSON", "").strip()

_KEYS = (
    "status",
    "exit_code",
    "failure_category",
    "duration_ms",
    "retried",
    "retry_reason",
    "selective_resolution_reason",
    "targets",
)


def _safe_inline_markdown(value: object) -> str:
    return " ".join(str(value).splitlines()).replace("`", "'")


def main() -> None:
    if not _PATH:
        return
    try:
        with open(_PATH, encoding="utf-8") as handle:
            data = json.load(handle)
    except (OSError, json.JSONDecodeError):
        return
    for key in _KEYS:
        if key not in data or data[key] is None:
            continue
        value = data[key]
        if isinstance(value, list):
            value = ", ".join(str(item) for item in value)
        print(f"- {key}: `{_safe_inline_markdown(value)}`")


if __name__ == "__main__":
    main()
