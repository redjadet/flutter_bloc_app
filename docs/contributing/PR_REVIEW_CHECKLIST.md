# PR Review Checklist — Networking & Contracts

Use with [`review/code_review_playbook.md`](../review/code_review_playbook.md).
Answer every question that applies; “N/A” needs a one-line reason.

## Networking / transport

- [ ] Uses shared `createAppDio` (or allowlisted `createRenderChatDio`) — no `?? Dio()` / bare `Dio(` in production constructors?
- [ ] Timeouts, retries, and auth injection still correct for this path?
- [ ] Certificate pinning / security posture unchanged unless intentionally reviewed?
- [ ] Guard still green: `bash tool/check_adhoc_dio_construction.sh`?

## Pagination (when lists change)

- [ ] Offset vs cursor fields match [`backend/API_CONTRACT_GUIDE.md`](../backend/API_CONTRACT_GUIDE.md)?
- [ ] Refresh replaces; load-more dedupes by id?
- [ ] Empty / terminal page stops fetching?
- [ ] Malformed page payload → controlled failure (not `TypeError`)?

## Request / idempotency

- [ ] Mutations safe to retry (idempotency key or equivalent)?
- [ ] No duplicate fire on double-tap / rebuild?
- [ ] Offline pending sync still merges correctly?

## Bloc / state ownership

- [ ] Cubit holds UI/domain state — not wire DTOs or raw `Map`s?
- [ ] Failures mapped to typed state / `AppError` — no uncaught cast leaks?
- [ ] See [`architecture/MOBILE_BACKEND_BOUNDARIES.md`](../architecture/MOBILE_BACKEND_BOUNDARIES.md) modes 1 and 6.

## Performance

- [ ] No unbounded `ListView` of huge payloads without pagination plan?
- [ ] Heavy JSON decode stays off UI isolate when existing patterns require it?
- [ ] No unnecessary rebuild storms from transport callbacks?

## Contract tests

- [ ] Happy path + missing/malformed required fields covered?
- [ ] Unknown string statuses / unknown optional keys accepted where policy says so?
- [ ] GraphQL/data failures map to feature exception types?

## Offline

- [ ] Cache ownership and stale-merge rules still hold?
- [ ] Remote failure does not wipe newer local state?

## Documentation

- [ ] New/changed API behavior linked from owner doc or change note?
- [ ] If introducing pagination or product analytics, update the contract guide / observability plan first?

## Related

- API contract: [`backend/API_CONTRACT_GUIDE.md`](../backend/API_CONTRACT_GUIDE.md)
- DTO policy: [`architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md)
- Reliability: [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md)
