# Cursor to Codex review default

Cursor's explicit GPT/Codex review requests use the repository helpers:
`tool/request_codex_feedback.sh` for Git diffs and
`tool/run_codex_plan_review.sh` for Markdown plans. Both now select
`gpt-6-sol` with medium reasoning by default. Diff review keeps `--model`
and `--profile fast` overrides; plan review passes explicit delegate
options through after its defaults.

## Must remain true

Review execution stays read-only. Model selection and reasoning are ordinary
CLI arguments; no API key, token, or machine-local configuration enters Git.
Cursor routes review only when the user explicitly asks for a cross-host
second opinion.

## Failure modes

A local Codex default or delegate model cache could silently select another
model. Both helpers pass the default explicitly. If GPT-6 Sol is unavailable
to the authenticated account, the command fails visibly; the operator can
choose an available model with `--model`. Mocked contract checks cover both
backends and plan review without sending repository content to a live model.

## Rejected alternatives

Changing `~/.codex/config.toml` would affect unrelated projects and risk
tracking local settings. Relying on the delegate's model discovery or cache
would not guarantee the requested default.
