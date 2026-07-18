# Firebase UI Auth – EditableUserDisplayName overflow fix

The Firebase UI Auth package’s `EditableUserDisplayName` widget can cause a **RenderFlex overflow** when the display name is long (e.g. a wallet address set by the [WalletConnect Auth](walletconnect_auth_status.md) demo and shown on the **Auth profile screen**).

## Fix applied

The fix is applied in the package copy in your pub cache:

- **File:** `$PUB_CACHE/hosted/pub.dev/firebase_ui_auth-<version>/lib/src/widgets/editable_user_display_name.dart`
- **Change:** In the non-editing state, the display name row uses `Expanded` + `Text(..., maxLines: 1, overflow: TextOverflow.ellipsis)` instead of `IntrinsicWidth` + `Subtitle`, so long names are ellipsized instead of overflowing.

## Re-applying after `flutter pub get`

This file lives in the pub cache, so **`flutter pub get` will overwrite the change**. To fix overflow again:

1. Open the file above (replace `<version>` with your `firebase_ui_auth` version from `pubspec.lock`, e.g. `3.0.1`).
2. Find the block that starts with `if (!_editing) {` and the `return Padding(... IntrinsicWidth(... Row( children: [ Subtitle(...` part.
3. Replace that whole block with a `Row` that has `Expanded(child: Text(displayName ?? 'Unknown', style: ..., maxLines: 1, overflow: TextOverflow.ellipsis))` and the same `iconButton`, and remove the `IntrinsicWidth` and `Subtitle` usage.

Alternatively, consider opening a PR or issue on [firebase_ui_auth](https://github.com/firebase/FirebaseUI-Flutter) so the fix can be merged upstream.
