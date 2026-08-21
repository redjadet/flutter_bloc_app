# Feature: Social Feed Demo

## Problem

Credential-free `/social-feed-demo` that proves senior feed engineering:
cursor paging, cache-first UX, optimistic like/comment, offline ordered
queue, realtime buffer banner, viewer isolation — with durable docs and
executable proof (`SF-ARCH-01`, `SF-SCALE-01`, `SF-TEST-01`, `SF-SEC-01`,
`SF-DEP-01`, `SF-BG-01`, `SF-PERF-01`).

## Scope

- In: simulated remote + Hive cache/queue; Cubit; adaptive UI; Example entry;
  six locales; selective integration walkthrough
- Out: comment history/replies/edit/delete; real backend/auth; package adds;
  terminated-app work; network images; shared sync refactor

## Layers touched

- [x] domain
- [x] data
- [x] presentation
- [x] DI
- [x] routes / l10n

## Contracts

- Repository: `SocialFeedRepository` (viewer-required methods; sync lease)
- Realtime: `SocialFeedRealtimeSource.acquire` → lease
- Scenario: `SocialFeedScenarioController` (simulated faults only)
- State: Freezed sealed `SocialFeedState` (`initial|loading|failure|ready`)
- DTO / mapper: hand-written primary constructors; typed malformed failures

## Tests (executable contract — RED first)

### Behaviour (widget and/or cubit)

- [ ] Scenario: cache-first load → optimistic like/comment → offline queue →
  reconnect replay → realtime banner → viewer switch isolation
- [ ] Files: `test/features/social_feed_demo/presentation/cubit/social_feed_cubit_test.dart`,
  `test/features/social_feed_demo/presentation/pages/social_feed_demo_page_test.dart`

### State (widget — seed cubit/state)

- [ ] Scenario: loading | ready | failure | empty | stale/offline banners
- [ ] Files: `test/features/social_feed_demo/presentation/cubit/social_feed_state_test.dart`,
  `test/features/social_feed_demo/presentation/widgets/social_feed_responsive_layout_test.dart`

### Unit (domain / data)

- [ ] Scenario: cursor stability after top insert; pending-local merge;
  ordered like/comment replay; viewer isolation; comment policy bounds
- [ ] Files: `test/features/social_feed_demo/domain/social_feed_merge_policy_test.dart`,
  `test/features/social_feed_demo/data/simulated_social_feed_remote_data_source_test.dart`,
  `test/features/social_feed_demo/data/hive_social_feed_mutation_queue_test.dart`,
  `test/features/social_feed_demo/data/offline_first_social_feed_repository_test.dart`

### Integration

- [ ] Journey: Example → Social Feed smoke (selective map); tier: smoke
- [ ] Files: `apps/mobile/integration_test/social_feed_demo_flow_test.dart`

### Proof command

- [ ] `cd apps/mobile && flutter test test/features/social_feed_demo`
- [ ] `./bin/router_feature_validate`
- [ ] `./bin/integration_tests integration_test/social_feed_demo_flow_test.dart`

## Docs

- [ ] [`apps/mobile/lib/features/social_feed_demo/README.md`](../../apps/mobile/lib/features/social_feed_demo/README.md)
- [ ] [`features/social_feed_demo.md`](../features/social_feed_demo.md)
- [ ] [`feature_overview.md`](../feature_overview.md) / indexes (Wave 5)

## Risks

- Lease/timer leaks on lifecycle; Freezed-only-state policy drift; disk pressure
  during full checklist / platform builds

## depends_on

- [ ] [`plans/2026-08-20_social_feed_senior_signal_demo.md`](../plans/2026-08-20_social_feed_senior_signal_demo.md)

## blocks

- Interview showcase / gold reference registration (after P3–P6)

## merge_order

- Waves 0→6 in plan; no commit until user requests

## rollback

- Revert write-set paths; feature Hive boxes version-prefixed only

## proof_commands

- Wave proofs in plan; Wave 6 `./bin/checklist` when disk allows
