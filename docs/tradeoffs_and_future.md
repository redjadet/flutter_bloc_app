# Trade-offs & Future Improvements

This document captures known trade-offs and future improvements for the codebase.

> **Related Documentation:**
>
> - [Code Quality](CODE_QUALITY.md) - Code quality analysis and recommendations
> - [Flutter Best Practices Review](flutter_best_practices_review.md) - Best practices audit with action checklist
> - [Architecture Details](architecture_details.md) - Architecture patterns and principles

## Current Trade-offs

- Deep links to non-root routes can bypass auth redirects; page-level guards may
  be needed for stricter access control.
- No role/claims-based authorization yet (authenticated vs anonymous only).
- Non-Firebase HTTP clients do not attach auth headers automatically.
- Biometric authenticator allows access when sensors are unavailable or not
  enrolled; tighten policy if stricter gating is required.

## Future Improvements

- Add role/claims-based auth and per-route authorization guards.
- Expand token injection beyond `ResilientHttpClient` where needed.
- Tighten biometric access policy for sensitive flows.
- Add deeper route-level auth checks for non-root deep links.
