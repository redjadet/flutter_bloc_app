# iOS simulator: real Firebase Auth via signed Runner (no Keychain Sharing)

**Date:** 2026-08-08

## Summary

- **Root cause (Auth):** Simulator Runner had `CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]=NO`, so the binary was unsigned and Firebase Auth hit Keychain `-34018` / `keychain-error`.
- **Root cause (launch denial):** Injecting `keychain-access-groups` into the simulator `.xcent` (even with Apple Development signing) causes `FBSOpenApplicationServiceErrorDomain` / `SBMainWorkspace` launch denial on current simulator runtimes.
- **Fix:** Re-enable Runner code signing for simulator; keep CocoaPods framework embed unsigned. Simulator build phase writes an **empty** `.xcent` and deletes stale `.xcent.der` so CodeSign does not embed Keychain Sharing. Signed empty-entitlement Runner launches and can use Keychain for Firebase Auth.
- **RTDB:** Stop omitting remotes on iOS simulator debug (macOS debug still omits). Local-guest Keychain fallback remains as safety net.
- **Docs:** [`authentication.md`](../authentication.md), [`firebase_setup.md`](../integrations/firebase_setup.md) troubleshooting, FN-10.

## Verification

```bash
flutter test test/app/composition/injector_helpers_test.dart test/app/composition/register_auth_services_test.dart
./bin/router_feature_validate
flutter build ios --simulator --debug
bash tool/check_ios_pod_framework_embed.sh --require-built-app
codesign -d --entitlements :- apps/mobile/build/ios/iphonesimulator/Runner.app  # expect empty dict
xcrun simctl uninstall <udid> com.example.flutterBlocApp
xcrun simctl install <udid> apps/mobile/build/ios/iphonesimulator/Runner.app
xcrun simctl launch <udid> com.example.flutterBlocApp
```

Manual: quit `flutter run`, uninstall app from simulator if needed, cold start → email/anonymous sign-in without `keychain-error`.
