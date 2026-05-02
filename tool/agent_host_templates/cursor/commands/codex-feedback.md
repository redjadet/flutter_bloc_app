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

Important: cross-host only; don’t ask current host to review itself. Adapter
only; repo script owns contract, fallback, output format.
