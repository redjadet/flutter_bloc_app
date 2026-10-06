# Flutter CLI → repo wrapper crosswalk (human onboarding)

## Why

Generic Flutter CLI “pro commands” articles teach `flutter create`, bare
`pub get` / `analyze` / `test`, and casual `flutter upgrade` / `channel`. This
monorepo already routes day-to-day work through wrappers and pins Flutter
**3.47.6**. Humans lacked a short map from raw CLI habits → repo entrypoints
(agents already had pin-sync prefs).

## What changed

- [`new_developer_guide.md`](../new_developer_guide.md) § Raw Flutter CLI → this repo
- FAQ + contributing pointers (no duplicate cheat sheet)
- Official links: [flutter CLI](https://docs.flutter.dev/reference/flutter-cli),
  [dart pub](https://dart.dev/tools/pub/cmd)

## Explicitly not done

- No invent-product features
- No restatement of the full official CLI table
- No paraphrase of unread Medium paywall body
