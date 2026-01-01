# Bundle Size Monitoring Guide

This guide explains how to monitor and track Flutter app bundle sizes to prevent size regressions and track improvements from optimizations like deferred imports.

## Overview

Bundle size monitoring helps:

- Track size changes over time
- Detect regressions early
- Measure impact of optimizations (deferred imports, code splitting)
- Enforce size budgets

## Quick Start

### Check Current Bundle Sizes

```bash
./tool/check_bundle_size.sh
```

This script:

- Checks Android APK/AAB and iOS app sizes
- Compares against configured budgets
- Records sizes in `.bundle_sizes.json` for tracking
- Reports violations if sizes exceed budgets

### Build and Check

```bash
# Build Android APK
flutter build apk --release
./tool/check_bundle_size.sh

# Build Android AAB
flutter build appbundle --release
./tool/check_bundle_size.sh

# Build iOS (macOS only)
flutter build ios --release
./tool/check_bundle_size.sh
```

## Configuration

### Size Budgets

Edit `tool/check_bundle_size.sh` to adjust budgets:

```bash
# Bundle size budgets (in MB)
ANDROID_APK_BUDGET=50
ANDROID_AAB_BUDGET=30
IOS_BUDGET=50
```

### Tracking File

Sizes are tracked in `.bundle_sizes.json` (git-ignored):

```json
{
  "android": {
    "apk": [
      {
        "size_mb": 45.23,
        "timestamp": "2025-01-15T10:30:00Z"
      }
    ],
    "aab": [
      {
        "size_mb": 28.45,
        "timestamp": "2025-01-15T10:35:00Z"
      }
    ]
  },
  "ios": {
    "app": [
      {
        "size_mb": 48.12,
        "timestamp": "2025-01-15T10:40:00Z"
      }
    ]
  }
}
```

## Size Analysis

### Understanding Bundle Sizes

**Android APK:**

- Includes all native libraries for all architectures
- Larger than AAB but simpler to distribute
- Typical size: 30-60 MB for medium apps

**Android AAB (App Bundle):**

- Google Play optimized format
- Smaller than APK (excludes unused architectures)
- Typical size: 20-40 MB for medium apps

**iOS App:**

- Universal binary (includes all architectures)
- Includes assets and code
- Typical size: 30-60 MB for medium apps

### Size Breakdown

To analyze what's taking up space:

**Android:**

```bash
# Analyze APK contents
unzip -l build/app/outputs/flutter-apk/app-release.apk | sort -k4 -r | head -20

# Use bundletool to analyze AAB
bundletool build-apks --bundle=app-release.aab --output=app.apks --mode=universal
unzip -l app.apks | grep universal.apk
```

**iOS:**

```bash
# Analyze app bundle
du -sh build/ios/iphoneos/Runner.app/*
```

**Flutter Build Analysis:**

```bash
# Detailed analysis of Flutter build
flutter build apk --release --analyze-size
```

## Optimization Strategies

### 1. Deferred Imports

Already implemented for:

- **Google Maps** - Heavy native SDK dependencies (maps SDK, location services)
- **Markdown Editor** - Custom RenderObject implementation and markdown parsing
- **WebSocket** - Real-time communication libraries
- **Charts** - Data visualization libraries

**Implementation:** Features are loaded via `DeferredPage` + `deferred as` imports in `lib/app/router/routes.dart`. Each deferred feature has a library file in `lib/app/router/deferred_pages/` with a `library;` declaration.

**Impact:** Reduces initial bundle size by excluding heavy dependencies until needed. Estimated 9-17 MB saved from initial bundle, resulting in faster startup time.

> **See also:** [Lazy Loading Review](../analysis/lazy_loading_late_review.md) for detailed explanation of deferred loading, implementation patterns, and best practices.

### 2. Remove Unused Dependencies

```bash
# Check for unused dependencies
flutter pub deps

# Analyze imports
flutter analyze --no-fatal-infos
```

### 3. Optimize Assets

- Use WebP instead of PNG for images
- Compress images appropriately
- Remove unused assets
- Use vector graphics where possible

### 4. Code Splitting

- Use deferred imports for feature modules
- Split large features into separate packages
- Lazy load routes (already implemented)

### 5. ProGuard/R8 (Android)

Ensure `android/app/build.gradle` has:

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Check Bundle Size
  run: |
    flutter build apk --release
    ./tool/check_bundle_size.sh
```

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
if git diff --cached --name-only | grep -q "pubspec.yaml\|lib/"; then
  echo "Checking bundle size after dependency/code changes..."
  flutter build apk --release 2>&1 | tail -5
  ./tool/check_bundle_size.sh || exit 1
fi
```

## Size Tracking Over Time

### View History

```bash
cat .bundle_sizes.json | python3 -m json.tool
```

### Generate Report

Create `tool/report_bundle_sizes.sh`:

```bash
#!/usr/bin/env bash
python3 << 'EOF'
import json
import sys
from datetime import datetime

with open('.bundle_sizes.json', 'r') as f:
    data = json.load(f)

print("Bundle Size History")
print("=" * 50)

for platform, builds in data.items():
    print(f"\n{platform.upper()}")
    for build_type, entries in builds.items():
        print(f"  {build_type}:")
        for entry in entries[-5:]:  # Last 5 entries
            size = entry['size_mb']
            timestamp = entry['timestamp']
            print(f"    {timestamp}: {size:.2f} MB")
EOF
```

## Troubleshooting

### Size Increased Unexpectedly

1. **Check for new dependencies:**

   ```bash
   git diff pubspec.yaml
   ```

2. **Check for large assets:**

   ```bash
   find assets -type f -size +100k
   ```

3. **Review recent code changes:**

   ```bash
   git log --since="1 week ago" --stat
   ```

4. **Analyze build output:**

   ```bash
   flutter build apk --release --analyze-size
   ```

### Build Fails Size Check

1. Review size budgets - may need adjustment
2. Investigate recent changes
3. Consider optimizations (deferred imports, asset compression)
4. Document why increase is necessary

## Best Practices

1. **Set realistic budgets** - Based on app complexity and target devices
2. **Monitor regularly** - Run size checks before releases
3. **Track trends** - Review size history to catch gradual increases
4. **Optimize incrementally** - Small improvements add up
5. **Document exceptions** - If size increases are necessary, document why

## Related Documentation

- [Lazy Loading Review](../analysis/lazy_loading_late_review.md) - Comprehensive analysis of lazy loading patterns, deferred imports explanation, and performance optimization opportunities
- [Startup Time Profiling](STARTUP_TIME_PROFILING.md) - Guide for measuring and profiling app startup time
- [Architecture Details](architecture_details.md) - Architecture overview including lazy loading patterns

## Tools Reference

- **Size Check Script:** `tool/check_bundle_size.sh`
- **Flutter Build Analysis:** `flutter build apk --release --analyze-size`
- **Size Tracking:** `.bundle_sizes.json`
- **Bundletool:** <https://github.com/google/bundletool> (Android AAB analysis)
