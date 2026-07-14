#!/usr/bin/env bash
# Deterministic, read-only tool recommendations from task intent and file scope.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/agent_tool_router.sh [--intent <text>] [--paths <file>...]

Print repo-first tool routes for AI agents. Explicit paths win; without paths,
the router inspects staged, unstaged, and untracked git paths. Intent augments
path routing for runtime, package API, browser, GitHub, Firebase, Supabase, and
Figma work.

This command is read-only. It recommends tools; it never starts debug apps,
installs dependencies, deploys, or mutates external systems.
EOF
}

intent=""
declare -a explicit_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --intent)
      intent="${2:-}"
      if [[ -z "$intent" ]]; then
        echo "usage-error|--intent requires text" >&2
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
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

declare -a paths=()
if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  paths=("${explicit_paths[@]}")
elif command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r path; do
    [[ -n "$path" ]] && paths+=("$path")
  done < <({
    git diff --name-only --diff-filter=ACMRTUXBD 2>/dev/null || true
    git diff --name-only --cached --diff-filter=ACMRTUXBD 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | sed '/^$/d' | LC_ALL=C sort -u)
fi

intent_lower="$(printf '%s' "$intent" | tr '[:upper:]' '[:lower:]')"
intent_words=" $intent_lower "

route_runtime=0
route_package=0
route_browser=0
route_github=0
route_firebase=0
route_supabase=0
route_figma=0
route_dart=0
route_app_dart=0
route_test=0
route_ui=0
route_router=0
route_docs=0
route_shell=0
route_agent=0

case "$intent_lower" in
  *runtime*|*crash*|*exception*|*"red screen"*|*"yellow screen"*) route_runtime=1 ;;
esac
case "$intent_words" in
  *" package "*|*" dependency "*|*" pubspec "*|*" api "*|*" sdk "*|*" migration "*) route_package=1 ;;
esac
case "$intent_words" in
  *" browser "*|*" website "*|*" webpage "*|*" url "*) route_browser=1 ;;
esac
case "$intent_words" in
  *" github "*|*" pull request "*|*" pr "*|*" ci "*) route_github=1 ;;
esac
case "$intent_lower" in *firebase*) route_firebase=1 ;; esac
case "$intent_lower" in *supabase*) route_supabase=1 ;; esac
case "$intent_lower" in *figma*) route_figma=1 ;; esac
case "$intent_words" in *" ui "*|*" widget "*|*" layout "*|*" design "*) route_ui=1 ;; esac
case "$intent_words" in *" route "*|*" router "*|*" navigation "*|*" auth gate "*) route_router=1 ;; esac
case "$intent_words" in
  *" harness "*|*" tool audit "*|*" agent-maintain "*|*" agent maintain "*|*" agent harness "*)
    route_agent=1
    ;;
esac

for raw_path in "${paths[@]}"; do
  path="${raw_path#"$repo_root"/}"
  case "$path" in
    apps/mobile/lib/*.dart|packages/*/lib/*.dart)
      route_dart=1
      ;;
  esac
  case "$path" in
    apps/mobile/lib/*.dart)
      route_app_dart=1
      ;;
  esac
  case "$path" in
    apps/mobile/test/*.dart|apps/mobile/integration_test/*.dart|packages/*/test/*.dart)
      route_test=1
      ;;
  esac
  case "$path" in
    apps/mobile/lib/features/*/presentation/*|apps/mobile/lib/app/theme/*|packages/design_system/*|DESIGN.md|docs/design_system.md)
      route_ui=1
      ;;
  esac
  case "$path" in
    apps/mobile/lib/app/router/*|*app_routes.dart|*auth_gate*.dart|*route_guard*.dart)
      route_router=1
      ;;
  esac
  case "$path" in
    pubspec.yaml|pubspec.lock|apps/*/pubspec.yaml|packages/*/pubspec.yaml)
      route_package=1
      ;;
  esac
  case "$path" in
    AGENTS.md|CONTRACTS.md|docs/*.md|README.md|SECURITY.md|DESIGN.md)
      route_docs=1
      ;;
  esac
  case "$path" in
    tool/*.sh|bin/*)
      route_shell=1
      ;;
  esac
  case "$path" in
    AGENTS.md|docs/ai/*|docs/agent_kb/*|docs/agent_knowledge_base.md|docs/agents_quick_reference.md|tool/agent_host_templates/*|tool/agent_maintain.sh|tool/agent_session_bootstrap.sh|tool/agent_tool_router.sh|bin/agent-maintain)
      route_agent=1
      ;;
  esac
done

echo "tool_route|discovery|repo|rg then targeted raw reads; semantic graph only when structure is unclear"

if (( route_runtime )); then
  echo "tool_route|runtime|dart-mcp|get_runtime_errors -> smallest fix -> hot_reload/hot_restart -> get_runtime_errors"
  echo "tool_route|runtime-fallback|repo|bash tool/check_runtime_errors.sh; no session: analyze + focused tests"
fi
if (( route_package )); then
  echo "tool_route|package-api|dart-mcp+official-docs|pin lockfile -> resolved package source -> current official docs -> analyze"
fi
if (( route_browser )); then
  echo "tool_route|browser|browser/playwright|inspect live page and console/network state; do not infer runtime state from source"
fi
if (( route_github )); then
  echo "tool_route|github|gh|read PR/check/run state first; external mutations require explicit scope"
fi
if (( route_firebase )); then
  echo "tool_route|firebase|firebase-mcp-or-cli|inspect project/config state; never print secrets; deploy only with confirmation"
fi
if (( route_supabase )); then
  echo "tool_route|supabase|supabase-mcp|inspect schema/migrations first; write migrations in repo; apply only with confirmation"
fi
if (( route_figma )); then
  echo "tool_route|figma|figma-mcp|read design context and variables before implementation"
fi
if (( route_dart )); then
  echo "tool_route|dart|dart-mcp-or-repo|analyze_files on touched paths; fallback ./tool/analyze.sh"
fi
if (( route_app_dart )); then
  echo "tool_route|app-debug|dart-mcp|if a matching debug app is active, hot_reload; use hot_restart for init/DI/codegen/native"
fi
if (( route_test )); then
  echo "tool_route|tests|repo|run focused flutter test paths before broad checklist"
fi
if (( route_ui )); then
  echo "tool_route|ui|repo+dart-mcp|DESIGN.md + design_system.md; compact/wide widget proof; active debug hot reload"
fi
if (( route_router )); then
  echo "tool_route|router|repo|./bin/router_feature_validate; add full checklist when scope is wide"
fi
if (( route_docs )); then
  echo "tool_route|docs|repo|bash tool/check_docs_gardening.sh on touched docs"
fi
if (( route_shell )); then
  echo "tool_route|shell|repo|bash -n on touched scripts + owning CLI/fixture test"
fi
if (( route_agent )); then
  echo "tool_route|agent-harness|repo|check_agent_knowledge_base + harness gates + agent-maintain closeout"
fi

if (( ! route_runtime && ! route_package && ! route_browser && ! route_github && ! route_firebase && ! route_supabase && ! route_figma && ! route_dart && ! route_test && ! route_ui && ! route_router && ! route_docs && ! route_shell && ! route_agent )); then
  echo "tool_route|fallback|repo|use ./bin/agent-maintain find QUERY, then narrowest owning validation"
fi
