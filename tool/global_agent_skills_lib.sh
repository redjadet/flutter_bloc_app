#!/usr/bin/env bash
# Shared helpers for global Cursor agent skill install/update scripts.

global_agent_skills_lib_loaded=1

GLOBAL_AGENT_SKILLS_AGENT="${GLOBAL_AGENT_SKILLS_AGENT:-cursor}"
GLOBAL_AGENT_SKILLS_HOME="${GLOBAL_AGENT_SKILLS_HOME:-$HOME/.agents/skills}"
GLOBAL_CURSOR_SKILLS_HOME="${GLOBAL_CURSOR_SKILLS_HOME:-$HOME/.cursor/skills}"

# Keep when --ios-minimal trims dpearson2699/swift-ios-skills noise.
IOS_MINIMAL_KEEP_SKILL_NAMES=(
  ios-development
  swift-development
  release-review
  security
  macos-development
)

# Flat iOS kit / Apple framework skills (agents-only bloat for Flutter-first work).
_ios_minimal_is_bloat_name() {
  local name="$1"
  local keep
  for keep in "${IOS_MINIMAL_KEEP_SKILL_NAMES[@]}"; do
    [[ "$name" == "$keep" ]] && return 1
  done
  case "$name" in
    accessory*|activity*|appkit*|widgetkit*|storekit*|swiftui-*|xcode*|uikit*|watchos*|visionos*|tvos*|carplay*|healthkit*|homekit*|mapkit*|cloudkit*|coredata*|coreml*|arkit*|passkit*|tipkit*|paperkit*|pencilkit*|photokit*|realitykit*|scenekit*|spritekit*|tabletop*|musickit*|financekit*|energykit*|dockkit*|browserengine*|callkit*|cryptokit*|cryptotoken*|device-integrity*|debugging-instruments*|focus-engine*|natural-language*|permissionkit*|push-notifications*|relevancekit*|shareplay*|speech-recognition*|sensorkit*|metrickit*|appmigration*|audioaccessory*|adattribution*|app-clips*|app-intents*|authentication*|avkit*|swift-charts*|swift-codable*|swift-concurrency*|swift-formatstyle*|swift-language*|swift-security*|swift-testing*|swift-architecture*|swiftlint*|swiftdata*|ios-accessibility|ios-localization|ios-networking|ios-simulator|app-store|apple-intelligence|design)
      return 0
      ;;
  esac
  return 1
}

_skill_frontmatter_name() {
  local skill_md="$1"
  [[ -f "$skill_md" ]] || return 1
  awk '
    BEGIN { in_fm=0 }
    /^---$/ { if (in_fm) { exit } in_fm=1; next }
    in_fm && /^name:/ {
      sub(/^name:[[:space:]]*/, "", $0)
      gsub(/^["'\'']|["'\'']$/, "", $0)
      print $0
      exit
    }
  ' "$skill_md"
}

CURSOR_SKILL_INDEX_FILE="${CURSOR_SKILL_INDEX_FILE:-}"

_cursor_skill_name_index_build() {
  local skill_md dir name
  CURSOR_SKILL_INDEX_FILE="$(mktemp "${TMPDIR:-/tmp}/cursor-skill-index.XXXXXX")"
  [[ -d "$GLOBAL_CURSOR_SKILLS_HOME" ]] || return 0
  while IFS= read -r -d '' skill_md; do
    dir="$(basename "$(dirname "$skill_md")")"
    printf '%s\n' "$dir" >>"$CURSOR_SKILL_INDEX_FILE"
    name="$(_skill_frontmatter_name "$skill_md")"
    [[ -n "$name" ]] && printf '%s\n' "$name" >>"$CURSOR_SKILL_INDEX_FILE"
  done < <(find "$GLOBAL_CURSOR_SKILLS_HOME" -name SKILL.md -print0 2>/dev/null)
  sort -u -o "$CURSOR_SKILL_INDEX_FILE" "$CURSOR_SKILL_INDEX_FILE"
}

_cursor_has_skill_name() {
  local name="$1"
  if [[ -z "$CURSOR_SKILL_INDEX_FILE" ]]; then
    _cursor_skill_name_index_build
  fi
  grep -qxF "$name" "$CURSOR_SKILL_INDEX_FILE"
}

_archive_agent_skill_dir() {
  local src="$1"
  local archive_root="$2"
  local apply="$3"
  local base dest
  base="$(basename "$src")"
  dest="$archive_root/$base"
  if (( apply )); then
    mkdir -p "$archive_root"
    if [[ -e "$dest" ]]; then
      dest="$archive_root/${base}-$RANDOM"
    fi
    mv "$src" "$dest"
    echo "global-agent-skills|archived|$src -> $dest"
  else
    echo "global-agent-skills|dry-run|archive $src -> $dest"
  fi
}

# Removed from flutter/skills upstream; keep linking local copies when present.
LEGACY_FLUTTER_SKILL_NAMES=(
  flutter-architecting-apps
  flutter-animating-apps
  flutter-building-forms
  flutter-building-layouts
  flutter-caching-data
  flutter-embedding-native-views
  flutter-handling-concurrency
  flutter-handling-http-and-json
  flutter-implementing-navigation-and-routing
  flutter-improving-accessibility
  flutter-interoperating-with-native-apis
  flutter-localizing-apps
  flutter-managing-state
  flutter-testing-apps
  flutter-theming-apps
  flutter-working-with-databases
)

require_global_agent_skills_runtime() {
  if ! command -v npx >/dev/null 2>&1; then
    echo "global-agent-skills|error|npx not found (install Node.js/npm)" >&2
    return 1
  fi
  if ! npx --yes skills --version >/dev/null 2>&1; then
    echo "global-agent-skills|error|skills CLI unavailable (npx skills --version failed)" >&2
    return 1
  fi
  return 0
}

run_skills_add() {
  local label="$1"
  shift
  local -a cmd=(npx skills add "$@" -g -a "$GLOBAL_AGENT_SKILLS_AGENT" -y)
  echo "global-agent-skills|run|${cmd[*]}"
  "${cmd[@]}"
  echo "global-agent-skills|ok|$label"
}

run_skills_update() {
  local -a cmd=(npx skills update -g -y)
  echo "global-agent-skills|run|${cmd[*]}"
  "${cmd[@]}"
  echo "global-agent-skills|ok|update"
}

run_skills_check() {
  local -a cmd=(npx skills check)
  echo "global-agent-skills|run|${cmd[*]}"
  "${cmd[@]}"
}

run_skills_find() {
  if (($# == 0)); then
    echo "global-agent-skills|error|find requires a query" >&2
    return 2
  fi
  local -a cmd=(npx skills find "$@")
  echo "global-agent-skills|run|${cmd[*]}"
  "${cmd[@]}"
}

install_dart_skills() {
  run_skills_add "dart-lang/skills" dart-lang/skills --all
}

install_flutter_skills() {
  run_skills_add "flutter/skills" flutter/skills --all
}

install_ios_skills() {
  run_skills_add "swift-ios-skills" dpearson2699/swift-ios-skills --all
  run_skills_add "ios-development" rshankras/claude-code-apple-skills@ios-development
}

install_ai_workflow_skills() {
  run_skills_add "superpowers" obra/superpowers --all
  run_skills_add "dart-flutter-patterns" affaan-m/everything-claude-code@dart-flutter-patterns
  run_skills_add "caveman" JuliusBrussee/caveman
  run_skills_add "find-skills" vercel-labs/skills@find-skills
}

install_legacy_flutter_skills() {
  local name path
  for name in "${LEGACY_FLUTTER_SKILL_NAMES[@]}"; do
    path="$GLOBAL_AGENT_SKILLS_HOME/$name"
    if [[ ! -f "$path/SKILL.md" ]]; then
      echo "global-agent-skills|skip|legacy $name (no $path/SKILL.md)"
      continue
    fi
    run_skills_add "legacy-$name" "$path"
  done
}
