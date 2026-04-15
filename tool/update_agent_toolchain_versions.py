#!/usr/bin/env python3
"""Sync Flutter/Dart version markers from README into repo canon and AI adapters."""

from __future__ import annotations

import re
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
README_PATH = PROJECT_ROOT / "README.md"


def _find_toolchain_section(text: str) -> str:
    section_match = re.search(
        r"^### (?:Prerequisites|Toolchain)\s*$\n(?P<body>.*?)(?:^\s*###\s|^\s*##\s|\Z)",
        text,
        flags=re.MULTILINE | re.DOTALL,
    )
    if section_match is not None:
        return section_match.group("body")
    return text


def _extract_version(text: str, label: str) -> str | None:
    patterns = (
        rf"^- {label} `([^`]+)`$",
        rf"{label}\s+`([^`]+)`",
        rf"{label}\s+([0-9]+\.[0-9]+\.[0-9]+)",
    )
    for pattern in patterns:
        match = re.search(pattern, text, flags=re.MULTILINE)
        if match is not None:
            return match.group(1)
    return None


def extract_versions() -> tuple[str, str]:
    text = README_PATH.read_text(encoding="utf-8")
    toolchain_text = _find_toolchain_section(text)
    flutter_version = _extract_version(toolchain_text, "Flutter") or _extract_version(
        text,
        "Flutter",
    )
    dart_version = _extract_version(toolchain_text, "Dart") or _extract_version(
        text,
        "Dart",
    )
    if flutter_version is None or dart_version is None:
        raise SystemExit(
            "Could not extract Flutter/Dart versions from README.md. "
            "The toolchain marker format likely changed; update "
            "tool/update_agent_toolchain_versions.py extraction rules."
        )
    return flutter_version, dart_version


def replace_required(
    path: Path,
    pattern: str,
    replacement: str,
    *,
    count: int = 1,
) -> bool:
    text = path.read_text(encoding="utf-8")
    updated, replacements = re.subn(
        pattern,
        replacement,
        text,
        count=count,
        flags=re.MULTILINE,
    )
    if replacements == 0:
        raise SystemExit(
            f"Expected toolchain marker pattern not found in {path}: {pattern}\n"
            "Hint: the toolchain marker format likely changed; update "
            "tool/update_agent_toolchain_versions.py replacement patterns."
        )
    if updated == text:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def main() -> int:
    flutter_version, dart_version = extract_versions()
    replacements = [
        (
            PROJECT_ROOT / "AGENTS.md",
            r"^(Flutter )\S+ / Dart \S+(\s+·\s+Presentation\s+→\s+Domain\s+←\s+Data\s+·\s+Cubit/BLoC\s+·)$",
            rf"\g<1>{flutter_version} / Dart {dart_version}\g<2>",
        ),
        (
            PROJECT_ROOT / "docs/agents_quick_reference.md",
            r"^Pinned repo toolchain: Flutter \S+ / Dart \S+\.$",
            f"Pinned repo toolchain: Flutter {flutter_version} / Dart {dart_version}.",
        ),
        (
            PROJECT_ROOT / "docs/ai_code_review_protocol.md",
            r"^Pinned repo toolchain: Flutter \S+ / Dart \S+\.$",
            f"Pinned repo toolchain: Flutter {flutter_version} / Dart {dart_version}.",
        ),
        (
            PROJECT_ROOT / "docs/new_developer_guide.md",
            r"^- Flutter `[^`]+`$",
            f"- Flutter `{flutter_version}`",
        ),
        (
            PROJECT_ROOT / "docs/new_developer_guide.md",
            r"^- Dart `[^`]+`$",
            f"- Dart `{dart_version}`",
        ),
        (
            PROJECT_ROOT / "tool/agent_host_templates/codex/skills/flutter-bloc-app-quick-reference/SKILL.md",
            r"^- Flutter \S+ / Dart \S+$",
            f"- Flutter {flutter_version} / Dart {dart_version}",
        ),
        (
            PROJECT_ROOT / "tool/agent_host_templates/cursor/skills/agents-quick-reference/SKILL.md",
            r"^- Flutter \S+ / Dart \S+$",
            f"- Flutter {flutter_version} / Dart {dart_version}",
        ),
    ]

    changed_paths: list[Path] = []
    for path, pattern, replacement in replacements:
        if replace_required(path, pattern, replacement):
            changed_paths.append(path.relative_to(PROJECT_ROOT))

    print(f"Toolchain source: README.md -> Flutter {flutter_version}, Dart {dart_version}")
    if changed_paths:
        print("Updated toolchain markers:")
        for path in changed_paths:
            print(f"- {path}")
    else:
        print("Toolchain markers already up to date.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
