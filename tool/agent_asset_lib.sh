#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

agent_templates_root="${AGENT_TEMPLATES_ROOT:-$repo_root/tool/agent_host_templates}"

has_agent_templates() {
  [[ -d "$agent_templates_root" ]]
}

# shellcheck disable=SC2034
managed_cursor_files=(
  "shared/skills/agents-quick-reference/SKILL.md|$HOME/.cursor/skills/agents-quick-reference/SKILL.md"
  "shared/skills/agents-skill-routing/SKILL.md|$HOME/.cursor/skills/agents-skill-routing/SKILL.md"
  "shared/skills/agents-delivery-workflow/SKILL.md|$HOME/.cursor/skills/agents-delivery-workflow/SKILL.md"
  "cursor/skills/agents-meta-behavior/SKILL.md|$HOME/.cursor/skills/agents-meta-behavior/SKILL.md"
  "cursor/skills/agents-cursor-integration/SKILL.md|$HOME/.cursor/skills/agents-cursor-integration/SKILL.md"
  "cursor/skills/agents-global-skills-setup/SKILL.md|$HOME/.cursor/skills/agents-global-skills-setup/SKILL.md"
  "shared/skills/flutter-cross-platform-modern/SKILL.md|$HOME/.cursor/skills/flutter-cross-platform-modern/SKILL.md"
  "shared/skills/brainstorming/SKILL.md|$HOME/.cursor/skills/brainstorming/SKILL.md"
  "shared/skills/systematic-debugging/SKILL.md|$HOME/.cursor/skills/systematic-debugging/SKILL.md"
  "shared/skills/writing-plans/SKILL.md|$HOME/.cursor/skills/writing-plans/SKILL.md"
  "shared/skills/verification-before-completion/SKILL.md|$HOME/.cursor/skills/verification-before-completion/SKILL.md"
  "shared/skills/test-driven-development/SKILL.md|$HOME/.cursor/skills/test-driven-development/SKILL.md"
  "shared/skills/caveman-compress/SKILL.md|$HOME/.cursor/skills/caveman-compress/SKILL.md"
  "cursor/skills/upgrade-pr-triage-validate/SKILL.md|$HOME/.cursor/skills/upgrade-pr-triage-validate/SKILL.md"
  "shared/skills/agents-repo-context/SKILL.md|$HOME/.cursor/skills/agents-repo-context/SKILL.md"
  "shared/skills/agents-principles-baseline/SKILL.md|$HOME/.cursor/skills/agents-principles-baseline/SKILL.md"
  "shared/skills/agents-references/SKILL.md|$HOME/.cursor/skills/agents-references/SKILL.md"
  "shared/skills/agents-canonical-rules/SKILL.md|$HOME/.cursor/skills/agents-canonical-rules/SKILL.md"
  "shared/skills/agents-canonical-rules-architecture/SKILL.md|$HOME/.cursor/skills/agents-canonical-rules-architecture/SKILL.md"
  "shared/skills/agents-canonical-rules-presentation/SKILL.md|$HOME/.cursor/skills/agents-canonical-rules-presentation/SKILL.md"
  "shared/skills/agents-canonical-rules-async/SKILL.md|$HOME/.cursor/skills/agents-canonical-rules-async/SKILL.md"
  "shared/skills/agents-canonical-rules-platform/SKILL.md|$HOME/.cursor/skills/agents-canonical-rules-platform/SKILL.md"
  "shared/skills/agents-feature-delivery/SKILL.md|$HOME/.cursor/skills/agents-feature-delivery/SKILL.md"
  "shared/skills/agents-bloc-standards/SKILL.md|$HOME/.cursor/skills/agents-bloc-standards/SKILL.md"
  "shared/skills/agents-create-cubit/SKILL.md|$HOME/.cursor/skills/agents-create-cubit/SKILL.md"
  "shared/skills/agents-validation-testing/SKILL.md|$HOME/.cursor/skills/agents-validation-testing/SKILL.md"
  "shared/skills/agents-common-pitfalls/SKILL.md|$HOME/.cursor/skills/agents-common-pitfalls/SKILL.md"
  "shared/skills/agents-figma/SKILL.md|$HOME/.cursor/skills/agents-figma/SKILL.md"
  "shared/skills/figma-this-repo/SKILL.md|$HOME/.cursor/skills/figma-this-repo/SKILL.md"
  "shared/skills/agents-modularity/SKILL.md|$HOME/.cursor/skills/agents-modularity/SKILL.md"
  "shared/skills/agents-shared-patterns/SKILL.md|$HOME/.cursor/skills/agents-shared-patterns/SKILL.md"
  "shared/skills/agents-supabase/SKILL.md|$HOME/.cursor/skills/agents-supabase/SKILL.md"
  "cursor/commands/commit-push-pr.md|$HOME/.cursor/commands/commit-push-pr.md"
  "cursor/commands/local-agents-quick-reference.md|$HOME/.cursor/commands/local-agents-quick-reference.md"
  "cursor/commands/upgrade-validate-all.md|$HOME/.cursor/commands/upgrade-validate-all.md"
  "cursor/commands/codex-feedback.md|$HOME/.cursor/commands/codex-feedback.md"
  "cursor/commands/setup-cursor-agent-environment.md|$HOME/.cursor/commands/setup-cursor-agent-environment.md"
  "cursor/commands/agent-maintain.md|$HOME/.cursor/commands/agent-maintain.md"
  "cursor/commands/hot-reload.md|$HOME/.cursor/commands/hot-reload.md"
  "cursor/rules/agents-global.mdc|$HOME/.cursor/rules/agents-global.mdc"
  "cursor/rules/design-system.mdc|$HOME/.cursor/rules/design-system.mdc"
  "cursor/rules/agent-auto-hot-reload.mdc|$HOME/.cursor/rules/agent-auto-hot-reload.mdc"
)

# shellcheck disable=SC2034
managed_codex_files=(
  "__repo_root__/AGENTS.md|$HOME/.codex/AGENTS.md"
  "shared/skills/agents-quick-reference/SKILL.md|$HOME/.codex/skills/flutter-bloc-app-quick-reference/SKILL.md"
  "shared/skills/agents-skill-routing/SKILL.md|$HOME/.codex/skills/flutter-bloc-app-skill-routing/SKILL.md"
  "shared/skills/agents-delivery-workflow/SKILL.md|$HOME/.codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md"
  "shared/skills/flutter-cross-platform-modern/SKILL.md|$HOME/.codex/skills/flutter-cross-platform-modern/SKILL.md"
  "shared/skills/agents-repo-context/SKILL.md|$HOME/.codex/skills/agents-repo-context/SKILL.md"
  "shared/skills/agents-principles-baseline/SKILL.md|$HOME/.codex/skills/agents-principles-baseline/SKILL.md"
  "shared/skills/agents-references/SKILL.md|$HOME/.codex/skills/agents-references/SKILL.md"
  "shared/skills/agents-canonical-rules/SKILL.md|$HOME/.codex/skills/agents-canonical-rules/SKILL.md"
  "shared/skills/agents-canonical-rules-architecture/SKILL.md|$HOME/.codex/skills/agents-canonical-rules-architecture/SKILL.md"
  "shared/skills/agents-canonical-rules-presentation/SKILL.md|$HOME/.codex/skills/agents-canonical-rules-presentation/SKILL.md"
  "shared/skills/agents-canonical-rules-async/SKILL.md|$HOME/.codex/skills/agents-canonical-rules-async/SKILL.md"
  "shared/skills/agents-canonical-rules-platform/SKILL.md|$HOME/.codex/skills/agents-canonical-rules-platform/SKILL.md"
  "shared/skills/agents-feature-delivery/SKILL.md|$HOME/.codex/skills/agents-feature-delivery/SKILL.md"
  "shared/skills/agents-bloc-standards/SKILL.md|$HOME/.codex/skills/agents-bloc-standards/SKILL.md"
  "shared/skills/agents-create-cubit/SKILL.md|$HOME/.codex/skills/agents-create-cubit/SKILL.md"
  "shared/skills/agents-validation-testing/SKILL.md|$HOME/.codex/skills/agents-validation-testing/SKILL.md"
  "shared/skills/agents-common-pitfalls/SKILL.md|$HOME/.codex/skills/agents-common-pitfalls/SKILL.md"
  "shared/skills/agents-modularity/SKILL.md|$HOME/.codex/skills/agents-modularity/SKILL.md"
  "shared/skills/agents-shared-patterns/SKILL.md|$HOME/.codex/skills/agents-shared-patterns/SKILL.md"
  "shared/skills/agents-figma/SKILL.md|$HOME/.codex/skills/agents-figma/SKILL.md"
  "shared/skills/figma-this-repo/SKILL.md|$HOME/.codex/skills/figma-this-repo/SKILL.md"
  "shared/skills/agents-supabase/SKILL.md|$HOME/.codex/skills/agents-supabase/SKILL.md"
  "shared/skills/brainstorming/SKILL.md|$HOME/.codex/skills/brainstorming/SKILL.md"
  "shared/skills/systematic-debugging/SKILL.md|$HOME/.codex/skills/systematic-debugging/SKILL.md"
  "shared/skills/writing-plans/SKILL.md|$HOME/.codex/skills/writing-plans/SKILL.md"
  "shared/skills/verification-before-completion/SKILL.md|$HOME/.codex/skills/verification-before-completion/SKILL.md"
  "shared/skills/test-driven-development/SKILL.md|$HOME/.codex/skills/test-driven-development/SKILL.md"
  "shared/skills/caveman-compress/SKILL.md|$HOME/.codex/skills/caveman-compress/SKILL.md"
)

managed_codex_rules_template="codex/rules/flutter_bloc_app_default.rules"
managed_codex_rules_target="$HOME/.codex/rules/default.rules"

required_toolchain_targets=(
  "README.md"
  "docs/new_developer_guide.md"
  "docs/ai_code_review_protocol.md"
)

optional_local_policy_targets=(
  "AGENTS.md"
  "docs/agents_quick_reference.md"
)

agent_asset_source_path() {
  local src_rel="$1"
  case "$src_rel" in
    __repo_root__/*)
      printf '%s/%s\n' "$repo_root" "${src_rel#__repo_root__/}"
      ;;
    *)
      printf '%s/%s\n' "$agent_templates_root" "$src_rel"
      ;;
  esac
}

list_optional_codex_worktree_agent_targets() {
  local repo_name
  local target
  repo_name="$(basename "$repo_root")"
  shopt -s nullglob
  for target in "$HOME"/.codex/worktrees/*/"$repo_name"/AGENTS.md; do
    printf '%s\n' "$target"
  done
  shopt -u nullglob
}

require_agent_asset_runtime() {
  local missing=0
  local tool_name

  for tool_name in python3 mktemp; do
    if ! command -v "$tool_name" >/dev/null 2>&1; then
      echo "missing-runtime|$tool_name"
      missing=1
    fi
  done

  if (( missing != 0 )); then
    return 1
  fi
}

copy_file_if_needed() {
  local src_rel="$1"
  local dst="$2"
  local src
  src="$(agent_asset_source_path "$src_rel")"

  if [[ ! -f "$src" ]]; then
    echo "missing-source|$src"
    return 1
  fi

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    echo "ok|$dst"
    return 0
  fi

  echo "update|$dst"
  return 0
}

apply_copy_file() {
  local src_rel="$1"
  local dst="$2"
  local src
  src="$(agent_asset_source_path "$src_rel")"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

extract_readme_toolchain() {
  python3 - "$repo_root/README.md" <<'PY'
import re
import sys

VERSION_TOKEN_PATTERN = r"[0-9]+(?:\.[0-9]+){2}(?:[-+][0-9A-Za-z.-]+)?"
readme_path = sys.argv[1]
text = open(readme_path, encoding="utf-8").read()


def find_toolchain_section(source: str) -> str:
    section_match = re.search(
        r"^### (?:Prerequisites|Toolchain)\s*$\n(?P<body>.*?)(?:^\s*###\s|^\s*##\s|\Z)",
        source,
        flags=re.MULTILINE | re.DOTALL,
    )
    if section_match is not None:
        return section_match.group("body")
    return source


def extract_version(source: str, label: str) -> str | None:
    patterns = (
        rf"^- {label} `([^`]+)`$",
        rf"{label}\s+`([^`]+)`",
        rf"{label}\s+({VERSION_TOKEN_PATTERN})",
        rf"badge/{label}-({VERSION_TOKEN_PATTERN})-",
    )
    for pattern in patterns:
        match = re.search(pattern, source, flags=re.MULTILINE)
        if match is not None:
            return match.group(1)
    return None


toolchain_text = find_toolchain_section(text)
flutter_version = extract_version(toolchain_text, "Flutter") or extract_version(
    text,
    "Flutter",
)
dart_version = extract_version(toolchain_text, "Dart") or extract_version(text, "Dart")
if flutter_version is None or dart_version is None:
    raise SystemExit(1)
print(f"{flutter_version}|{dart_version}")
PY
}

check_toolchain_mentions() {
  local versions target text flutter dart
  if ! versions="$(extract_readme_toolchain)"; then
    echo "toolchain-drift|$repo_root/README.md|could not extract Flutter/Dart versions"
    return 1
  fi
  flutter="${versions%%|*}"
  dart="${versions##*|}"
  if [[ -z "$flutter" || -z "$dart" ]]; then
    echo "toolchain-drift|$repo_root/README.md|empty Flutter/Dart version after extraction"
    return 1
  fi

  for target in "${required_toolchain_targets[@]}"; do
    text="$repo_root/$target"
    if ! grep -Fq "$flutter" "$text"; then
      echo "toolchain-drift|$text|missing Flutter $flutter"
      return 1
    fi
    if ! grep -Fq "$dart" "$text"; then
      echo "toolchain-drift|$text|missing Dart $dart"
      return 1
    fi
  done

  for target in "${optional_local_policy_targets[@]}"; do
    text="$repo_root/$target"
    if [[ ! -f "$text" ]]; then
      continue
    fi
    if ! grep -Fq "$flutter" "$text"; then
      echo "toolchain-drift|$text|missing Flutter $flutter"
      return 1
    fi
    if ! grep -Fq "$dart" "$text"; then
      echo "toolchain-drift|$text|missing Dart $dart"
      return 1
    fi
  done

  echo "ok|toolchain-check|Flutter $flutter / Dart $dart"
  return 0
}

check_codex_rules_block() {
  local template="$agent_templates_root/$managed_codex_rules_template"
  local target="$managed_codex_rules_target"

  if [[ ! -f "$template" ]]; then
    echo "missing-source|$template"
    return 1
  fi

  if [[ ! -f "$target" ]]; then
    echo "missing-target|$target"
    return 1
  fi

  local expected actual
  expected="$(sed -n '/^# BEGIN flutter_bloc_app managed rules$/,/^# END flutter_bloc_app managed rules$/p' "$template")"
  actual="$(sed -n '/^# BEGIN flutter_bloc_app managed rules$/,/^# END flutter_bloc_app managed rules$/p' "$target")"

  if [[ "$expected" != "$actual" ]]; then
    echo "update|$target"
    return 1
  fi

  echo "ok|$target"
}

# Workspace .cursor/skills must not repeat names synced to ~/.cursor/skills (duplicate picker entries).
check_workspace_managed_skill_duplicates() {
  local workspace_skills="$repo_root/.cursor/skills"
  local mapping dst skill_dir workspace_skill
  [[ -d "$workspace_skills" ]] || return 0
  for mapping in "${managed_cursor_files[@]}"; do
    dst="${mapping##*|}"
    skill_dir="$(basename "$(dirname "$dst")")"
    workspace_skill="$workspace_skills/$skill_dir/SKILL.md"
    if [[ -f "$workspace_skill" ]]; then
      echo "workspace-skill-duplicate|$workspace_skill|remove; canon syncs to $dst"
      return 1
    fi
  done
  echo "ok|$workspace_skills"
  return 0
}

apply_codex_rules_block() {
  local template="$agent_templates_root/$managed_codex_rules_template"
  local target="$managed_codex_rules_target"
  local tmp
  mkdir -p "$(dirname "$target")"
  [[ -f "$target" ]] || touch "$target"
  tmp="$(mktemp)"
  python3 - "$template" "$target" "$tmp" <<'PY'
from pathlib import Path
import sys
template = Path(sys.argv[1]).read_text()
target_path = Path(sys.argv[2])
target = target_path.read_text() if target_path.exists() else ""
start = "# BEGIN flutter_bloc_app managed rules"
end = "# END flutter_bloc_app managed rules"
if start in target and end in target:
    prefix = target.split(start, 1)[0]
    suffix = target.split(end, 1)[1]
    out = prefix.rstrip("\n") + "\n" + template.rstrip("\n") + "\n" + suffix.lstrip("\n")
else:
    out = target.rstrip("\n")
    if out:
        out += "\n"
    out += template.rstrip("\n") + "\n"
Path(sys.argv[3]).write_text(out)
PY
  mv "$tmp" "$target"
}
