# Deployment

This document describes the deployment process and release preparation steps.

## Deploy Flutter App to the App Store

This section provides a step-by-step guide to deploy this Flutter app to the Apple App Store.

### Prerequisites

| Requirement | Details |
| ----------- | ------- |
| **Apple Developer Program** | Paid membership ($99/year) required for App Store distribution |
| **Xcode** | Latest stable version (macOS only) |
| **Flutter** | Flutter 3.41.0+ with iOS support |
| **Firebase** | `GoogleService-Info.plist` in `ios/Runner/` (generate via `flutterfire configure`) |
| **Signing identity** | Distribution certificate and App Store provisioning profile |

### Step 1: App Store Connect Setup

1. **Create the app** (if not already created):
   - Go to [App Store Connect](https://appstoreconnect.apple.com/) → **My Apps** → **+** → **New App**
   - Fill in app name, primary language, bundle ID, SKU
   - Bundle ID must match `ios/Runner.xcodeproj` (e.g. `com.example.flutterBlocApp`)

2. **App information**:
   - Add screenshots (required sizes: 6.5", 5.5", iPad Pro 12.9" if supporting iPad)
   - Privacy policy URL
   - Support URL
   - Category and age rating

3. **Pricing and availability**:
   - Set price tier or free
   - Select countries/regions

### Step 2: Switch to Distribution Entitlements

Before building for App Store, use distribution entitlements (includes Associated Domains for deep links):

```bash
./tool/ios_entitlements.sh distribution
```

### Step 3: Prepare Release Build

```bash
# Scrub secrets and prepare release artifacts
dart run tool/prepare_release.dart

# Build release iOS (no archive yet)
flutter build ios --release
```

### Step 4: Archive and Upload

#### Option A – Xcode (manual)

1. Open the iOS project in Xcode:

   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select **Any iOS Device (arm64)** as the run destination (not a simulator).

3. **Product** → **Archive**. Wait for the archive to complete.

4. In the Organizer window: **Distribute App** → **App Store Connect** → **Upload** → follow the wizard.

5. Choose automatic signing (recommended) or manual signing with your distribution profile.

#### Option B – Fastlane (automated)

```bash
bundle install
bundle exec fastlane ios deploy
```

This automates archive, upload, and (optionally) submission to App Store Connect.

### Step 5: Submit for Review in App Store Connect

1. In App Store Connect → **My Apps** → your app → **App Store** tab.

2. Create a **new version** (or use the one created by the upload).

3. Fill in:
   - **What's New in This Version** (release notes)
   - **Promotional Text** (optional)
   - **Description**, **Keywords**, **Screenshots** (if not already set)
   - **Build**: Select the uploaded build from the build dropdown.

4. Answer **App Review Information** (contact, demo account if needed).

5. **Submit for Review**.

### Step 6: Post-Submission

- Monitor **App Store Connect** for review status and messages.
- Fix any issues reported by App Review and resubmit if needed.
- After approval, the app goes live according to your release setting (manual or automatic).

### Troubleshooting

| Issue | Solution |
| ----- | -------- |
| **Signing errors** | Ensure distribution certificate and App Store provisioning profile are valid in Xcode → Signing & Capabilities |
| **Associated Domains rejected** | Use `./tool/ios_entitlements.sh distribution` before building; personal Apple IDs cannot use Associated Domains |
| **Archive not appearing** | Build destination must be **Any iOS Device (arm64)**, not a simulator |
| **Upload fails** | Check bundle ID matches App Store Connect; verify `GoogleService-Info.plist` exists |
| **Missing compliance** | Answer export compliance, encryption, and content rights in App Store Connect |

### Related

- [iOS Entitlements (Development vs Distribution)](#ios-entitlements-development-vs-distribution) – Switch entitlements before App Store builds
- [Firebase App Distribution](firebase_app_distribution.md) – Pre-release testing before store submission
- [Security & Secrets](security_and_secrets.md) – API keys and secrets handling

---

## Deploy Flutter App to Google Play Store

This section provides a step-by-step guide to deploy this Flutter app to the Google Play Store.

### Google Play – Prerequisites

| Requirement | Details |
| ----------- | ------- |
| **Google Play Developer account** | One-time registration fee ($25); [Play Console](https://play.google.com/console/signup) |
| **Flutter** | Flutter 3.41.0+ with Android support |
| **Firebase** | `android/app/google-services.json` (generate via `flutterfire configure`) |
| **Signing** | Release keystore (`.jks` or `.keystore`); store credentials securely |

### Google Play – Step 1: Play Console Setup

1. **Create the app** (if not already created):
   - Go to [Google Play Console](https://play.google.com/console/) → **All apps** → **Create app**
   - Fill in app name, default language, and app or game type
   - Declare whether the app is free or paid

2. **Complete required sections** (dashboard checklist):
   - **App content**: Privacy policy, ads declaration (if applicable), content rating questionnaire, target audience, news app declaration (if applicable), COVID-19 contact tracing (if applicable)
   - **Policy**: App access, ads (if used), content rights, Developer Program Policies

3. **Store listing**:
   - Short and full description, graphics (icon, feature graphic, screenshots for phone and optionally tablet)
   - Category and contact details

### Google Play – Step 2: Configure App Signing

Play Store requires **App Signing by Google Play** (recommended) or your own upload key:

- **App Signing by Google Play**: Google holds the app signing key; you upload builds signed with an **upload key**. First upload: Play Console will prompt you to register the key (or create one).
- **Upload key**: Use a release keystore. Configure in `android/app/build.gradle` (or `build.gradle.kts`) under `android { signingConfigs { release { ... } } }`, or set `storeFile`/`storePassword`/`keyAlias`/`keyPassword` via environment or `key.properties` (gitignored).

Ensure `android/app/key.properties` (or your chosen path) is **not** committed. See [Security & Secrets](security_and_secrets.md).

### Google Play – Step 3: Prepare Release Build

```bash
# Scrub secrets before packaging
dart run tool/prepare_release.dart

# Build release App Bundle (required for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Google Play – Step 4: Upload to Play Console

#### Google Play – Option A: Play Console (manual)

1. In Play Console → your app → **Release** → **Production** (or **Testing** → Internal/Closed/Open).
2. **Create new release** → upload `app-release.aab`.
3. Add **release name** and **release notes**.
4. **Review release** → **Start rollout** (or save for later).

#### Google Play – Option B: Fastlane (automated)

```bash
bundle install
bundle exec fastlane android deploy track:internal
```

Use `track:internal`, `track:alpha`, `track:beta`, or `track:production` as needed. This automates build (if configured), upload, and optional rollout.

### Google Play – Step 5: Submit for Review

- For **Production**: Complete all Play Console requirements (content rating, policy declarations, etc.). Then submit the release for review.
- For **Internal testing** or **Closed/Open testing**: No review; testers get access after you add them.
- **Review time**: Production reviews can take from hours to several days.

### Google Play – Step 6: Post-Submission

- Monitor **Play Console** → **Release** → **Production** (or your track) for status and any policy or rejection messages.
- Address any issues (policy, crashes, metadata) and upload a new version if required.
- After approval, the app is available according to your rollout percentage and country selection.

### Google Play – Troubleshooting

| Issue | Solution |
| ----- | -------- |
| **Signing errors** | Ensure `key.properties` (or env) has correct `storeFile`, `storePassword`, `keyAlias`, `keyPassword`; release `buildTypes.release.signingConfig` points to your release config |
| **Version code conflict** | Increment `versionCode` in `pubspec.yaml` (or `android/app/build.gradle`) for each upload |
| **Upload rejected** | Check minimum SDK, target SDK, and permissions; fix any policy or security warnings in Play Console |
| **Missing google-services.json** | Run `flutterfire configure`; ensure file is at `android/app/google-services.json` |
| **ProGuard/R8** | If release build fails or crashes, check `android/app/build.gradle` ProGuard rules and mapping files for obfuscation issues |

### Google Play – Related

- [Release Preparation](#release-preparation) – Shared release steps
- [Firebase App Distribution](firebase_app_distribution.md) – Pre-release testing before store submission
- [Security & Secrets](security_and_secrets.md) – API keys and keystore handling
- [Platform-Specific Requirements (Android)](#android) – Firebase, Maps, signing

---

## iOS Entitlements (Development vs Distribution)

Personal Apple developer accounts do **not** support the **Associated Domains** capability (required for universal links / deep links). For local development on your device, use minimal entitlements. For Ad Hoc or App Store distribution, use full entitlements with Associated Domains.

Switch entitlements with the `ios_entitlements.sh` script:

```bash
# For local runs on your device (personal Apple ID)
./tool/ios_entitlements.sh development

# Before Ad Hoc or App Store builds (paid Apple Developer account required)
./tool/ios_entitlements.sh distribution
```

**When to use each mode:**

- **`development`** – `flutter run` on your device, day-to-day development
- **`distribution`** – `flutter build ipa`, Xcode Archive, Ad Hoc or App Store distribution

Templates are in `ios/Runner/`: `Runner.entitlements.development` and `Runner.entitlements.distribution`.

## Fastlane Automation

This project includes Fastlane configurations for automated deployments:

```bash
# Install dependencies
bundle install

# Deploy to iOS App Store
bundle exec fastlane ios deploy

# Deploy to Google Play Store
bundle exec fastlane android deploy track:internal

# Distribute to Firebase App Distribution (pre-release testers)
bundle exec fastlane android firebase_distribute   # Android APK
bundle exec fastlane ios firebase_distribute      # iOS IPA (requires paid Apple account for build)
```

See [Firebase App Distribution](firebase_app_distribution.md#fastlane-lanes-firebase_distribute) for lane options (release notes, groups, testers, skip_build).

## Release Preparation

```bash
# Scrub secrets before packaging
dart run tool/prepare_release.dart

# Build release
flutter build ios --release
flutter build appbundle --release
```

## Environment-Specific Builds

The project supports multiple environments:

- **Development**: `main_dev.dart`
- **Staging**: `main_staging.dart`
- **Production**: `main_prod.dart`

Select the appropriate entry point based on your deployment target.

## CI/CD Integration

- Fastlane scripts located in `ios/fastlane/` and `android/fastlane/`
- Firebase App Distribution hooks configured
- Per-environment configurations available

## Platform-Specific Requirements

### Android

- **Firebase config** – `android/app/google-services.json` (gitignored; generate via `flutterfire configure`)
- **Google Maps API key** – `android/app/src/main/AndroidManifest.xml` (required for maps feature)
- **Signing keystore** – `android/app/*.jks` or `~/.android/` (release builds only)

### iOS

- **Firebase config** – `ios/Runner/GoogleService-Info.plist` (gitignored; generate via `flutterfire configure`)
- **Entitlements** – `ios/Runner/Runner.entitlements` (use `./tool/ios_entitlements.sh` to switch)
- **Apple Developer account** – **Paid** required for Ad Hoc/App Store; **Free** works for personal device

### Platform-Specific Packages

Some dependencies only work on specific platforms:

- **`apple_maps_flutter`** – iOS-only; app uses `google_maps_flutter` on Android
- **`window_manager`** – Desktop-only; no-op on mobile

See [tech_stack.md](tech_stack.md#platform-specific-dependencies) for the full list.

## Related Documentation

- **App Store deployment**: [Deploy Flutter App to the App Store](#deploy-flutter-app-to-the-app-store) – Step-by-step guide for iOS App Store submission
- **Google Play deployment**: [Deploy Flutter App to Google Play Store](#deploy-flutter-app-to-google-play-store) – Step-by-step guide for Android Play Store submission
- **Firebase App Distribution**: [firebase_app_distribution.md](firebase_app_distribution.md) – Distribute pre-release iOS and Android builds to testers via Firebase App Distribution.
- **Tech Stack**: [tech_stack.md](tech_stack.md) – Dependencies and platform-specific packages
- Security and secrets: [security_and_secrets.md](security_and_secrets.md)
- Developer guide: [new_developer_guide.md](new_developer_guide.md)

### iOS Entitlements Reference

- `./tool/ios_entitlements.sh development` – Minimal entitlements for local runs (personal Apple ID)
- `./tool/ios_entitlements.sh distribution` – Full entitlements for Ad Hoc/App Store (paid Apple Developer account)
