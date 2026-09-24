#!/usr/bin/env bash

# Shared by the checklist and CI. An empty or unrecognized scope takes full CI.
checklist_docs_only_event_allowed() {
  [ -z "${CI:-}" ] || [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]
}

checklist_docs_only_paths() {
  [ "$#" -gt 0 ] || return 1

  local file
  for file in "$@"; do
    case "$file" in
      *.md|*.mdx|*.rst|*.adoc|\
      llms.txt)
        ;;
      *)
        return 1
        ;;
    esac
  done
}
