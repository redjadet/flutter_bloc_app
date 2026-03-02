# FCM Demo Integration

This document describes the Firebase Cloud Messaging (FCM) demo feature: setup, scope, and how to test it on Android, iOS device, and iOS Simulator.

## Execution checklist (before finish)

Before considering the FCM demo integration complete, ensure:

- [ ] **Analyze:** `flutter analyze` (or `./tool/analyze.sh`) passes with no issues.
- [ ] **Checklist:** `./bin/checklist` passes (format, analyze, tests, and project guards).
- [ ] **Coverage:** Run `dart run tool/update_coverage_summary.dart` and commit updated `coverage/coverage_summary.md` if coverage changed.
- [ ] **iOS (manual):** In Xcode, Runner target has **Push Notifications** and **Background Modes** (Background fetch, Remote notifications) enabled.
- [ ] **Optional:** Add or run unit/cubit/widget tests for the FCM demo; add regression tests for lifecycle/stream guards if you changed subscription or dispose behavior.

## Setup

### Android

- Ensure the `com.google.gms.google-services` plugin is applied in `android/app/build.gradle` and that `google-services.json` exists under `android/app/` (from your Firebase project).
- The demo adds `android.permission.POST_NOTIFICATIONS` for Android 13+ in `AndroidManifest.xml`.

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Add **Push Notifications**.
4. Add **Background Modes** and enable **Background fetch** and **Remote notifications**.

No APNs authentication key or certificates are configured as part of this demo.

## Demo scope

- **Android:** Full FCM (foreground, background, terminated). Use Firebase Console to send a test message to the device token shown on the FCM demo page.
- **iOS device:** Permission and token retrieval work. Without an APNs key in Firebase Console, background/terminated delivery is not guaranteed.
- **iOS Simulator:** Real FCM/APNs is not available. Use the simulated push flow below.

## Sending a test notification (Android / iOS with APNs)

1. Run the app and open the FCM demo from the Example page.
2. Grant notification permission and copy the FCM token.
3. In Firebase Console: **Engage** → **Messaging** → **Create campaign** → **Firebase Notification messages**.
4. Enter title/body, then **Send test message** → paste the FCM token → **Test**.

## Testing on iOS Simulator

Real FCM is not used on the iOS Simulator. You can still simulate a remote notification so the app’s handling (e.g. “Last message”, open from notification) can be tested.

1. **Prepare the .apns file**
   - Use `docs/fcm_demo_simulator.apns` or `tool/fcm_demo_simulator.apns`. Both are pre-filled with this project’s bundle ID (`com.example.flutterBlocApp`).
   - If your app uses a different bundle ID, edit the `"Simulator Target Bundle"` value to match it (Xcode → Runner target → General → Bundle Identifier).

2. **Run the app on the iOS Simulator**
   - Install and run the app at least once (e.g. `flutter run` or Run from Xcode) so the app is on the simulator.

3. **Deliver the notification**
   - **Drag-and-drop:** Drag `docs/fcm_demo_simulator.apns` or `tool/fcm_demo_simulator.apns` onto the **simulator window** (not Xcode). The bundle ID is already set for this project.
   - **Command line (recommended):** Bundle ID is passed explicitly, so you don’t rely on the file content:

     ```bash
     xcrun simctl push booted <YOUR_BUNDLE_ID> <path/to/fcm_demo_simulator.apns>
     ```

     Example if bundle ID is `com.example.flutterBlocApp` and the file is in the project root:

     ```bash
     xcrun simctl push booted com.example.flutterBlocApp tool/fcm_demo_simulator.apns
     ```

4. **Where to see the notification**
   - **Background or terminated:** Notification appears in the simulator’s **Notification Center** (swipe down from the top of the screen) or on the **lock screen**. Tap it to open the app.
   - **Foreground:** Some simulator/iOS versions do not show a banner when the app is in foreground; the app may still receive the payload. Open the FCM demo page to see “Last message” after the push.
   - **Logs:** Run the app from Xcode or `flutter run` and watch the console; when the notification is delivered or tapped, your app’s code (and any `print`/logging) will run.

## Troubleshooting: Nothing appears when dragging .apns onto simulator

- **Bundle ID mismatch:** The provided `.apns` files use `com.example.flutterBlocApp`. If your app uses a different bundle ID, edit `"Simulator Target Bundle"` in the file, or use the command line and pass your bundle ID as the second argument.
- **Last message empty:** The payload must include `"gcm.message_id"` so the Firebase plugin forwards the simulated push to Flutter. The provided `.apns` files already have this. Without it, the system shows the notification but the app does not receive the payload.
- **App not installed:** Run the app on the simulator once so the app is installed; simulated push targets the app by bundle ID.
- **Where to look:** Check Notification Center (swipe down from top) and lock screen; simulated push does not always show a banner if the app is in the foreground.
- **Command line instead of drag-and-drop:** Use `xcrun simctl push booted <BUNDLE_ID> <path/to/file.apns>` so the bundle ID is explicit and the file does not need to contain it.
