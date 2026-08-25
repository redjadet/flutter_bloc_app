# 2026-08-25 — Social feed synced likes survive process restart

## Why

Online / dispatched likes lived only in the simulated remote’s in-memory map.
Recreating the remote (hot restart) lost `isLikedByMe` even after queue drain.
Comments already hydrated from Hive; likes did not.

## Scope

- Persist viewer likes via Hive (`likes:v1`) after online `setLiked` and after
  successful like dispatch; hydrate beside comment threads on startup.
- Patch first-page cache after apply so cached reads stay consistent.
- Split over-long Hive/remote data sources into `*_likes` / `*_persist` parts
  for `file_length_lint` (max 225).
- Stabilize offline-dispatch unit test: pump event queue until pending count
  is zero before asserting drain.

## Proof

- `flutter test test/features/social_feed_demo/data/` (incl. synced + dispatched
  offline likes survive remote recreation)
- `bash tool/run_file_length_lint.sh`
- CI `build` delivery checklist Step 4 (feature brief linked)
