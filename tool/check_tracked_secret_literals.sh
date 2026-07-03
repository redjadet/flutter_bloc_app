#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "tracked-secrets|skip|not-git-repo"
  exit 0
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "tracked-secrets|skip|ripgrep-missing"
  exit 0
fi

is_scannable_path() {
  case "$1" in
    assets/config/*|*/assets/config/*)
      return 0
      ;;
    assets/*|*/assets/*|tool/fixtures/*)
      return 1
      ;;
    *.dart|*.ts|*.tsx|*.js|*.jsx|*.py|*.sh|*.yml|*.yaml|*.json|*.plist|*.toml|*.env|*.example|*.sample|*.xml)
      return 0
      ;;
    .env.*|.firebaserc|Gemfile|Gemfile.lock|pubspec.yaml|pubspec.lock|firebase.json|backend/firebase/**/firestore.rules|backend/firebase/**/storage.rules)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

mapfile -t tracked_files < <(
  git ls-files | while IFS= read -r path; do
    if is_scannable_path "$path"; then
      printf '%s\n' "$path"
    fi
  done
)
if [ "${#tracked_files[@]}" -eq 0 ]; then
  echo "tracked-secrets|ok|no-tracked-files"
  exit 0
fi

finding_count=0

emit_findings() {
  local rule="$1"
  local pattern="$2"
  local output

  output="$(
    rg --line-number --no-heading --color never "$pattern" "${tracked_files[@]}" 2>/dev/null || true
  )"
  if [ -z "$output" ]; then
    return 0
  fi

  while IFS=: read -r file line _rest; do
    [ -n "$file" ] || continue
    finding_count=$((finding_count + 1))
    printf 'violation|%s:%s:%s:tracked secret-looking literal\n' "$file" "$line" "$rule"
  done <<< "$output"
}

emit_findings "google_api_key" 'AIza[0-9A-Za-z_-]{20,}'
emit_findings "openai_api_key" 'sk-[A-Za-z0-9_=-]{20,}'
emit_findings "aws_access_key" '(AKIA|ASIA)[0-9A-Z]{16}'
emit_findings "private_key_block" '-----BEGIN[[:space:]]PRIVATE[[:space:]]KEY-----'

if [ "$finding_count" -eq 0 ]; then
  echo "tracked-secrets|ok"
  exit 0
fi

exit 1
