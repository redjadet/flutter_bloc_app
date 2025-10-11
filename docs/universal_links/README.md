# Universal Link Setup

The app expects universal links under `https://links.flutterbloc.app`. Host these files at the root of that domain to complete verification:

- `https://links.flutterbloc.app/.well-known/apple-app-site-association`
- `https://links.flutterbloc.app/.well-known/assetlinks.json`

Templates for both files live in this folder. Update the values (bundle identifiers, SHA-256 fingerprints) to match the build you are shipping, then deploy them to your domain.

## Verification Checklist

1. Deploy the files above without an extension and with the `application/json` MIME type.
2. Confirm that iOS receives the association via `applinks: links.flutterbloc.app` in the device logs (`defaults read com.apple.system.logger`).
3. Verify Android auto-verification with `adb shell dumpsys package domain-preferred-apps`.
4. Tap a sample link such as `https://links.flutterbloc.app/settings` on a real device. The app should launch (cold, warm, or foreground) and navigate directly to the requested page.
5. During development you can use the fallback scheme `flutter-bloc-app://settings` when a hosted domain is not available.
