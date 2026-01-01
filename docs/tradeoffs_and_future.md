# Trade-offs & Future Improvements

This section captures known trade-offs and future improvements that were
previously listed in the README.

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
