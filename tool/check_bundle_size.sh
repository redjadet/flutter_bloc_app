#!/usr/bin/env bash
# Check and report Flutter app bundle sizes.
# Compares current build sizes to budgets and tracks size over time.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Bundle size budgets (in MB)
ANDROID_APK_BUDGET=50
ANDROID_AAB_BUDGET=30
IOS_BUDGET=50

# Size tracking file
SIZE_TRACKING_FILE="$PROJECT_ROOT/.bundle_sizes.json"

echo "📦 Checking Flutter app bundle sizes..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not found. Please install Flutter first."
  exit 1
fi

# Create tracking file if it doesn't exist
if [ ! -f "$SIZE_TRACKING_FILE" ]; then
  echo "{}" > "$SIZE_TRACKING_FILE"
fi

# Function to get file size in MB
get_size_mb() {
  local file="$1"
  if [ -f "$file" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      stat -f%z "$file" | awk '{printf "%.2f", $1/1024/1024}'
    else
      # Linux
      stat -c%s "$file" | awk '{printf "%.2f", $1/1024/1024}'
    fi
  else
    echo "0.00"
  fi
}

# Function to record size
record_size() {
  local platform="$1"
  local build_type="$2"
  local size_mb="$3"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Use Python or jq if available, otherwise simple JSON manipulation
  if command -v python3 &> /dev/null; then
    python3 << EOF
import json
import sys

try:
    with open("$SIZE_TRACKING_FILE", "r") as f:
        data = json.load(f)
except:
    data = {}

if "$platform" not in data:
    data["$platform"] = {}
if "$build_type" not in data["$platform"]:
    data["$platform"]["$build_type"] = []

entry = {
    "size_mb": float("$size_mb"),
    "timestamp": "$timestamp"
}
data["$platform"]["$build_type"].append(entry)

# Keep only last 20 entries
data["$platform"]["$build_type"] = data["$platform"]["$build_type"][-20:]

with open("$SIZE_TRACKING_FILE", "w") as f:
    json.dump(data, f, indent=2)

print(f"Recorded: {entry['size_mb']:.2f} MB at {entry['timestamp']}")
EOF
  else
    echo "⚠️  Python3 not available. Install Python3 or jq to track sizes over time."
  fi
}

# Check Android APK size
check_android_apk() {
  local apk_path="build/app/outputs/flutter-apk/app-release.apk"
  if [ -f "$apk_path" ]; then
    local size_mb=$(get_size_mb "$apk_path")
    record_size "android" "apk" "$size_mb"
    echo "📱 Android APK: ${size_mb} MB (budget: ${ANDROID_APK_BUDGET} MB)"
    if (( $(echo "$size_mb > $ANDROID_APK_BUDGET" | bc -l) )); then
      echo "⚠️  APK size exceeds budget!"
      return 1
    else
      echo "✅ APK size within budget"
      return 0
    fi
  else
    echo "ℹ️  Android APK not found. Build with: flutter build apk --release"
    return 0
  fi
}

# Check Android AAB size
check_android_aab() {
  local aab_path="build/app/outputs/bundle/release/app-release.aab"
  if [ -f "$aab_path" ]; then
    local size_mb=$(get_size_mb "$aab_path")
    record_size "android" "aab" "$size_mb"
    echo "📱 Android AAB: ${size_mb} MB (budget: ${ANDROID_AAB_BUDGET} MB)"
    if (( $(echo "$size_mb > $ANDROID_AAB_BUDGET" | bc -l) )); then
      echo "⚠️  AAB size exceeds budget!"
      return 1
    else
      echo "✅ AAB size within budget"
      return 0
    fi
  else
    echo "ℹ️  Android AAB not found. Build with: flutter build appbundle --release"
    return 0
  fi
}

# Check iOS size (approximate from .app bundle)
check_ios() {
  local app_path="build/ios/iphoneos/Runner.app"
  if [ -d "$app_path" ]; then
    local size_mb=0
    if [[ "$OSTYPE" == "darwin"* ]]; then
      size_mb=$(du -sm "$app_path" | cut -f1 | awk '{printf "%.2f", $1/1024}')
    else
      echo "ℹ️  iOS size checking requires macOS"
      return 0
    fi
    record_size "ios" "app" "$size_mb"
    echo "🍎 iOS App: ${size_mb} MB (budget: ${IOS_BUDGET} MB)"
    if (( $(echo "$size_mb > $IOS_BUDGET" | bc -l) )); then
      echo "⚠️  iOS app size exceeds budget!"
      return 1
    else
      echo "✅ iOS app size within budget"
      return 0
    fi
  else
    echo "ℹ️  iOS app not found. Build with: flutter build ios --release"
    return 0
  fi
}

# Main execution
HAS_VIOLATIONS=0

# Check if bc is available for floating point comparison
if ! command -v bc &> /dev/null; then
  echo "⚠️  'bc' not found. Size comparisons will be skipped. Install bc for full functionality."
  echo ""
  echo "To install bc:"
  echo "  macOS: brew install bc"
  echo "  Linux: apt-get install bc"
  echo ""
fi

echo ""
check_android_apk || HAS_VIOLATIONS=1
echo ""
check_android_aab || HAS_VIOLATIONS=1
echo ""
check_ios || HAS_VIOLATIONS=1
echo ""

if [ -f "$SIZE_TRACKING_FILE" ] && command -v python3 &> /dev/null; then
  echo "📊 Size history saved to: $SIZE_TRACKING_FILE"
  echo "   View with: cat $SIZE_TRACKING_FILE | python3 -m json.tool"
fi

if [ $HAS_VIOLATIONS -eq 1 ]; then
  echo "❌ Some bundle sizes exceed budgets. Consider:"
  echo "   - Removing unused dependencies"
  echo "   - Using deferred imports for heavy features"
  echo "   - Optimizing images and assets"
  echo "   - Reviewing the lazy loading guide: docs/performance/lazy_loading_review.md"
  exit 1
else
  echo "✅ All bundle sizes within budgets"
  exit 0
fi
