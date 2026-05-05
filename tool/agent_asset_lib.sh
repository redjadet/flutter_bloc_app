#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

agent_templates_root="${AGENT_TEMPLATES_ROOT:-$repo_root/tool/agent_host_templates}"

has_agent_templates() {
  [[ -d "$agent_templates_root" ]]
}

# shellcheck disable=SC2034
managed_cursor_files=(
  "cursor/skills/agents-quick-reference/SKILL.md|$HOME/.cursor/skills/agents-quick-reference/SKILL.md"
  "cursor/skills/agents-delivery-workflow/SKILL.md|$HOME/.cursor/skills/agents-delivery-workflow/SKILL.md"
  "cursor/skills/agents-meta-behavior/SKILL.md|$HOME/.cursor/skills/agents-meta-behavior/SKILL.md"
  "cursor/skills/agents-cursor-integration/SKILL.md|$HOME/.cursor/skills/agents-cursor-integration/SKILL.md"
  "cursor/skills/caveman-compress/SKILL.md|$HOME/.cursor/skills/caveman-compress/SKILL.md"
  "cursor/skills/upgrade-pr-triage-validate/SKILL.md|$HOME/.cursor/skills/upgrade-pr-triage-validate/SKILL.md"
  "cursor/commands/commit-push-pr.md|$HOME/.cursor/commands/commit-push-pr.md"
  "cursor/commands/local-agents-quick-reference.md|$HOME/.cursor/commands/local-agents-quick-reference.md"
  "cursor/commands/upgrade-validate-all.md|$HOME/.cursor/commands/upgrade-validate-all.md"
  "cursor/commands/codex-feedback.md|$HOME/.cursor/commands/codex-feedback.md"
  "cursor/rules/agents-global.mdc|$HOME/.cursor/rules/agents-global.mdc"
)

# shellcheck disable=SC2034
managed_codex_files=(
  "codex/AGENTS.md|$HOME/.codex/AGENTS.md"
  "codex/skills/flutter-bloc-app-quick-reference/SKILL.md|$HOME/.codex/skills/flutter-bloc-app-quick-reference/SKILL.md"
  "codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md|$HOME/.codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md"
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
  "tool/agent_host_templates/codex/skills/flutter-bloc-app-quick-reference/SKILL.md"
  "tool/agent_host_templates/cursor/skills/agents-quick-reference/SKILL.md"
)

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
  local src="$agent_templates_root/$src_rel"

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
  local src="$agent_templates_root/$src_rel"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

extract_readme_toolchain() {
  python3 - "$repo_root/README.md" <<'PY'
import re
import sys
text = open(sys.argv[1], encoding="utf-8").read()
flutter = re.search(r"Flutter `([^`]+)`", text)
dart = re.search(r"Dart `([^`]+)`", text)
if not flutter or not dart:
    raise SystemExit(1)
print(f"{flutter.group(1)}|{dart.group(1)}")
PY
}

check_toolchain_mentions() {
  local versions target text flutter dart
  versions="$(extract_readme_toolchain)"
  flutter="${versions%%|*}"
  dart="${versions##*|}"

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
