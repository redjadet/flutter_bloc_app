# Firebase App Distribution – Pre-release Distribution

This document describes how to distribute **pre-release** versions of this Flutter app (iOS and Android) to testers using **Firebase App Distribution**. Use it for internal QA, beta testers, or staging builds before store release.

## Overview

- **Firebase App Distribution** lets you upload builds (APK/AAB for Android, IPA for iOS) and invite testers by email or group. Testers get an email with a link to install the app.
- This project already uses Firebase (Auth, Crashlytics, Remote Config, etc.) and has a Firebase project configured (`flutter-bloc-app-697e8`). App Distribution uses the same project and app registrations.
- Builds are retained for **150 days**; testers have **30 days** to accept an invitation.

## Prerequisites

1. **Firebase project** – Already set up for this app (see [firebase.json.example](../firebase.json.example); copy to gitignored `firebase.json` locally — [WalletConnect Auth Status](walletconnect_auth_status.md)).
2. **Firebase CLI** – Install or update the [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli) (standalone binary recommended). Sign in, select this repo’s default project (from [`.firebaserc`](../.firebaserc)), then confirm access:

   ```bash
   firebase login
   firebase use flutter-bloc-app-697e8
   firebase projects:list
   ```

   Before distributing, you can verify the CLI project and iOS App ID match this checkout:

   ```bash
   ./tool/firebase_preflight.sh --require-cli --app-id "1:473097776453:ios:6962f6ddc4d7ea12bd222c"
   ```

3. **Flutter** – Release builds require a configured Flutter environment and, for iOS, Xcode and signing.
4. **Firebase App IDs** – You will need the **App ID** for each platform (not the project ID). Find them in [Firebase Console → Project Settings → General](https://console.firebase.google.com/project/_/settings/general/). For this project they are:
   - **Android**: `1:473097776453:android:80db6a1c2b04bfc0bd222c`
   - **iOS**: `1:473097776453:ios:6962f6ddc4d7ea12bd222c`

## Firebase Console Setup

1. Open [Firebase Console](https://console.firebase.google.com/) → your project (`flutter-bloc-app-697e8`).
2. In the left sidebar, go to **Release & Monitor → App Distribution** (or **Build → App Distribution** depending on console layout). If prompted, enable App Distribution for the project.
3. **Add testers** (optional if you will use CLI-only):
   - **Testers**: Add email addresses of people who should receive builds.
   - **Groups**: Create groups (e.g. `qa-team`, `beta-testers`) and add testers to them. Use the **group alias** (e.g. `qa-team`) when distributing via CLI with `--groups`.

You can also manage testers and groups from the CLI (see [Manage testers and groups (CLI)](#manage-testers-and-groups-cli) below).

## Firebase CLI – Install and sign in

- **Install**: Prefer the [standalone binary](https://firebase.google.com/docs/cli#install_the_firebase_cli) for your OS.
- **Sign in** (interactive):

  ```bash
  firebase login
  ```

- **CI / automation**: Use a [Firebase CI token](https://firebase.google.com/docs/cli#cli-ci-systems) or [service account](https://firebase.google.com/docs/app-distribution/authenticate-service-account):

  ```bash
  firebase login:ci
  # Use the printed token as: --token "$FIREBASE_TOKEN"
  ```

## Distributing Android builds (Flutter)

### Pre-release checklist (Android)

Before distributing an Android pre-release via Firebase App Distribution, confirm:

| Check | Action |
| ------ | ------ |
| **Firebase project** | Project is set up; Android app is registered. See [firebase.json.example](../firebase.json.example) (local `firebase.json` is gitignored) and [Firebase Console](https://console.firebase.google.com/). |
| **google-services.json** | File exists at `android/app/google-services.json` (gitignored; generate via [FlutterFire CLI](https://firebase.flutter.dev/docs/overview#1-install-the-flutterfire-cli): `flutterfire configure`). |
| **firebase_options.dart** | Committed placeholder at `lib/firebase_options.dart`; local `FIREBASE_*` in `.envrc` (see [Firebase setup](firebase_setup.md)). Run `flutterfire configure` for platform files, then restore the placeholder Dart file (step 3b). |
| **Firebase CLI** | Installed and signed in: `firebase login`; `firebase projects:list` shows your project. |
| **Release build succeeds** | Run `flutter build apk --release` (or `appbundle`). Fix any build errors (e.g. [Namespace not specified](#namespace-not-specified-android) below) before distributing. |
| **Android App ID** | Use the App ID from Firebase Console (e.g. `1:473097776453:android:80db6a1c2b04bfc0bd222c`) in `--app` when distributing. |

Then build, then run `firebase appdistribution:distribute` with your APK/AAB path, `--app`, `--release-notes`, and `--testers` or `--groups`.

### 1. No paid Google subscription required

**No.** You do **not** need a paid Google Play Developer account to run or distribute pre-release Android builds on real devices.

| Scenario | Paid subscription |
| ------ | ------ |
| Run on **your** device (debug or release) | Not required. Sign with debug keystore or your own release keystore. |
| **Distribute** to testers (Firebase App Distribution, sideloading) | Not required. Build a signed APK/AAB and upload or share it. |
| Publish on **Google Play Store** | One-time [Play Console registration](https://play.google.com/console/signup) fee ($25); no recurring subscription. |

For Firebase App Distribution you only need a signed build (debug or release keystore) and your Firebase project; no Google Play or paid Android developer fee is required.

### 2. Build the app

You must ship a **signed** APK or AAB. For pre-release, an APK is often simplest; App Distribution supports both.

**Option A – APK (typical for internal QA):**

```bash
# From project root
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

**Option B – App Bundle (same as Play store artifact):**

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Environment-specific entry point (optional):**

This project supports multiple entry points ([deployment](deployment.md)). For a staging pre-release you might use:

```bash
flutter build apk --release -t lib/main_staging.dart
# or
flutter build apk --release -t lib/main_dev.dart
```

### 3. Distribute via Firebase CLI

Replace `YOUR_ANDROID_APP_ID` with your Android App ID (e.g. `1:473097776453:android:80db6a1c2b04bfc0bd222c`).

**By tester emails:**

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_ANDROID_APP_ID \
  --release-notes "Pre-release build for QA - $(date +%Y-%m-%d)" \
  --testers "tester1@example.com,tester2@example.com"
```

**By tester group:**

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_ANDROID_APP_ID \
  --release-notes "Staging build" \
  --groups "qa-team"
```

**Using files for testers and release notes:**

```bash
# testers.txt: comma-separated emails
# release_notes.txt: plain text
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_ANDROID_APP_ID \
  --release-notes-file release_notes.txt \
  --testers-file testers.txt
```

If you use **AAB** instead of APK, use the path to `app-release.aab` in the same way.

After a successful upload, the CLI prints links (e.g. `testing_uri`, `binary_download_uri`) that testers can use to install the app.

---

## Distributing iOS builds (Flutter)

### 1. Apple Developer account required

**Yes. You need an active paid Apple Developer Program membership** to distribute pre-release iOS builds to real devices and run them on testers’ devices.

| Scenario | Paid Apple Developer ($99/year) |
| ------ | ------ |
| Run on **simulator** only | Not required (free Apple ID is enough). |
| Run on **your own** device (development) | Free Apple ID allows 7-day provisioning; no Ad Hoc distribution. |
| **Distribute** to other testers (Firebase App Distribution, Ad Hoc/Enterprise) | **Required.** Ad Hoc and Enterprise provisioning are only available with a paid account. |

- **Paid account** gives you Ad Hoc provisioning (register device UDIDs, distribute to testers) and, if applicable, Enterprise distribution.
- Without it, you cannot create distribution provisioning profiles or ship IPAs that install on other people’s devices. Firebase App Distribution for iOS therefore assumes you have an active [Apple Developer Program](https://developer.apple.com/programs/) subscription.

### 2. Signing and provisioning

- iOS builds for testers must be signed with a **distribution** profile. Use either:
  - **Ad Hoc** – for a limited set of registered device UDIDs, or
  - **Enterprise** – if you have an Apple Developer Enterprise account.
- Ensure your **App ID**, **Provisioning Profile**, and **Distribution Certificate** are set up in Xcode (or via Fastlane). For App Distribution, the provisioning profile must include the devices (or be Enterprise).

### 3. Build an IPA

**Important:** Before building for Ad Hoc or App Store, switch to distribution entitlements (includes Associated Domains for universal links). Personal Apple accounts cannot use Associated Domains; distribution requires a paid Apple Developer Program membership.

```bash
./tool/ios_entitlements.sh distribution
```

**Option A – Flutter:**

```bash
flutter build ipa
```

This produces an IPA in `build/ios/ipa/` (exact path may vary; check the command output). You can specify the entry point:

```bash
flutter build ipa -t lib/main_staging.dart
```

**Option B – Xcode:**

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select **Product → Archive**.
3. In the Organizer, **Distribute App** → **Ad Hoc** (or **Enterprise**) → export IPA.

**Option C – Fastlane (Ad Hoc IPA):**

From the project root, run `./tool/fastlane.sh ios adhoc`. The IPA is exported under `build/ios/`. See [Deployment – iOS (TestFlight and App Store)](deployment.md#ios-testflight-and-app-store) for all iOS lanes (`adhoc`, `upload_testflight`, `upload_appstore`). For TestFlight + Play in one step, see [Deployment – Both stores](deployment.md#both-stores-ios--android).

Use the path to the exported `.ipa` file in the next step.

### 4. Distribute via Firebase CLI

Replace `YOUR_IOS_APP_ID` with your iOS App ID (e.g. `1:473097776453:ios:6962f6ddc4d7ea12bd222c`).

```bash
firebase appdistribution:distribute path/to/YourApp.ipa \
  --app YOUR_IOS_APP_ID \
  --release-notes "iOS pre-release - $(date +%Y-%m-%d)" \
  --testers "tester1@example.com,tester2@example.com"
```

Or with groups:

```bash
firebase appdistribution:distribute path/to/YourApp.ipa \
  --app YOUR_IOS_APP_ID \
  --release-notes-file release_notes.txt \
  --groups "qa-team,beta-testers"
```

Testers receive an email with a link. On iOS they may need to **trust the developer** (Settings → General → VPN & Device Management) and have their device **registered** in your Apple Developer account for Ad Hoc builds.

### iOS upload script

[`tool/upload_ios_to_firebase_app_distribution.sh`](../tool/upload_ios_to_firebase_app_distribution.sh) is what the Fastlane lane `ios firebase_distribute` runs after building the IPA. It:

- Runs [`tool/firebase_preflight.sh`](../tool/firebase_preflight.sh) with `--require-cli` and the iOS App ID (default: `1:473097776453:ios:6962f6ddc4d7ea12bd222c`, overridable via `FIREBASE_IOS_APP_ID`).
- Passes **`--groups`** or **`--testers`** to `firebase appdistribution:distribute` as follows:
  - If **`FIREBASE_GROUPS`** or **`FIREBASE_TESTERS`** is set in the environment, those flags are used (both can be set if you call the script manually and need both).
  - Otherwise, the **third script argument** (recipient string from Fastlane) is interpreted as **group aliases** when it does **not** contain `@`, and as **comma-separated tester emails** when it **does** contain `@` (so `FIREBASE_TESTERS` flows to `--testers`, not `--groups`).

You can also run the script directly (after `flutter build ipa`):

```bash
./tool/upload_ios_to_firebase_app_distribution.sh path/to/App.ipa "Release notes" qa-team
# or with tester emails:
./tool/upload_ios_to_firebase_app_distribution.sh path/to/App.ipa "Release notes" "a@example.com,b@example.com"
```

---

## Flutter project notes (what’s specific to this repo)

This doc stays focused on **Firebase App Distribution**. Shared build concepts
(entry points, entitlements, and release preparation) are centralized in
[Deployment](deployment.md).

| Item | Notes |
| ------ | ------ |
| **Firebase config** | Platform files (`google-services.json`, `GoogleService-Info.plist`) are gitignored — generate via `flutterfire configure`. Dart uses committed `lib/firebase_options.dart` placeholders plus local `FIREBASE_*` in `.envrc`. CI template: `ios/ci/GoogleService-Info.plist` (placeholder API keys only). See [Firebase setup](firebase_setup.md). |
| **Build output paths** | Android: `build/app/outputs/flutter-apk/app-release.apk` or `build/app/outputs/bundle/release/app-release.aab`. iOS: use the path printed by `flutter build ipa` or your Xcode export. |
| **iOS upload + project guard** | `tool/upload_ios_to_firebase_app_distribution.sh` runs `firebase_preflight.sh` so the active Firebase CLI project matches `.firebaserc` and the `--app` id belongs to that project. |

---

## One-shot scripts (Android and iOS)

You can save these as shell scripts (e.g. `script/distribute_android.sh`, `script/distribute_ios.sh`) and pass release notes and testers as arguments.

**Android example:**

```bash
#!/usr/bin/env bash
# script/distribute_android.sh
set -e
ANDROID_APP_ID="1:473097776453:android:80db6a1c2b04bfc0bd222c"
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$ANDROID_APP_ID" \
  --release-notes "${1:-Pre-release Android build}" \
  --groups "${2:-qa-team}"
```

**iOS example:**

```bash
#!/usr/bin/env bash
# script/distribute_ios.sh
set -e
IOS_APP_ID="1:473097776453:ios:6962f6ddc4d7ea12bd222c"
./tool/ios_entitlements.sh distribution   # Restore Associated Domains for Ad Hoc
flutter build ipa
IPA_PATH=$(find build/ios -name "*.ipa" | head -1)
# Prefer the repo helper (preflight + correct --groups vs --testers):
./tool/upload_ios_to_firebase_app_distribution.sh "$IPA_PATH" "${1:-Pre-release iOS build}" "${2:-qa-team}"
# Or call firebase directly, e.g. --groups "qa-team" or --testers "a@x.com,b@y.com"
# Optional: ./tool/ios_entitlements.sh development   # Revert for local runs
```

---

## Manage testers and groups (CLI)

- **Add testers**: `firebase appdistribution:testers:add tester@example.com` (space-separated emails). Optional: `--file /path/to/testers.txt`.
- **Remove testers**: `firebase appdistribution:testers:remove tester@example.com`.
- **Create a group**: `firebase appdistribution:group:create "QA team" qa-team` (display name + alias).
- **Add testers to a group**: `firebase appdistribution:testers:add --group-alias=qa-team a@example.com b@example.com`.
- **Delete a group**: `firebase appdistribution:group:delete qa-team`.

Group aliases (e.g. `qa-team`) are what you pass to `--groups` when distributing.

---

## Fastlane lanes (firebase_distribute)

This project has **Fastlane lanes** that build and upload to Firebase App Distribution. Run from the **project root** (not inside `ios/` or `android/`).

### Android

```bash
bundle install
./tool/fastlane.sh android firebase_distribute
```

**Options (env or lane params):**

- `FIREBASE_RELEASE_NOTES` or `release_notes:` – Release notes (default: timestamp).
- `FIREBASE_GROUPS` or `groups:` – Comma-separated group aliases (e.g. `qa-team`).
- `FIREBASE_TESTERS` or `testers:` – Comma-separated tester emails.
- `FIREBASE_SKIP_BUILD=true` or `skip_build: true` – Upload an existing APK/AAB only.
- `FIREBASE_USE_APK=false` – Use AAB instead of APK (default: APK).
- `FIREBASE_ANDROID_APP_ID` – Override Firebase Android App ID.

**Example with options:**

```bash
FIREBASE_GROUPS=qa-team FIREBASE_RELEASE_NOTES="Staging build" ./tool/fastlane.sh android firebase_distribute
```

### iOS

```bash
bundle install
./tool/fastlane.sh ios firebase_distribute
```

**Options (env or lane params):**

- `FIREBASE_RELEASE_NOTES` or `release_notes:` – Release notes (default: timestamp).
- `FIREBASE_GROUPS` or `groups:` – Comma-separated group aliases (passed to Firebase CLI as `--groups`).
- `FIREBASE_TESTERS` or `testers:` – Comma-separated tester emails (passed as `--testers`). The lane forwards a single recipient string to `upload_ios_to_firebase_app_distribution.sh`; if you use **groups** in the lane, set `FIREBASE_GROUPS` (or `groups:`). If you use **testers**, set `FIREBASE_TESTERS` (or `testers:`). When only one is set, that value is used; the upload script maps emails to `--testers` and group aliases to `--groups` (see [iOS upload script](#ios-upload-script) above).
- `FIREBASE_SKIP_BUILD=true` or `skip_build: true` – Upload an existing IPA only (IPA must already exist under `build/ios/`).
- `FIREBASE_DISTRIBUTION_ENTITLEMENTS=false` or `distribution_entitlements: false` – Skip switching to distribution entitlements (use if building with a personal Apple ID and you only have a pre-built IPA).
- `FIREBASE_IOS_APP_ID` – Override Firebase iOS App ID.

**Example with options:**

```bash
FIREBASE_GROUPS=qa-team ./tool/fastlane.sh ios firebase_distribute
```

```bash
FIREBASE_TESTERS="qa1@example.com,qa2@example.com" ./tool/fastlane.sh ios firebase_distribute
```

**Note:** iOS lane runs `tool/ios_entitlements.sh distribution` before building (requires paid Apple Developer account for IPA export). Set `FASTLANE_APP_IDENTIFIER` to your bundle ID before running (see `fastlane/Appfile` and `.env.ios.release.example`). To upload an IPA you built elsewhere, use `FIREBASE_SKIP_BUILD=true` and ensure the IPA is at `build/ios/ipa/Runner.ipa` or anywhere under `build/ios/**/*.ipa`.

For other iOS distribution (Ad Hoc IPA only, TestFlight upload, App Store upload), see [Deployment – iOS (TestFlight and App Store)](deployment.md#ios-testflight-and-app-store): `./tool/fastlane.sh ios adhoc`, `ios upload_testflight`, `ios upload_appstore`.

### CI

- Use `firebase login:ci` to get a token and set `FIREBASE_TOKEN`; the Firebase CLI will use it when run from Fastlane.
- Or use a [Firebase service account](https://firebase.google.com/docs/app-distribution/authenticate-service-account) for non-interactive uploads.

---

## Troubleshooting

| Issue | Suggestion |
| ------ | ---------- |
| **Firebase CLI not found** | Install the [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli) and ensure it’s on your `PATH`. |
| **Permission denied / not authorized** | Run `firebase login` and ensure your account has access to the project. In CI, check token or service account permissions. |
| **Active Firebase project mismatch** | Run `firebase use flutter-bloc-app-697e8` (see `.firebaserc`). `./tool/firebase_preflight.sh --require-cli --app-id "<your-ios-app-id>"` explains the failure. |
| **Wrong App ID** | Use the **App ID** from Firebase Console → Project Settings → General (e.g. `1:...:android:...` or `1:...:ios:...`), not the project ID. |
| **iOS: distributing to emails but install never offered** | Confirm you used **`--testers`** (emails) or **`--groups`** (aliases), not emails passed as `--groups`. The repo upload script maps this automatically; raw `firebase` CLI calls must pass the correct flag. |
| **iOS: “Unable to install”** | For Ad Hoc builds, the device UDID must be in the provisioning profile. Register devices in Apple Developer and regenerate the profile. |
| **Android: App not installing** | Ensure the APK/AAB is signed. Use `flutter build apk --release` or `flutter build appbundle --release` (with your signing config). |
| **Build path not found** | After `flutter build apk`, use `build/app/outputs/flutter-apk/app-release.apk`. After `flutter build ipa`, use the path shown in the output or under `build/ios/ipa/`. |
| **Namespace not specified (Android)** | Some plugins (e.g. `wallet_connect_v2`) lack `namespace` in their `build.gradle`; AGP 8+ requires it. See [Namespace not specified (Android)](#namespace-not-specified-android) below. |
| **iOS: "Personal development teams do not support the Associated Domains capability"** | You're using distribution entitlements with a free Apple ID. Run `./tool/ios_entitlements.sh development` for local runs. For Ad Hoc/App Store, use a paid [Apple Developer Program](https://developer.apple.com/programs/) account. |

### Namespace not specified (Android)

If `flutter build apk --release` fails with **"Namespace not specified"** in a dependency (e.g. `:wallet_connect_v2`), the plugin’s Android module has no `namespace` and AGP 8+ requires it. You can fix it from the **root** Android project by setting a default namespace for library subprojects.

**Recommended: Groovy** – If your root is `android/build.gradle.kts`, add a **new** file `android/build.gradle` (Groovy) containing only:

```gradle
subprojects { subproject ->
    subproject.afterEvaluate {
        if (subproject.plugins.hasPlugin("com.android.library")) {
            subproject.android {
                if (namespace == null || namespace.isEmpty()) {
                    namespace = (subproject.group ?: "unknown").toString() + ".android"
                }
            }
        }
    }
}
```

Gradle can use both `build.gradle` and `build.gradle.kts` in the same directory; the Groovy script runs and sets namespace for plugin modules that lack it. If your root is already `android/build.gradle` (Groovy), add the same `subprojects { ... }` block there.

Then run `flutter build apk --release` again. If the plugin’s `AndroidManifest.xml` uses a specific package, you can set that package as `namespace` for that subproject only (e.g. by checking `project.name == "wallet_connect_v2"` and setting the known package). Alternatively, upgrade the plugin when a version with a proper `namespace` is released.

---

## Summary

1. **Prerequisites**: Firebase project (done), Firebase CLI installed and logged in (`firebase use` must match [`.firebaserc`](../.firebaserc)), Flutter build environment (and iOS signing for IPA).
2. **Android**: `flutter build apk --release` (or `appbundle`) → `firebase appdistribution:distribute <apk-or-aab> --app <ANDROID_APP_ID> --release-notes "..." --testers "..."` or `--groups "..."`.
3. **iOS**: `flutter build ipa` (or Xcode archive) → `firebase appdistribution:distribute <path-to-ipa> --app <IOS_APP_ID> --release-notes "..." --testers "..."` or `--groups "..."`, or use [`tool/upload_ios_to_firebase_app_distribution.sh`](../tool/upload_ios_to_firebase_app_distribution.sh) / `./tool/fastlane.sh ios firebase_distribute` for preflight and correct `--testers` / `--groups` handling.
4. Use **tester groups** and **release-notes files** for repeatable pre-release distribution. Tie into Fastlane or CI using tokens or service accounts.

## Related documentation

- [Deployment](deployment.md) – Canonical build/entitlements notes and repo-first release commands.
- [Security and secrets](security_and_secrets.md) – How secrets are injected for builds (and what not to commit).
- [Firebase (WalletConnect Auth)](walletconnect_auth_status.md) – Firebase setup for this project.
- [Firebase App Distribution – Android CLI](https://firebase.google.com/docs/app-distribution/android/distribute-cli)
- [Firebase App Distribution – iOS CLI](https://firebase.google.com/docs/app-distribution/ios/distribute-cli)
