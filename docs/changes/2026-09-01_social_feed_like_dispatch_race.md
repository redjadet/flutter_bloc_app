# 2026-09-01 — social-feed like dispatch race

## Why

An offline like replay could apply a stale queue head while a newer online
intent was in flight. The replay cleanup then risked removing the newer intent
instead of only the mutation it had dispatched.

## Scope

- Serialize remote like applies per viewer across replay and online writes.
- Mark a replayed like as dispatched before awaiting the remote result, then
  re-read the head inside the lock before applying it.
- Remove only the replayed mutation after dispatch; a successful online write
  clears all queued likes for that post because it is the newest user intent.
- Serialize replay ticks and cover the in-flight online-unlike regression.

## Out of scope

- Production backend, queue schema, and comment replay behavior.

## Proof

- `cd apps/mobile && flutter test test/features/social_feed_demo/data/`
- `./tool/analyze.sh`
- `./bin/checklist`
