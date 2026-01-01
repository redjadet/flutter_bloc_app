# Deployment

This document describes the deployment process and release preparation steps.

## Fastlane Automation

This project includes Fastlane configurations for automated deployments:

```bash
# Install dependencies
bundle install

# Deploy to iOS App Store
bundle exec fastlane ios deploy

# Deploy to Google Play Store
bundle exec fastlane android deploy track:internal
```

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

## Related Documentation

- Security and secrets: `docs/security_and_secrets.md`
- Developer guide: `docs/new_developer_guide.md`

