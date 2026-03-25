#!/usr/bin/env python3
"""Helpers for reusing successful validation runs on the same worktree state."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from typing import Iterable


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCORECARD_ROOT = PROJECT_ROOT / "analysis" / "agent_scorecard"
SCORECARD_FILE = SCORECARD_ROOT / "scorecard-events.jsonl"
ARCHIVE_DIR = SCORECARD_ROOT / "archive"
IGNORED_FINGERPRINT_PATHS = (
    "analysis/agent_scorecard/scorecard-events.jsonl",
    "analysis/agent_scorecard/scorecard-events-",
    "analysis/agent_scorecard/archive/",
    "analysis/agent_scorecard/summaries/",
)


def _should_ignore_fingerprint_path(path: str) -> bool:
    normalized = path.replace("\\", "/")
    return any(normalized.startswith(prefix) for prefix in IGNORED_FINGERPRINT_PATHS)


def _run_git(*args: str, check: bool = True) -> str:
    result = subprocess.run(
        ["git", "-C", str(PROJECT_ROOT), *args],
        check=check,
        capture_output=True,
        text=True,
    )
    return result.stdout


def _git_head() -> str:
    try:
        return _run_git("rev-parse", "HEAD").strip()
    except subprocess.CalledProcessError:
        return "NO_HEAD"


def _git_branch() -> str:
    try:
        return _run_git("rev-parse", "--abbrev-ref", "HEAD").strip()
    except subprocess.CalledProcessError:
        return "unknown"


def _hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _tracked_entries() -> list[dict[str, str]]:
    output = _run_git("diff", "--name-status", "-M", "HEAD", "--")
    entries: list[dict[str, str]] = []
    for line in output.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        status = parts[0]
        kind = status[0]
        if kind == "R" and len(parts) >= 3:
            old_path = parts[1]
            new_path = parts[2]
            if _should_ignore_fingerprint_path(old_path) and _should_ignore_fingerprint_path(new_path):
                continue
            entries.append({"path": old_path, "status": "deleted", "hash": ""})
            if _should_ignore_fingerprint_path(new_path):
                continue
            full_new_path = PROJECT_ROOT / new_path
            entries.append(
                {
                    "path": new_path,
                    "status": "renamed",
                    "hash": _hash_file(full_new_path),
                },
            )
            continue

        if len(parts) < 2:
            continue
        path = parts[1]
        if _should_ignore_fingerprint_path(path):
            continue
        full_path = PROJECT_ROOT / path
        if kind == "D" or not full_path.exists():
            entries.append({"path": path, "status": "deleted", "hash": ""})
            continue
        entries.append(
            {
                "path": path,
                "status": kind,
                "hash": _hash_file(full_path),
            },
        )
    return entries


def _untracked_entries() -> list[dict[str, str]]:
    output = _run_git("ls-files", "--others", "--exclude-standard", "-z")
    entries: list[dict[str, str]] = []
    for raw_path in output.split("\0"):
        if not raw_path:
            continue
        if _should_ignore_fingerprint_path(raw_path):
            continue
        path = PROJECT_ROOT / raw_path
        if not path.exists():
            continue
        entries.append(
            {
                "path": raw_path,
                "status": "untracked",
                "hash": _hash_file(path),
            },
        )
    return entries


def compute_workspace_fingerprint() -> str:
    payload = {
        "head": _git_head(),
        "entries": sorted(
            [*_tracked_entries(), *_untracked_entries()],
            key=lambda item: (item["path"], item["status"], item["hash"]),
        ),
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode(
        "utf-8"
    )
    return hashlib.sha256(encoded).hexdigest()


def _scorecard_files() -> Iterable[Path]:
    if SCORECARD_FILE.exists():
        yield SCORECARD_FILE
    if SCORECARD_ROOT.exists():
        for path in sorted(SCORECARD_ROOT.glob("scorecard-events-*.jsonl")):
            yield path
    if ARCHIVE_DIR.exists():
        for path in sorted(ARCHIVE_DIR.glob("scorecard-events-*.jsonl.gz")):
            yield path


def _iter_scorecard_events() -> Iterable[dict[str, object]]:
    for path in _scorecard_files():
        if path.suffix == ".gz":
            with gzip.open(path, "rt", encoding="utf-8") as handle:
                lines = handle.readlines()
        else:
            lines = path.read_text(encoding="utf-8").splitlines()
        for line in lines:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if isinstance(event, dict):
                yield event


def _pass_field_for(command: str) -> str:
    if command == "checklist":
        return "checklist_pass"
    if command == "integration_tests":
        return "integration_pass"
    if command == "router_feature_validate":
        return "router_validate_pass"
    raise SystemExit(f"Unsupported command: {command}")


def find_reusable_run(command: str) -> dict[str, object] | None:
    fingerprint = compute_workspace_fingerprint()
    branch = _git_branch()
    pass_field = _pass_field_for(command)
    matches: list[dict[str, object]] = []
    for event in _iter_scorecard_events():
        if event.get("command") != command:
            continue
        if event.get("status") != "ok":
            continue
        if event.get(pass_field) is not True:
            continue
        if event.get("invalid_partial") is True:
            continue
        if event.get("branch") != branch:
            continue
        if event.get("workspace_fingerprint") != fingerprint:
            continue
        matches.append(event)
    if not matches:
        return None
    matches.sort(key=lambda event: str(event.get("ended_at", "")), reverse=True)
    return matches[0]


def _fingerprint_command(_: argparse.Namespace) -> int:
    print(compute_workspace_fingerprint())
    return 0


def _find_command(args: argparse.Namespace) -> int:
    match = find_reusable_run(args.command)
    if match is None:
        return 1
    print(json.dumps(match, ensure_ascii=True))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    fingerprint_parser = subparsers.add_parser("fingerprint")
    fingerprint_parser.set_defaults(func=_fingerprint_command)

    find_parser = subparsers.add_parser("find")
    find_parser.add_argument(
        "--command",
        required=True,
        choices=["checklist", "integration_tests", "router_feature_validate"],
    )
    find_parser.set_defaults(func=_find_command)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
