# SwiftPM Google Maps SDK10 migration

**Date:** 2026-06-03

## Summary

Added the official `google_maps_flutter_ios_sdk10` package so iOS Google Maps
SDK dependencies resolve through Swift Package Manager instead of CocoaPods.
The repo remains hybrid because some Apple-platform plugins still lack upstream
SwiftPM support.

## Changes

- `pubspec.yaml` / `pubspec.lock`: add `google_maps_flutter_ios_sdk10`.
- iOS Pod lock: remove Google Maps CocoaPods entries.
- iOS SwiftPM lock files: pin `ios-maps-sdk` and `google-maps-ios-utils`.
- Tech stack and Google Maps docs: record SDK10 SwiftPM path.

## Verification

```bash
flutter build ios --simulator --debug
flutter build macos --debug
./tool/analyze.sh
```
