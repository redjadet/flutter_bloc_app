#!/usr/bin/env bash
# Build curated Repomix context packs (onboarding or feature-scoped).
# Usage: bash tool/repomix_pack.sh onboarding
#        bash tool/repomix_pack.sh feature --feature counter

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

REPOMIX_VERSION="1.16.1"

usage() {
  cat <<'EOF'
Usage: bash tool/repomix_pack.sh onboarding
       bash tool/repomix_pack.sh feature --feature <snake_case>

Writes gitignored output under .repomix/<profile>-<timestamp>.md using
npx --yes repomix@1.16.1 and tracked configs under tool/repomix/.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "$#" -lt 1 ]]; then
  usage
  exit 0
fi

profile="$1"
shift

feature_name=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --feature)
      feature_name="${2:-}"
      [[ -n "$feature_name" ]] || {
        echo "usage-error|--feature requires a value" >&2
        exit 2
      }
      shift 2
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

mkdir -p .repomix
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_path=""
base_config=""
tmp_config=""

cleanup() {
  [[ -n "$tmp_config" && -f "$tmp_config" ]] && rm -f "$tmp_config"
}
trap cleanup EXIT

write_config_with_output() {
  local src="$1"
  local dest="$2"
  local out="$3"
  python3 - "$src" "$dest" "$out" <<'PY'
import json
import sys

src, dest, output = sys.argv[1], sys.argv[2], sys.argv[3]
with open(src, encoding="utf-8") as fh:
    data = json.load(fh)
data.setdefault("output", {})["filePath"] = output
with open(dest, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
}

case "$profile" in
  onboarding)
    base_config="tool/repomix/onboarding.config.json"
    output_path=".repomix/onboarding-${timestamp}.md"
    ;;
  feature)
    if [[ -z "$feature_name" ]]; then
      echo "usage-error|feature profile requires --feature <name>" >&2
      exit 2
    fi
    feature_root="apps/mobile/lib/features/${feature_name}"
    if [[ ! -d "$feature_root" ]]; then
      echo "❌ Unknown feature directory: $feature_root" >&2
      exit 1
    fi
    base_config="tool/repomix/feature.config.json"
    output_path=".repomix/feature-${feature_name}-${timestamp}.md"
    ;;
  *)
    echo "usage-error|unknown profile: $profile (expected onboarding|feature)" >&2
    exit 2
    ;;
esac

tmp_config="$(mktemp "${TMPDIR:-/tmp}/repomix.XXXXXX.json")"
write_config_with_output "$base_config" "$tmp_config" "$output_path"

if [[ "$profile" == "feature" ]]; then
  python3 - "$tmp_config" "$feature_name" <<'PY'
import glob
import json
import sys

path, feature = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)
extra = [
    f"apps/mobile/lib/features/{feature}/**/*",
    f"apps/mobile/test/features/{feature}/**/*",
]
for pattern in (
    f"apps/mobile/lib/app/composition/features/register_{feature}*.dart",
    f"apps/mobile/lib/app/composition/groups/*{feature}*.dart",
):
    extra.extend(glob.glob(pattern, recursive=False))
for registrar in glob.glob("apps/mobile/lib/app/composition/features/register_*.dart"):
    try:
        with open(registrar, encoding="utf-8") as fh:
            body = fh.read()
    except OSError:
        continue
    if f"/features/{feature}/" in body or f"features/{feature}/" in body:
        extra.append(registrar)
for helper in (
    "apps/mobile/lib/app/composition/injector_factories.dart",
    "apps/mobile/lib/app/composition/groups/register_feature_services.dart",
):
    if helper not in extra:
        extra.append(helper)
data["include"] = list(dict.fromkeys(data["include"] + extra))
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
fi

echo "repomix|pack|profile=$profile|output=$output_path"
npx --yes "repomix@${REPOMIX_VERSION}" --config "$tmp_config"

if [[ ! -f "$output_path" ]]; then
  echo "❌ Repomix did not write expected output: $output_path" >&2
  exit 1
fi

echo "✅ Repomix pack written: $output_path"
