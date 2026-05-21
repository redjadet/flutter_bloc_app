# Firebase secret scanning and history scrub (2026-05-21)

## Context

GitHub secret scanning flagged Google API keys that had been committed in
`lib/firebase_options.dart` and CI plist paths. `main` was later fixed to use
placeholders plus `.envrc` / `--dart-define`, but old commits still contained
literal `AIzaSy…` keys.

## What changed

- **Current tree:** `lib/firebase_options.dart` stays a committed
  `String.fromEnvironment('FIREBASE_*', …)` placeholder; real keys live in
  gitignored `.envrc` and platform files.
- **Local regen:** `flutterfire configure` → copy values to `.envrc` →
  `git checkout HEAD -- lib/firebase_options.dart` (documented in
  [`docs/firebase_setup.md`](../firebase_setup.md)).
- **History scrub:** `git filter-repo --replace-text tool/firebase_secret_history_replacements.txt`
  rewrites all refs (`AIzaSy…` → `REDACTED_GOOGLE_API_KEY`). Requires coordinated
  `git push --force --all origin` and collaborator re-clones.
- **Guard:** [`tool/check_tracked_secret_literals.sh`](../../tool/check_tracked_secret_literals.sh)
  in delivery checklist.

## Docs updated

- [`docs/firebase_setup.md`](../firebase_setup.md) — Option A step 3b, secret scanning + filter-repo
- [`docs/security_and_secrets.md`](../security_and_secrets.md) — Firebase artifact table, history note
- [`docs/firebase_app_distribution.md`](../firebase_app_distribution.md) — `firebase_options.dart` row
- [`docs/validation_scripts.md`](../validation_scripts.md) — pointer to history scrub tool

## Operator follow-up

- Rotate restricted Firebase/Google API keys in GCP if alerts were `publicly_leaked`.
- Force-push rewritten history when ready (not done automatically by doc/tooling work).
