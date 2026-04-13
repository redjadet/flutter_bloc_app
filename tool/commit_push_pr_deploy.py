#!/usr/bin/env python3
"""Plan or execute pre-commit remote deploys for `/commit-push-pr`."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


PROJECT_ROOT = Path(__file__).resolve().parents[1]
TOOL_ROOT = PROJECT_ROOT / "tool"
if str(TOOL_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOL_ROOT))

import validation_reuse


SUPABASE_NO_VERIFY_JWT_FUNCTIONS = {
    "sync-chart-trending",
    "sync-graphql-countries",
}
DEPLOY_COMMANDS = {
    "supabase": "deploy_supabase",
    "firebase": "deploy_firebase",
    "fastapi_cloud": "deploy_fastapi_cloud",
}
FASTAPI_CLOUD_DEPLOY_SCRIPT = PROJECT_ROOT / "tool" / "deploy_fastapi_cloud_chat_api.sh"
RENDER_DEPLOY_TRIGGER_SCRIPT = PROJECT_ROOT / "tool" / "trigger_render_chat_api_deploy.sh"


@dataclass(frozen=True)
class DeployTarget:
    platform: str
    command_name: str
    reason: str
    commands: tuple[str, ...]
    staged_files: tuple[str, ...]
    blocking_files: tuple[str, ...]
    deploy_fingerprint: str
    already_deployed: bool


def _run_git(*args: str) -> list[str]:
    result = subprocess.run(
        ["git", "-C", str(PROJECT_ROOT), *args, "-z"],
        check=True,
        capture_output=True,
        text=True,
    )
    return [part for part in result.stdout.split("\0") if part]


def _git_branch() -> str:
    result = subprocess.run(
        ["git", "-C", str(PROJECT_ROOT), "rev-parse", "--abbrev-ref", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def _git_head() -> str:
    result = subprocess.run(
        ["git", "-C", str(PROJECT_ROOT), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def _staged_files() -> list[str]:
    return _run_git("diff", "--cached", "--name-only")


def _unstaged_files() -> list[str]:
    return _run_git("diff", "--name-only")


def _untracked_files() -> list[str]:
    return _run_git("ls-files", "--others", "--exclude-standard")


def _all_supabase_function_names() -> list[str]:
    functions_root = PROJECT_ROOT / "supabase" / "functions"
    if not functions_root.exists():
        return []
    return sorted(
        child.name for child in functions_root.iterdir() if child.is_dir() and not child.name.startswith(".")
    )


def _hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _staged_entries_for_paths(paths: Iterable[str]) -> list[dict[str, str]]:
    path_list = sorted(set(paths))
    if not path_list:
        return []

    result = subprocess.run(
        ["git", "-C", str(PROJECT_ROOT), "diff", "--cached", "--name-status", "-M", "HEAD", "--", *path_list],
        check=True,
        capture_output=True,
        text=True,
    )
    entries: list[dict[str, str]] = []
    for line in result.stdout.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        status = parts[0]
        kind = status[0]
        if kind == "R" and len(parts) >= 3:
            old_path, new_path = parts[1], parts[2]
            entries.append({"path": old_path, "status": "deleted", "hash": ""})
            new_full_path = PROJECT_ROOT / new_path
            entries.append(
                {
                    "path": new_path,
                    "status": "renamed",
                    "hash": _hash_file(new_full_path) if new_full_path.exists() else "",
                }
            )
            continue

        if len(parts) < 2:
            continue
        path = parts[1]
        full_path = PROJECT_ROOT / path
        if kind == "D" or not full_path.exists():
            entries.append({"path": path, "status": "deleted", "hash": ""})
            continue
        entries.append(
            {
                "path": path,
                "status": kind,
                "hash": _hash_file(full_path),
            }
        )
    return entries


def _compute_deploy_fingerprint(paths: Iterable[str]) -> str:
    payload = {
        "head": _git_head(),
        "entries": sorted(
            _staged_entries_for_paths(paths),
            key=lambda item: (item["path"], item["status"], item["hash"]),
        ),
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _is_supabase_deploy_file(path: str) -> bool:
    return (
        path.startswith("supabase/migrations/")
        or path.startswith("supabase/functions/")
        or path == "supabase/config.toml"
    )


def _is_firebase_deploy_file(path: str) -> bool:
    if path in {"firebase.json", "firestore.rules", "firestore.indexes.json"}:
        return True
    if not path.startswith("functions/"):
        return False
    relative = path.removeprefix("functions/")
    return not (
        relative == "README.md"
        or relative.startswith("test/")
        or relative.startswith("tool/")
        or relative.startswith("node_modules/")
    )


def _is_fastapi_cloud_deploy_file(path: str) -> bool:
    if not path.startswith("demos/render_chat_api/"):
        return False
    relative = path.removeprefix("demos/render_chat_api/")
    return not (
        relative == "README.md"
        or relative.startswith("README")
        or relative.startswith(".fastapicloud/")
        or relative.startswith(".venv/")
        or relative.startswith("tests/")
        or relative.endswith("_test.py")
        or relative.endswith("_test.sh")
    )


def _changed_supabase_functions(paths: Iterable[str]) -> list[str]:
    names = {
        path.split("/", 3)[2]
        for path in paths
        if path.startswith("supabase/functions/") and len(path.split("/", 3)) >= 3
    }
    return sorted(name for name in names if name)


def _supabase_commands(staged_files: list[str]) -> tuple[str, ...]:
    commands: list[str] = []
    if any(path.startswith("supabase/migrations/") for path in staged_files):
        commands.append("npx supabase db push")

    function_names = _changed_supabase_functions(staged_files)
    if "supabase/config.toml" in staged_files and not function_names:
        function_names = _all_supabase_function_names()

    for name in function_names:
        extra = " --no-verify-jwt" if name in SUPABASE_NO_VERIFY_JWT_FUNCTIONS else ""
        commands.append(f"npx supabase functions deploy {name}{extra}")

    return tuple(commands)


def _firebase_commands(staged_files: list[str]) -> tuple[str, ...]:
    commands: list[str] = []
    if any(path.startswith("functions/") for path in staged_files):
        commands.append("npm --prefix functions run deploy")
    if "firestore.rules" in staged_files:
        commands.append("firebase deploy --only firestore:rules")
    if "firestore.indexes.json" in staged_files:
        commands.append("firebase deploy --only firestore:indexes")
    return tuple(commands)


def _fastapi_cloud_commands(staged_files: list[str]) -> tuple[str, ...]:
    if not any(_is_fastapi_cloud_deploy_file(path) for path in staged_files):
        return ()
    if FASTAPI_CLOUD_DEPLOY_SCRIPT.exists():
        return ("./tool/deploy_fastapi_cloud_chat_api.sh",)
    if RENDER_DEPLOY_TRIGGER_SCRIPT.exists():
        return ("./tool/trigger_render_chat_api_deploy.sh",)
    return ()


def _build_target(
    *,
    platform: str,
    relevant_predicate,
    command_builder,
    staged: list[str],
    unstaged: list[str],
    untracked: list[str],
    branch: str,
) -> DeployTarget | None:
    staged_files = sorted(path for path in staged if relevant_predicate(path))
    if not staged_files:
        return None

    commands = command_builder(staged_files)
    if not commands:
        return None

    blocking_files = sorted(
        path for path in [*unstaged, *untracked] if relevant_predicate(path)
    )
    command_name = DEPLOY_COMMANDS[platform]
    deploy_fingerprint = _compute_deploy_fingerprint(staged_files)
    already_deployed = (
        validation_reuse.find_successful_command_event(
            command_name,
            fingerprint=deploy_fingerprint,
            branch=branch,
        )
        is not None
    )
    return DeployTarget(
        platform=platform,
        command_name=command_name,
        reason=", ".join(staged_files),
        commands=commands,
        staged_files=tuple(staged_files),
        blocking_files=tuple(blocking_files),
        deploy_fingerprint=deploy_fingerprint,
        already_deployed=already_deployed,
    )


def build_plan(
    *,
    staged: list[str],
    unstaged: list[str],
    untracked: list[str],
    branch: str,
) -> list[DeployTarget]:
    targets = [
        _build_target(
            platform="supabase",
            relevant_predicate=_is_supabase_deploy_file,
            command_builder=_supabase_commands,
            staged=staged,
            unstaged=unstaged,
            untracked=untracked,
            branch=branch,
        ),
        _build_target(
            platform="firebase",
            relevant_predicate=_is_firebase_deploy_file,
            command_builder=_firebase_commands,
            staged=staged,
            unstaged=unstaged,
            untracked=untracked,
            branch=branch,
        ),
        _build_target(
            platform="fastapi_cloud",
            relevant_predicate=_is_fastapi_cloud_deploy_file,
            command_builder=_fastapi_cloud_commands,
            staged=staged,
            unstaged=unstaged,
            untracked=untracked,
            branch=branch,
        ),
    ]
    return [target for target in targets if target is not None]


def _emit_event(command_name: str, status: str, fingerprint: str) -> None:
    subprocess.run(
        [
            str(PROJECT_ROOT / "tool" / "emit_agent_scorecard_event.sh"),
            "--command",
            command_name,
            "--status",
            status,
            "--workspace-fingerprint",
            fingerprint,
        ],
        check=True,
        cwd=PROJECT_ROOT,
    )


def _print_text_plan(targets: list[DeployTarget], branch: str) -> None:
    print(f"branch={branch}")
    if not targets:
        print("deploys=none")
        return
    for target in targets:
        print(f"[{target.platform}]")
        print(f"command_name={target.command_name}")
        print(f"already_deployed={'yes' if target.already_deployed else 'no'}")
        print(f"deploy_fingerprint={target.deploy_fingerprint}")
        print(f"staged={','.join(target.staged_files)}")
        if target.blocking_files:
            print(f"blocking={','.join(target.blocking_files)}")
        for command in target.commands:
            print(f"run={command}")


def _plan_command(args: argparse.Namespace) -> int:
    branch = _git_branch()
    targets = build_plan(
        staged=_staged_files(),
        unstaged=_unstaged_files(),
        untracked=_untracked_files(),
        branch=branch,
    )
    if args.json:
        print(
            json.dumps(
                {
                    "branch": branch,
                    "targets": [asdict(target) for target in targets],
                },
                indent=2,
            )
        )
    else:
        _print_text_plan(targets, branch)
    return 0


def _execute_command(_: argparse.Namespace) -> int:
    branch = _git_branch()
    targets = build_plan(
        staged=_staged_files(),
        unstaged=_unstaged_files(),
        untracked=_untracked_files(),
        branch=branch,
    )
    blocking = [target for target in targets if target.blocking_files]
    if blocking:
        for target in blocking:
            joined = ", ".join(target.blocking_files)
            print(
                f"{target.platform}: deploy-relevant unstaged files block deploy: {joined}",
                file=sys.stderr,
            )
        return 2

    for target in targets:
        if target.already_deployed:
            print(
                f"{target.platform}: already deployed for branch={branch} "
                f"deploy_fingerprint={target.deploy_fingerprint}; skipping"
            )
            continue

        try:
            for command in target.commands:
                print(f"{target.platform}: {command}")
                subprocess.run(command, check=True, cwd=PROJECT_ROOT, shell=True)
        except subprocess.CalledProcessError:
            _emit_event(target.command_name, "failed", target.deploy_fingerprint)
            return 1

        _emit_event(target.command_name, "ok", target.deploy_fingerprint)
        print(
            f"{target.platform}: recorded {target.command_name} "
            f"for deploy_fingerprint={target.deploy_fingerprint}"
        )

    if not targets:
        print("No remote deploy required for the staged worktree.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    plan_parser = subparsers.add_parser("plan")
    plan_parser.add_argument("--json", action="store_true")
    plan_parser.set_defaults(func=_plan_command)

    execute_parser = subparsers.add_parser("execute")
    execute_parser.set_defaults(func=_execute_command)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
