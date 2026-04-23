#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_docs_gardening.sh [--paths <file>...] [--base <git-ref>]

Cheap, deterministic doc-rot detector for repo markdown guidance.

Checks (scoped to changed docs when provided; otherwise checks core docs):
- backticked `*.md` tokens resolve to real files (best-effort, same rules as normalize_doc_links)
- `docs/validation_scripts.md` is synced with `tool/delivery_checklist.sh` (via tool/validate_validation_docs.sh)

Exit codes:
  0 pass
  1 fail
  2 usage error

Environment:
  HARNESS_SKIP_DOC_GARDENING=1 -> prints skipped-by-policy and exits 0
EOF
}

if [[ "${HARNESS_SKIP_DOC_GARDENING:-0}" == "1" ]]; then
  echo "skipped-by-policy|doc-gardening|HARNESS_SKIP_DOC_GARDENING=1"
  exit 0
fi

base_ref=""
declare -a explicit_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --base)
      base_ref="${2:-}"
      if [[ -z "$base_ref" ]]; then
        echo "usage-error|--base requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        explicit_paths+=("$1")
        shift
      done
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

declare -a doc_targets=()

add_doc_target_if_exists() {
  local p="$1"
  if [[ -f "$p" ]]; then
    doc_targets+=("$p")
  fi
}

add_doc_target_if_in_scope() {
  local p="$1"
  # Accept fixture docs as absolute or relative paths.
  if [[ "$p" == /* ]]; then
    p="${p#$repo_root/}"
  fi
  case "$p" in
    README.md|SECURITY.md|AGENTS.md|docs/*.md|docs/*/*.md|docs/*/*/*.md|tool/fixtures/harness/*.md)
      add_doc_target_if_exists "$p"
      ;;
  esac
}

if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  for p in "${explicit_paths[@]}"; do
    add_doc_target_if_in_scope "$p"
  done
elif [[ -n "$base_ref" ]]; then
  if ! git rev-parse "$base_ref" >/dev/null 2>&1; then
    echo "usage-error|invalid base ref: $base_ref" >&2
    exit 2
  fi
  while IFS= read -r p; do
    [[ -n "$p" ]] && add_doc_target_if_in_scope "$p"
  done < <(git diff --name-only "$base_ref...HEAD" --diff-filter=ACMRTUXB | sed '/^$/d')
else
  add_doc_target_if_exists "README.md"
  add_doc_target_if_exists "AGENTS.md"
  add_doc_target_if_exists "docs/README.md"
  add_doc_target_if_exists "docs/agent_knowledge_base.md"
  add_doc_target_if_exists "docs/agents_quick_reference.md"
  add_doc_target_if_exists "docs/ai_code_review_protocol.md"
  add_doc_target_if_exists "docs/validation_scripts.md"
fi

if [[ "${#doc_targets[@]}" -eq 0 ]]; then
  echo "doc-gardening|no-doc-targets"
  exit 0
fi

failures=0
fail() {
  echo "❌ $*" >&2
  failures=1
}

python3_bin=""
if command -v python3 >/dev/null 2>&1; then
  python3_bin="python3"
else
  echo "unknown-scope|treating as broad|python3-missing"
fi

if [[ -n "$python3_bin" ]]; then
  # Validate that backticked `*.md` tokens resolve to existing files.
  # We reuse the resolution rules from tool/normalize_doc_links.py by importing and calling its helpers.
  "$python3_bin" - "$repo_root" "${doc_targets[@]}" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
targets = [Path(p).resolve() for p in sys.argv[2:]]

md_token_re = re.compile(r"`([^`\n]+?\.md)`")

# Import resolver from normalize_doc_links.py (repo-local).
normalize = repo_root / "tool" / "normalize_doc_links.py"
namespace: dict[str, object] = {}
exec(normalize.read_text(encoding="utf-8"), namespace)  # noqa: S102
resolve_token = namespace["_resolve_token_to_existing_path"]

failures: list[str] = []

for file_path in targets:
    try:
        text = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue

    for m in md_token_re.finditer(text):
        token = m.group(1).strip()
        start, end = m.span()

        # Skip tokens that are already part of a markdown link label: [`token`](...)
        if start >= 2 and text[start - 2:start] == "[`":
            # best-effort: avoid false positives from link labels
            continue
        if end + 2 <= len(text) and text[end:end + 2] == "](":
            continue

        # Skip globs/placeholders and non-file tokens.
        if any(ch in token for ch in ("*", "<", ">", "{", "}", "$")):
            continue
        if token in (".md", "*.md"):
            continue
        if token.endswith(".original.md"):
            continue
        if token.startswith(("./", "../")):
            continue
        if "PATH/TO" in token or "path/to" in token:
            continue
        resolved = resolve_token(token, file_path=file_path, repo_root=repo_root)
        if resolved is None and "tool/fixtures/" in token:
            # Fixture docs are under repo root; allow explicit repo-root resolution.
            candidate = repo_root / token
            resolved = candidate if candidate.is_file() else None
        if resolved is None:
            failures.append(f"{file_path.relative_to(repo_root)}: missing md token `{token}`")
            continue

        # Do not allow doc links to escape the repo root via symlinks.
        try:
            resolved_real = resolved.resolve()
        except OSError:
            failures.append(f"{file_path.relative_to(repo_root)}: unreadable md token `{token}`")
            continue
        try:
            resolved_real.relative_to(repo_root)
        except ValueError:
            failures.append(f"{file_path.relative_to(repo_root)}: md token escapes repo `{token}` -> {resolved_real}")

if failures:
    for f in failures[:50]:
        print(f"violation|{f}")
    if len(failures) > 50:
        print(f"violation|... and {len(failures) - 50} more")
    raise SystemExit(1)

print("doc-gardening|md-tokens|ok")
PY
  token_exit=$?
  if [[ "$token_exit" -ne 0 ]]; then
    fail "doc-gardening token check failed"
  fi
else
  echo "doc-gardening|md-tokens|skipped|python3-missing"
fi

if command -v bash >/dev/null 2>&1 && [ -f "$repo_root/tool/agent_asset_lib.sh" ]; then
  # Toolchain mention drift: reuse existing canonical extractor/checker.
  # shellcheck source=./agent_asset_lib.sh disable=SC1091
  source "$repo_root/tool/agent_asset_lib.sh"
  if ! check_toolchain_mentions; then
    fail "toolchain mention drift detected (README vs required docs)"
  fi
fi

# Missing referenced scripts (cheap): if docs mention backticked tool/*.sh or bin/*, they must exist.
for doc in "${doc_targets[@]}"; do
  while IFS= read -r token; do
    token="${token#\`}"
    token="${token%\`}"
    case "$token" in
      tool/*.sh|bin/*)
        if [[ "$token" == *"*"* || "$token" == *"<"* || "$token" == *">"* ]]; then
          continue
        fi
        if [[ ! -f "$repo_root/$token" ]]; then
          fail "$doc references missing script: $token"
        fi
        ;;
    esac
  done < <(grep -oE '`(tool/[^`]+\.sh|bin/[^`]+)`' "$doc" 2>/dev/null || true)
done

if ! bash "$repo_root/tool/validate_validation_docs.sh"; then
  fail "docs/validation_scripts.md out of sync with CHECK_SCRIPTS"
fi

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "✅ Doc gardening checks passed."
