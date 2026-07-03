#!/usr/bin/env bash
# Guard Apple-platform debug Hive + secret-storage invariants (iOS simulator / macOS).
# Prevents Keychain -34018 noise, ephemeral encryption keys, and "Recovering corrupted box."
# See docs/engineering/apple_debug_hive_storage.md

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

SECRET_STORAGE="lib/shared/platform/secure_secret_storage.dart"
HIVE_INIT="lib/shared/storage/hive_initializer_io.dart"
HIVE_KEYS="lib/shared/storage/hive_key_manager.dart"
SECRET_TEST="test/secure_secret_storage_test.dart"
KEY_TEST="test/shared/storage/hive_key_manager_test.dart"

fail() {
  echo "❌ $1"
  exit 1
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local hint="$3"
  if ! grep -qE "$pattern" "$file"; then
    fail "$file missing $hint (pattern: $pattern). See docs/engineering/apple_debug_hive_storage.md"
  fi
}

echo "🔍 Checking Apple debug Hive + secret-storage guards..."

for f in "$SECRET_STORAGE" "$HIVE_INIT" "$HIVE_KEYS" "$SECRET_TEST" "$KEY_TEST"; do
  [ -f "$f" ] || fail "Expected file missing: $f"
done

require_pattern "$SECRET_STORAGE" 'useInMemorySecretStorageInDebug' \
  'useInMemorySecretStorageInDebug() helper'
require_pattern "$SECRET_STORAGE" 'TargetPlatform\.iOS' \
  'iOS in useInMemorySecretStorageInDebug gate'
require_pattern "$SECRET_STORAGE" 'TargetPlatform\.macOS' \
  'macOS in useInMemorySecretStorageInDebug gate'
require_pattern "$SECRET_STORAGE" 'kIsWeb' 'kIsWeb guard in secret storage helper'
require_pattern "$SECRET_STORAGE" 'kReleaseMode' 'kReleaseMode guard in secret storage helper'

require_pattern "$HIVE_INIT" 'Platform\.isIOS && !kReleaseMode' \
  'iOS debug Hive directory gate'
require_pattern "$HIVE_INIT" 'hive_ios_debug' \
  'hive_ios_debug subdirectory'
require_pattern "$HIVE_INIT" 'hive_macos_debug' \
  'hive_macos_debug subdirectory (macOS parity)'

require_pattern "$HIVE_KEYS" 'useInMemorySecretStorageInDebug' \
  'HiveKeyManager Apple debug fallback wiring'
require_pattern "$HIVE_KEYS" '_appleDebugFallbackKey' \
  'stable Apple debug encryption key'

require_pattern "$SECRET_TEST" 'iOS debug' \
  'iOS debug secret-storage regression test'
require_pattern "$KEY_TEST" 'iOS debug' \
  'iOS debug Hive key regression test'

require_pattern "$SECRET_STORAGE" 'useUnencryptedHiveBoxesInDebug' \
  'useUnencryptedHiveBoxesInDebug() web debug helper'
require_pattern "$SECRET_STORAGE" 'useInMemoryHiveBoxesInDebug' \
  'useInMemoryHiveBoxesInDebug() web debug helper'

HIVE_INIT_WEB="lib/shared/storage/hive_initializer_web.dart"
[ -f "$HIVE_INIT_WEB" ] || fail "Expected file missing: $HIVE_INIT_WEB"
require_pattern "$HIVE_INIT_WEB" 'hive_web_debug_v4' \
  'hive_web_debug_v4 IndexedDB namespace'

require_pattern "$SECRET_STORAGE" 'if \(useInMemorySecretStorageInDebug\(\)\)' \
  'createDefaultSecretStorage routes Apple debug through useInMemorySecretStorageInDebug()'

echo "✅ Apple debug Hive + secret-storage guards present"
