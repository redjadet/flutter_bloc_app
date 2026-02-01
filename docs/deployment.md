# Deployment

This document describes the deployment process and release preparation steps.

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

- **Firebase App Distribution**: [firebase_app_distribution.md](firebase_app_distribution.md) – Distribute pre-release iOS and Android builds to testers via Firebase App Distribution.
- **Tech Stack**: [tech_stack.md](tech_stack.md) – Dependencies and platform-specific packages
- Security and secrets: [security_and_secrets.md](security_and_secrets.md)
- Developer guide: [new_developer_guide.md](new_developer_guide.md)

### iOS Entitlements Reference

- `./tool/ios_entitlements.sh development` – Minimal entitlements for local runs (personal Apple ID)
- `./tool/ios_entitlements.sh distribution` – Full entitlements for Ad Hoc/App Store (paid Apple Developer account)
