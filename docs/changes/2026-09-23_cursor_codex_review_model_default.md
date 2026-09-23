# Cursor to Codex review default

Cursor's explicit GPT/Codex review requests use the repository helpers:
`tool/request_codex_feedback.sh` for Git diffs and
`tool/run_codex_plan_review.sh` for Markdown plans. Both now select
`gpt-6-sol` with medium reasoning by default. If the account rejects that
model, the helpers retry once with `gpt-5.6-sol` at the same reasoning level.
Diff review keeps `--model` and `--profile fast` overrides; plan review passes
explicit delegate options through after its defaults. Explicit model choices
and raw debugging modes do not retry.

## Must remain true

Review execution stays read-only. Model selection and reasoning are ordinary
CLI arguments; no API key, token, or machine-local configuration enters Git.
Cursor routes review only when the user explicitly asks for a cross-host
second opinion.

## Failure modes

A local Codex default or delegate model cache could silently select another
model. Both helpers pass the default explicitly. Account access can reject
GPT-6 Sol, so a specific unsupported-model error triggers one visible fallback
to GPT-5.6 Sol. Other errors remain failures, and explicit model choices stay
exact. Mocked contract checks cover both backends and plan review without
sending repository content to a live model.

## Rejected alternatives

Changing `~/.codex/config.toml` would affect unrelated projects and risk
tracking local settings. Relying on the delegate's model discovery or cache
would not guarantee the requested default.
