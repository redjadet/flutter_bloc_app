#!/bin/bash
# Fail fast on known-incompatible pubspec combos that break build_runner/codegen.
#
# Primary guardrail:
# - json_serializable has hard analyzer API requirements.
# - Path analyzer plugins (mix_lint, file_length_lint) use analysis_server_plugin on analyzer 10 via overrides.
#
# Keep this check cheap: parse pubspec.yaml (and pubspec.lock when present), no `pub get`.

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PUBSPEC="$APP_ROOT/pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "pubspec-compat|skip|missing pubspec.yaml"
  exit 0
fi

python3 - "$PUBSPEC" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Literal

pubspec_path = Path(sys.argv[1])
lock_path = pubspec_path.with_name("pubspec.lock")
text = pubspec_path.read_text(encoding="utf-8")


ROOT_SECTIONS = {
    "dependencies",
    "dev_dependencies",
    "dependency_overrides",
}


def _strip_comment(value: str) -> str:
    return value.split("#", 1)[0].strip()


def _read_root_pubspec_scalars(pubspec_text: str) -> dict[str, dict[str, str]]:
    sections: dict[str, dict[str, str]] = {name: {} for name in ROOT_SECTIONS}
    current_section: str | None = None

    for raw_line in pubspec_text.splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue

        root_match = re.match(r"^([A-Za-z0-9_]+):\s*(.*)$", raw_line)
        if root_match:
            section = root_match.group(1)
            current_section = section if section in ROOT_SECTIONS else None
            continue

        if current_section is None:
            continue

        dep_match = re.match(r"^[ \t]{2}([A-Za-z0-9_]+):[ \t]*([^\n]*)$", raw_line)
        if not dep_match:
            continue

        key = dep_match.group(1)
        value = _strip_comment(dep_match.group(2))
        if value:
            sections[current_section][key] = value

    return sections


pubspec_sections = _read_root_pubspec_scalars(text)


def _find_scalar(
    key: str,
    *,
    section_order: tuple[
        Literal["dependency_overrides", "dev_dependencies", "dependencies"], ...
    ] = ("dependency_overrides", "dev_dependencies", "dependencies"),
) -> str | None:
    for section in section_order:
        value = pubspec_sections[section].get(key)
        if value:
            return value
    return None


def _parse_version_min(constraint: str | None) -> tuple[int, int, int] | None:
    if not constraint:
        return None
    # Accept: 6.14.0, ^6.14.0, >=6.14.0 <7.0.0
    m = re.search(r"(\d+)\.(\d+)\.(\d+)", constraint)
    if not m:
        return None
    return int(m.group(1)), int(m.group(2)), int(m.group(3))


def _parse_caret_max(constraint: str | None) -> tuple[int, int, int] | None:
    if not constraint:
        return None
    # Minimal caret parsing for the common case:
    # ^6.11.4 means <7.0.0 (so it could float to 6.14.0).
    c = constraint.strip()
    if not c.startswith("^"):
        return None
    v = _parse_version_min(c)
    if v is None:
        return None
    major, minor, patch = v
    if major > 0:
        return major + 1, 0, 0
    if minor > 0:
        return 0, minor + 1, 0
    return 0, 0, patch + 1


def _required_analyzer_major_for_json_serializable(
    version: tuple[int, int, int] | None,
) -> int | None:
    if version is None:
        return None
    _, minor, _ = version
    if minor >= 13:
        return 10
    if minor >= 12:
        return 9
    return None


def _fmt(v: tuple[int, int, int] | None) -> str:
    return "unknown" if v is None else f"{v[0]}.{v[1]}.{v[2]}"


def _read_lock_versions(lock_text: str) -> dict[str, tuple[int, int, int]]:
    versions: dict[str, tuple[int, int, int]] = {}
    current: str | None = None
    in_packages = False
    for raw in lock_text.splitlines():
        line = raw.rstrip("\n")
        if line == "packages:":
            in_packages = True
            continue
        if not in_packages:
            continue
        # top-level package key: "  name:"
        m = re.match(r"^  ([a-zA-Z0-9_]+):\s*$", line)
        if m:
            current = m.group(1)
            continue
        if current and "version:" in line:
            m = re.search(r'"\s*(\d+)\.(\d+)\.(\d+)\s*"', line)
            if m:
                versions[current] = (int(m.group(1)), int(m.group(2)), int(m.group(3)))
            current = None
    return versions


json_serializable = _find_scalar("json_serializable")
json_annotation = _find_scalar("json_annotation", section_order=("dependencies", "dev_dependencies"))
analyzer_override = _find_scalar("analyzer", section_order=("dependency_overrides", "dev_dependencies"))
mix_lint_present = "mix_lint" in pubspec_sections["dev_dependencies"]
file_length_lint_present = "file_length_lint" in pubspec_sections["dev_dependencies"]

json_serializable_min = _parse_version_min(json_serializable)
json_annotation_min = _parse_version_min(json_annotation)
analyzer_override_min = _parse_version_min(analyzer_override)

# If lockfile exists, prefer resolved versions for extra safety (especially when no analyzer override exists).
lock_versions: dict[str, tuple[int, int, int]] = {}
if lock_path.exists():
    lock_versions = _read_lock_versions(lock_path.read_text(encoding="utf-8"))

json_serializable_resolved = lock_versions.get("json_serializable")
json_annotation_resolved = lock_versions.get("json_annotation")
analyzer_resolved = lock_versions.get("analyzer")

# Version sources:
# - declared constraints: what `pub get` must solve after pubspec changes.
# - resolved lock: what build_runner actually uses today.
analyzer_effective = analyzer_override_min or analyzer_resolved

errors: list[str] = []

for source, js_version in (
    ("declared json_serializable constraint", json_serializable_min),
    ("resolved json_serializable", json_serializable_resolved),
):
    required_analyzer_major = _required_analyzer_major_for_json_serializable(js_version)
    if required_analyzer_major is None or analyzer_effective is None:
        continue
    if analyzer_effective[0] < required_analyzer_major:
        errors.append(
            "incompatible json_serializable/analyzer"
            f" ({source} {_fmt(js_version)} requires analyzer >={required_analyzer_major}.x"
            f" but effective analyzer is {_fmt(analyzer_effective)})"
        )

# json_serializable 6.11.x requires json_annotation <4.10.0 (so ^4.12.0 will fail solver)
for source, js_version, ja_version in (
    ("declared constraints", json_serializable_min, json_annotation_min),
    ("resolved lock", json_serializable_resolved, json_annotation_resolved),
):
    if js_version is not None and ja_version is not None and js_version[:2] <= (6, 11):
        if ja_version[:2] >= (4, 10):
            errors.append(
                "incompatible json_serializable/json_annotation"
                f" ({source}: json_serializable {_fmt(js_version)} requires json_annotation <4.10.0"
                f" but json_annotation is {_fmt(ja_version)})"
            )

if (
    json_serializable_min is not None
    and json_serializable_resolved is not None
    and json_serializable_min[:2] >= (6, 12)
    and json_serializable_resolved[:2] <= (6, 11)
):
    errors.append(
        "stale lock risk"
        f" (declared json_serializable {_fmt(json_serializable_min)} is analyzer-stricter"
        f" than resolved {_fmt(json_serializable_resolved)}; run pub get after choosing compatible constraints)"
    )

if (
    json_annotation_min is not None
    and json_annotation_resolved is not None
    and json_annotation_min[:2] >= (4, 10)
    and json_annotation_resolved[:2] <= (4, 9)
    and json_serializable_min is not None
    and json_serializable_min[:2] <= (6, 11)
):
    errors.append(
        "stale lock risk"
        f" (declared json_annotation {_fmt(json_annotation_min)} is incompatible with"
        f" json_serializable {_fmt(json_serializable_min)} despite resolved {_fmt(json_annotation_resolved)})"
    )

if (
    json_serializable_min is None
    and json_serializable_resolved is not None
    and analyzer_effective is not None
):
    required_analyzer_major = _required_analyzer_major_for_json_serializable(
        json_serializable_resolved
    )
    if required_analyzer_major is not None and analyzer_effective[0] < required_analyzer_major:
        errors.append(
            "incompatible transitive json_serializable/analyzer"
            f" (resolved json_serializable {_fmt(json_serializable_resolved)} requires analyzer >={required_analyzer_major}.x"
            f" but effective analyzer is {_fmt(analyzer_effective)})"
        )

# Drift guard: caret constraints can float into known-bad zones on `pub upgrade`.
json_serializable_caret_max = _parse_caret_max(json_serializable)
if json_serializable_caret_max is not None and analyzer_effective is not None:
    # If constraint allows any >=6.12 (minor 12+) but analyzer is pinned <9, flag.
    # In practice, ^6.11.x allows 6.14.x.
    if json_serializable_min is not None and json_serializable_min[0] == 6:
        allows_bad = json_serializable_caret_max[0] >= 7  # ^6.x => <7.0.0 includes 6.12+
        if allows_bad and analyzer_effective[0] < 9 and json_serializable_min[1] <= 11:
            errors.append(
                "risk: json_serializable constraint can float to analyzer>=9 requirement"
                f" (json_serializable constraint '{json_serializable}' allows 6.12+ but analyzer is {_fmt(analyzer_effective)})."
                " Pin json_serializable to 6.11.x (exact) or make analyzer/custom_lints compatible with >=9/10."
            )

if errors:
    print("❌ pubspec-compat|fail")
    for e in errors:
        print(f"- {e}")
    print("")
    print("Fix options (pick one coherent set):")
    print("- preferred: json_serializable ^6.14.0 + json_annotation ^4.12.0 + dependency_overrides analyzer 10.0.2, dart_style 3.1.4 + mix_lint 2.x (analysis_server_plugin)")
    print("- legacy: analyzer 8.x + json_serializable 6.11.x + json_annotation ^4.9.0 + custom_lint 0.8.x")
    print("- move analyzer >=10 without overrides: keep mix_lint on analysis_server_plugin; migrate other custom_lints off custom_lint_builder")
    if mix_lint_present or file_length_lint_present:
        print("")
        print(
            "Note: custom analyzer plugins present"
            " (`mix_lint`/`file_length_lint`); upgrade those first if raising analyzer."
        )
    raise SystemExit(1)

print("✅ pubspec-compat|ok")
PY
