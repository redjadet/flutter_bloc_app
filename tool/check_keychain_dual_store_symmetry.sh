#!/usr/bin/env bash
# Guard dual-store Apple Keychain symmetry: when read peeks legacy, delete must
# clear legacy too (credential-clear resurrection). See #817 / #834 and
# docs/security/storage_rules.md.
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"

SECRET_STORAGE="$WORKSPACE_ROOT/packages/app_shared_flutter/lib/src/platform/secure_secret_storage.dart"
SECRET_TEST="$APP_ROOT/test/secure_secret_storage_test.dart"
STORAGE_RULES="$WORKSPACE_ROOT/docs/security/storage_rules.md"

fail() {
  echo "❌ $1"
  exit 1
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local hint="$3"
  if ! grep -qE "$pattern" "$file"; then
    fail "$file missing $hint (pattern: $pattern). See docs/security/storage_rules.md"
  fi
}

echo "🔍 Checking Apple Keychain dual-store delete/read symmetry..."

for f in "$SECRET_STORAGE" "$SECRET_TEST" "$STORAGE_RULES"; do
  [ -f "$f" ] || fail "Expected file missing: $f"
done

# Read path still peeks legacy first (invariant from #817).
require_pattern "$SECRET_STORAGE" '_legacyMigrationStorage\.read' \
  'legacy Keychain peek on read'

# Scoped: FlutterSecureSecretStorage.delete body must clear legacy independently
# of hardened delete success (not migration helpers alone).
python3 - "$SECRET_STORAGE" <<'PY' || fail "delete() body missing independent legacy clear"
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
# Isolate FlutterSecureSecretStorage.delete (stop before InMemorySecretStorage)
cls = re.search(
    r"class FlutterSecureSecretStorage[\s\S]*?(?=class InMemorySecretStorage)",
    text,
)
if not cls:
    raise SystemExit("FlutterSecureSecretStorage class not found")
body_match = re.search(
    r"Future<void>\s+delete\(String key\)\s+async\s*\{([\s\S]*?)\n  \}",
    cls.group(0),
)
if not body_match:
    raise SystemExit("delete(String key) method not found on FlutterSecureSecretStorage")
body = body_match.group(1)
if "_legacyMigrationStorage.delete" not in body:
    raise SystemExit("delete() does not call _legacyMigrationStorage.delete")
# Hardened delete and legacy delete must not be nested (independent attempts).
# Heuristic: legacy delete must not appear only inside the first try that
# awaits _storage.delete without a sibling try after that try's catch.
if not re.search(
    r"_storage\.delete\([\s\S]*?\}\s*(?:on [^{]+\{[\s\S]*?\})*\s*"
    r"if\s*\(_enableLegacyKeychainMigration[\s\S]*?_legacyMigrationStorage\.delete",
    body,
):
    raise SystemExit(
        "delete() must attempt legacy clear after hardened delete attempt "
        "(independent of hardened success)"
    )
print("ok|delete-body|legacy-clear-independent")
PY

require_pattern "$SECRET_STORAGE" 'FlutterSecureSecretStorage\.delete failed for legacy key' \
  'legacy delete error logging'

# Regression anchors.
require_pattern "$SECRET_TEST" 'delete clears legacy Keychain item so read does not resurrect secret' \
  'delete-resurrection regression test'
require_pattern "$SECRET_TEST" 'delete still clears legacy when hardened delete fails' \
  'hardened-delete-failure still clears legacy regression test'
require_pattern "$SECRET_TEST" 'legacy Keychain value wins when hardened store holds interim rotated secret' \
  'legacy-wins coexistence regression test'

# Living doc must state delete symmetry (not only read priority).
require_pattern "$STORAGE_RULES" '[Dd]elete.*(legacy|both)|legacy.*delete|clears? both' \
  'delete/legacy symmetry documented in storage_rules'

echo "✅ Apple Keychain dual-store read/delete symmetry guards present"
