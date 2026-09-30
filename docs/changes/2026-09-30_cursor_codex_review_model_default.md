# Cursor to Codex review default

Cursor diff and plan review helpers now default to `gpt-6.1-sol` with medium
reasoning. Their shared model policy and Cursor adapters agree on this default.
Explicit model/profile overrides remain supported. The existing visible retry
with `gpt-6-luna` applies only when the account rejects the default model;
transport failures and explicit model requests do not trigger fallback.

The installed Cursor delegate also defaults to `gpt-6.1-sol` with medium
reasoning, bypassing old model-discovery caches. This host-local skill is not
tracked by the repository. Codex CLI settings for unrelated calls are unchanged.

Proof: `bash tool/check_delegate_wrapper_contracts.sh` checks read-only
arguments, default model/reasoning, overrides, unsupported-model fallback,
transport failure, and structured output using mocked CLIs.
