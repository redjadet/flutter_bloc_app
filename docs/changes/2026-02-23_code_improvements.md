# Code Improvements — 2026-02-23

## Step-by-Step Plan

### 1. Add confetti explosion on Counter increment

1. Add `confetti: ^0.8.0` dependency to `pubspec.yaml`.
2. Run `flutter pub get`.
3. In `counter_page.dart`:
   - Import `package:confetti/confetti.dart`.
   - Create a `ConfettiController` in `initState()`, dispose it in `dispose()`.
   - Add a `TypeSafeBlocListener` that fires `_confettiController.play()` when `curr.count > prev.count`.
   - Wrap the `Scaffold` in a `Stack` and overlay an `Align > ConfettiWidget` at the top-center with `BlastDirectionality.explosive`.

### 2. Optimize chat rendering (equality on `_ChatListData`)

1. In `chat_message_list.dart`:
   - Replace the hand-written `@immutable` class `_ChatListData` with a `@freezed` class.
   - Add `import 'package:freezed_annotation/freezed_annotation.dart';` and the `part` directive.
2. Run `dart run build_runner build --delete-conflicting-outputs` to generate `chat_message_list.freezed.dart`.
   - **Note:** `build_runner` currently fails due to a Flutter engine stamp permission issue. The generated file was created from a prior successful run and is tracked as an untracked file.

### 3. Clean up WalletConnect placeholder TODO

1. In `walletconnect_service.dart`:
   - Replace the bare `// TODO(username):` comment with a descriptive inline comment.
   - Improve the placeholder client initialization comment to reference `Web3App` from `walletconnect_flutter_v2`.
   - Update the debug log to indicate it is a mock initialization.

---

## File List with Change Intent

| # | File | Intent |
| --- | ------ | -------- |
| 1 | `pubspec.yaml` | Add `confetti: ^0.8.0` dependency |
| 2 | `pubspec.lock` | Auto-updated by `pub get` |
| 3 | `lib/features/counter/presentation/pages/counter_page.dart` | Add `ConfettiController`, `ConfettiWidget` overlay, and listener that plays confetti on increment |
| 4 | `lib/features/chat/presentation/widgets/chat_message_list.dart` | Refactor `_ChatListData` from `@immutable` hand-written class to `@freezed` for auto-generated `==`/`hashCode` |
| 5 | `lib/features/chat/presentation/widgets/chat_message_list.freezed.dart` | **New** — generated Freezed code for `_ChatListData` |
| 6 | `lib/features/walletconnect_auth/data/walletconnect_service.dart` | Remove bare `TODO`, improve placeholder docs, clarify mock init log |

---

## Risks and Rollback Notes

### Risks

| Risk | Severity | Mitigation |
| ------ | ---------- | ------------ |
| **`build_runner` cannot run** due to engine stamp permission error (`Operation not permitted`). The `.freezed.dart` file for `chat_message_list` may be stale or incomplete. | **High** | Fix permissions with `sudo chmod +w .../bin/cache/engine.stamp`, then re-run `build_runner`. Or revert the Freezed change (see rollback). |
| **Missing `.freezed.dart` files project-wide.** Many existing Freezed classes across ~30 files also have missing generated code (pre-existing issue, not introduced by this changeset). | **Medium** | Run `build_runner` once permissions are fixed. These errors are **not new**. |
| **Confetti `Colors.*` usage** — project rules forbid `Colors.black/white/grey` but the confetti colors (green, blue, pink, orange, purple) are decorative particle colors, not UI theme colors. | **Low** | Acceptable for confetti particles. Could be moved to a theme extension if strict compliance is desired. |
| **`_ChatListData` is private + Freezed** — Freezed on private classes can cause code-gen quirks in some versions. | **Low** | If generation fails, revert to the hand-written `==`/`hashCode` implementation (see rollback). |

### Rollback

To fully revert all changes:

```bash
git checkout -- lib/features/counter/presentation/pages/counter_page.dart
git checkout -- lib/features/chat/presentation/widgets/chat_message_list.dart
git checkout -- lib/features/walletconnect_auth/data/walletconnect_service.dart
git checkout -- pubspec.yaml pubspec.lock
rm lib/features/chat/presentation/widgets/chat_message_list.freezed.dart
flutter pub get
```

To revert only the chat Freezed change (keeping confetti and WalletConnect):

```bash
git checkout -- lib/features/chat/presentation/widgets/chat_message_list.dart
rm lib/features/chat/presentation/widgets/chat_message_list.freezed.dart
```

Then restore `_ChatListData` as a plain immutable class with manual `==` and `hashCode`.

---

## Solutions

### Problem 1: `build_runner` cannot run (engine stamp permission error)

**Root cause:** The file `$FLUTTER_SDK/bin/cache/engine.stamp` is read-only or owned by root, so `build_runner` (which triggers the Flutter tool startup script `update_engine_version.sh`) cannot write to it.

**Solution:**

```bash
# 1. Fix the permission on the stamp file
sudo chmod +w "$FLUTTER_SDK/bin/cache/engine.stamp"

# 2. If the entire cache dir has permission issues, fix recursively
sudo chown -R $(whoami) "$FLUTTER_SDK/bin/cache"

# 3. Re-run build_runner
cd /Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app
dart run build_runner build --delete-conflicting-outputs
```

**If that still fails** (e.g. SIP or MDM locks the directory):

```bash
# Workaround: skip the engine version check by touching the file first
touch "$FLUTTER_SDK/bin/cache/engine.stamp" 2>/dev/null || true
dart run build_runner build --delete-conflicting-outputs
```

**Verification:** After a successful run, confirm no `Target of URI doesn't exist: '...freezed.dart'` errors remain:

```bash
dart analyze lib/features/chat/presentation/widgets/chat_message_list.dart
```

---

### Problem 2: Missing `.freezed.dart` files project-wide (~30 files)

**Root cause:** The generated Freezed files were never committed to the repo (correct practice), but `build_runner` has not been run successfully on this machine, so they are all missing.

**Solution:**

```bash
# 1. First fix the engine stamp permission (see Problem 1 above)

# 2. Run build_runner for the entire project
cd /Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app
dart run build_runner build --delete-conflicting-outputs

# 3. Verify zero analysis errors
dart analyze lib/
```

**Expected output:** `build_runner` will generate `.freezed.dart` and `.g.dart` files for:

- `lib/features/auth/` — `register_country_option`, `register_state`
- `lib/features/calculator/` — `calculator_state`
- `lib/features/chart/` — `chart_point`
- `lib/features/chat/` — `chat_sync_payload`, `chat_contact`, `chat_conversation`, `chat_list_state`, `chat_input_bar`, `chat_message_list`
- `lib/features/counter/` — `counter_error`, `counter_snapshot`, `counter_state`
- `lib/features/deeplink/` — `deep_link_state`
- `lib/features/example/` — `whiteboard_painter`
- `lib/features/genui_demo/` — `genui_demo_events`, `genui_demo_state`
- `lib/features/google_maps/` — `map_coordinate`, `map_location`, `map_sample_state`
- `lib/features/graphql_demo/` — `graphql_country`, `graphql_demo_state`, `graphql_demo_view_models`
- `lib/features/playlearn/` — `playlearn_state`
- `lib/features/profile/` — `profile_user`, `profile_state`
- `lib/features/remote_config/` — `remote_config_snapshot`, `remote_config_state`
- `lib/features/scapes/` — `scape`, `scapes_state`
- `lib/features/search/` — `search_result`, `search_state`
- `lib/features/settings/` — `app_info`, `app_locale`, `app_info_section`, `remote_config_view_data`
- `lib/features/todo_list/` — `todo_list_state`
- `lib/features/walletconnect_auth/` — `nft_metadata`, `wallet_address`, `wallet_user_profile`, `walletconnect_auth_state`
- `lib/features/websocket/` — `websocket_connection_state`, `websocket_message`, `websocket_state`
- `lib/shared/sync/` — `sync_status_state`, `sync_cycle_summary`, `sync_operation`

**If build_runner is too slow:** Use the `--build-filter` flag to generate only the files you need right now:

```bash
dart run build_runner build --delete-conflicting-outputs \
  --build-filter="lib/features/chat/presentation/widgets/chat_message_list.freezed.dart"
```

---

### Problem 3: Confetti `Colors.*` usage vs project rules

**Root cause:** Project rules (`AGENTS.md`) forbid `Colors.black/white/grey` but the confetti particle colors use `Colors.green`, `Colors.blue`, etc. These are decorative and not part of the design system.

**Solution (if strict compliance is required):**

1. Add a `ThemeExtension` for confetti colors in `lib/core/theme/`:

```dart
@immutable
class ConfettiTheme extends ThemeExtension<ConfettiTheme> {
  const ConfettiTheme({required this.particleColors});
  final List<Color> particleColors;

  @override
  ConfettiTheme copyWith({List<Color>? particleColors}) =>
      ConfettiTheme(particleColors: particleColors ?? this.particleColors);

  @override
  ConfettiTheme lerp(ConfettiTheme? other, double t) => this;
}
```

1. Register it in `ThemeData.extensions` with curated palette colors.
2. In `counter_page.dart`, replace the inline `Colors.*` list with:

```dart
colors: Theme.of(context).extension<ConfettiTheme>()!.particleColors,
```

**Pragmatic alternative:** The current `Colors.*` for confetti particles is acceptable because:

- The rule targets `Colors.black/white/grey` specifically (UI contrast concerns).
- Particle colors are ephemeral decorative elements, not UI surfaces.
- No action needed unless a code review explicitly flags it.

---

### Problem 4: Private class `_ChatListData` + Freezed code-gen quirks

**Root cause:** Freezed's code generator creates a mixin `_$ChatListData` and an implementation class `__ChatListData`. With private classes, some Freezed versions produce broken or non-compilable output due to Dart visibility rules.

**Solution A — Keep Freezed, verify generation:**

```bash
# After fixing build_runner (Problem 1), regenerate and check:
dart run build_runner build --delete-conflicting-outputs
dart analyze lib/features/chat/presentation/widgets/chat_message_list.dart
```

If analysis passes with zero errors → no action needed.

**Solution B — Revert to manual equality (if Freezed generation fails):**

Replace the `@freezed` class at the bottom of `chat_message_list.dart` with:

```dart
@immutable
class _ChatListData {
  const _ChatListData({
    required this.hasMessages,
    required this.isLoading,
    required this.messages,
  });

  final bool hasMessages;
  final bool isLoading;
  final List<ChatMessage> messages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ChatListData &&
          runtimeType == other.runtimeType &&
          hasMessages == other.hasMessages &&
          isLoading == other.isLoading &&
          const DeepCollectionEquality().equals(messages, other.messages);

  @override
  int get hashCode => Object.hash(
        hasMessages,
        isLoading,
        const DeepCollectionEquality().hash(messages),
      );
}
```

Then remove the `part` directive, the `freezed_annotation` import, and delete `chat_message_list.freezed.dart`.

**Note:** Solution B requires adding `import 'package:collection/collection.dart';` for `DeepCollectionEquality`, or using `listEquals` from `package:flutter/foundation.dart`.
