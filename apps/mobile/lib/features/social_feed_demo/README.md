# Social Feed Demo

Credential-free Flutter judgment guidance feed simulator (cursor paging, offline queue,
optimistic mutations, realtime banner, viewer isolation).

## Entry

- Route: `/social-feed-demo` (`AppRoutes.socialFeedDemo`)
- Example key: `example-social-feed-demo-button`
- Barrel: `social_feed_demo.dart`
- DI: `register_social_feed_demo_services.dart`

## Integrations

Hive cache/queue (viewer-scoped), `TimerService`, simulated remote/realtime/
scenario — no network, secrets, or auth.

## Tests

```bash
cd apps/mobile && flutter test test/features/social_feed_demo
```

## Gotchas

1. Freezed only for Cubit state; domain/DTOs are primary constructors.
2. Pending local intent wins over remote refresh until ack/reject.
3. Realtime posts buffer behind banner; never auto-jump scroll.
4. Viewer switch closes leases; never reuse prior viewer cache/queue.
5. Comment bodies are sensitive — never log them.

## Deep guide

See [`docs/features/social_feed_demo.md`](../../../../../../docs/features/social_feed_demo.md).
