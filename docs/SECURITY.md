# Security policy

This repo is a reference Flutter application and not a versioned, packaged
library. Security reporting is still welcome and handled via the process below.

For the complete docs index, see `docs/README.md`.

## Reporting a vulnerability

- **Where**: open a GitHub Security Advisory, or if that is not available,
  open a private issue to the maintainers.
- **What to include**: clear repro steps, impact, affected platforms
  (Android/iOS/Web), and any proof-of-concept details needed to verify.
- **What to expect**: an initial acknowledgement within a few business days,
  followed by either a mitigation plan + timeline or a request for more detail.

## Secrets and local development keys

Please do not include real API keys, tokens, or credentials in reports or PRs.

This repository’s secrets strategy (local development, CI safety, and how
feature integrations are enabled/disabled) is documented in:

- `docs/security_and_secrets.md`
