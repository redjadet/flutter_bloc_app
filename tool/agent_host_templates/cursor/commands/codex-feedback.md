---
name: codex-feedback
description: Thin wrapper command for repo review helper.
---

# codex-feedback

Run repo review helper only for explicit second opinion/cross-host review:

```bash
./tool/request_codex_feedback.sh
./tool/request_codex_feedback.sh --focus "<focus area>"
./tool/request_codex_feedback.sh --base main
```

When user asks GPT or Codex to review a plan, use
`./tool/run_codex_plan_review.sh PATH/TO/plan.md`. Both helpers default to
GPT-6 Sol with medium reasoning. If the account rejects GPT-6 Sol, they retry
once with GPT-5.6 Sol at the same reasoning level. An explicit `--model`
selection does not retry. Keep review read-only; never put credentials
or tokens in command arguments, prompts, or tracked configuration.

Important: cross-host only; don’t ask current host to review itself. Adapter
only; repo script owns contract, fallback, output format.
