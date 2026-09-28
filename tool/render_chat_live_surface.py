#!/usr/bin/env python3
"""Validate Render/FastAPI chat live OpenAPI surface paths.

Used by ``tool/check_render_chat_live_surface.sh`` (operator / post-deploy smoke).
Offline unit tests import ``required_paths_missing``.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections.abc import Iterable, Mapping, Sequence
from typing import Any

# W12+ contract: liveness, readiness/provenance, chat completions.
REQUIRED_OPENAPI_PATHS: tuple[str, ...] = (
    "/health",
    "/ready",
    "/v1/chat/completions",
)


def normalize_path(path: str) -> str:
    """Normalize an OpenAPI path key for comparison."""
    text = path.strip()
    if not text:
        return text
    if not text.startswith("/"):
        text = f"/{text}"
    if len(text) > 1 and text.endswith("/"):
        text = text.rstrip("/")
    return text


def openapi_paths(document: Mapping[str, Any]) -> set[str]:
    """Return normalized path keys from an OpenAPI document."""
    raw = document.get("paths")
    if not isinstance(raw, Mapping):
        return set()
    return {normalize_path(str(key)) for key in raw}


def required_paths_missing(
    document: Mapping[str, Any],
    required: Sequence[str] = REQUIRED_OPENAPI_PATHS,
) -> list[str]:
    """Return required paths absent from the OpenAPI document (stable order)."""
    present = openapi_paths(document)
    missing: list[str] = []
    for path in required:
        normalized = normalize_path(path)
        if normalized not in present:
            missing.append(normalized)
    return missing


def load_openapi_json(text: str) -> Mapping[str, Any]:
    """Parse OpenAPI JSON text into a mapping."""
    data = json.loads(text)
    if not isinstance(data, Mapping):
        raise ValueError("OpenAPI root must be a JSON object")
    return data


def format_report(
    *,
    origin: str,
    present: Iterable[str],
    missing: Sequence[str],
) -> str:
    """Human-readable pass/fail report."""
    lines = [
        f"origin: {origin.rstrip('/')}",
        f"present: {', '.join(sorted(present)) or '(none)'}",
    ]
    if missing:
        lines.append(f"missing required: {', '.join(missing)}")
        lines.append(
            "fail: live OpenAPI does not expose the W12+ chat surface "
            "(/health, /ready, /v1/chat/completions). Redeploy tip "
            "`demos/render_chat_api` to the target, then re-run."
        )
    else:
        lines.append("ok: required OpenAPI paths present")
    return "\n".join(lines)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate that a Render/FastAPI chat OpenAPI document exposes "
            "required live surface paths."
        )
    )
    parser.add_argument(
        "--origin",
        default="https://render-chat-api.fastapicloud.dev",
        help="Origin label for the report (default: FastAPI Cloud canonical)",
    )
    parser.add_argument(
        "openapi_json",
        nargs="?",
        help="Path to openapi.json (default: stdin)",
    )
    args = parser.parse_args(list(argv) if argv is not None else None)

    if args.openapi_json:
        with open(args.openapi_json, encoding="utf-8") as handle:
            text = handle.read()
    else:
        text = sys.stdin.read()

    try:
        document = load_openapi_json(text)
    except (json.JSONDecodeError, ValueError) as exc:
        print(f"error: invalid OpenAPI JSON: {exc}", file=sys.stderr)
        return 2

    present = sorted(openapi_paths(document))
    missing = required_paths_missing(document)
    print(format_report(origin=args.origin, present=present, missing=missing))
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
