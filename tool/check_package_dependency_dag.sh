#!/usr/bin/env bash
# Enforce Melos workspace package path-dependency DAG under packages/*.
#
# Usage: tool/check_package_dependency_dag.sh
#
# Rules mirror docs/changes/2026-07-03_melos-monorepo-migration-closeout.md (Package dependency DAG).
# App packages (apps/mobile) are not checked here — only workspace library packages.

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"

python3 - "$WORKSPACE_ROOT" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

workspace_root = Path(sys.argv[1])
packages_dir = workspace_root / "packages"

# Allowed path dependency targets per package name (workspace libraries only).
ALLOWED: dict[str, frozenset[str]] = {
    "ai": frozenset({"core", "utilities"}),
    "app_shared_flutter": frozenset({"core"}),
    "auth": frozenset({"core", "utilities"}),
    "core": frozenset(),
    "design_system": frozenset({"app_shared_flutter", "core", "utilities"}),
    "feature_flags": frozenset({"core", "utilities"}),
    "networking": frozenset({"app_shared_flutter", "core", "storage", "utilities"}),
    "storage": frozenset({"app_shared_flutter", "core", "utilities"}),
    "utilities": frozenset({"core"}),
}

FORBIDDEN_TARGET_MARKERS = (
    "apps/",
    "flutter_bloc_app",
)


def package_name(pubspec_path: Path) -> str:
    text = pubspec_path.read_text(encoding="utf-8")
    match = re.search(r"^name:\s*(\S+)", text, re.M)
    if not match:
        raise SystemExit(f"package-dag|fail|missing name in {pubspec_path}")
    return match.group(1)


def dependencies_section(text: str) -> str:
    if "dependencies:" not in text:
        return ""
    after = text.split("dependencies:", 1)[1]
    for stop in ("dev_dependencies:", "dependency_overrides:", "melos:", "flutter:"):
        if stop in after:
            after = after.split(stop, 1)[0]
    return after


def path_dependencies(pubspec_path: Path) -> dict[str, str]:
    section = dependencies_section(pubspec_path.read_text(encoding="utf-8"))
    deps: dict[str, str] = {}
    for key, path in re.findall(
        r"^  (\w+):\n    path:\s*(\S+)",
        section,
        re.M,
    ):
        deps[key] = path
    return deps


def resolve_target(dep_path: str, from_pkg: Path) -> str | None:
    resolved = (from_pkg.parent / dep_path).resolve()
    pubspec = resolved / "pubspec.yaml"
    if not pubspec.is_file():
        return None
    return package_name(pubspec)


errors: list[str] = []
graph: dict[str, set[str]] = {}

if not packages_dir.is_dir():
    print("package-dag|skip|no packages/ directory")
    raise SystemExit(0)

for pubspec in sorted(packages_dir.glob("*/pubspec.yaml")):
    name = package_name(pubspec)
    allowed = ALLOWED.get(name)
    if allowed is None:
        errors.append(
            f"{name}: unlisted in ALLOWED map — update check_package_dependency_dag.sh"
        )
        continue

    deps = path_dependencies(pubspec)
    graph[name] = set()

    for dep_name, dep_path in deps.items():
        for marker in FORBIDDEN_TARGET_MARKERS:
            if marker in dep_path or dep_name == "flutter_bloc_app":
                errors.append(f"{name}: forbidden path dependency {dep_name} -> {dep_path}")
        target = resolve_target(dep_path, pubspec)
        if target is None:
            if dep_path.startswith("../") and "packages" not in Path(dep_path).parts:
                errors.append(
                    f"{name}: path dependency {dep_name} -> {dep_path} resolves outside packages/"
                )
            continue
        graph[name].add(target)
        if target not in allowed:
            errors.append(
                f"{name}: disallowed dependency on {target} "
                f"(allowed: {sorted(allowed) or ['(none)']})"
            )

visiting: set[str] = set()
visited: set[str] = set()


def dfs(node: str) -> None:
    if node in visiting:
        errors.append(f"cycle detected involving {node}")
        return
    if node in visited:
        return
    visiting.add(node)
    for nxt in graph.get(node, ()):
        dfs(nxt)
    visiting.remove(node)
    visited.add(node)


for node in graph:
    dfs(node)

if errors:
    print("package-dag|fail")
    for err in errors:
        print(f"  - {err}")
    raise SystemExit(1)

print("package-dag|pass|packages verified")
PY
