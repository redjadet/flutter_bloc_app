#!/usr/bin/env bash
# Check for potential concurrent modification errors when iterating over collections.
# Pattern: Iterating over a collection view (values/keys/entries/repositories) without snapshotting.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for potential concurrent modification issues..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  FILES=$(rg --files lib \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    || true)
else
  FILES=$(find lib -type f -name "*.dart" 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "\.g\.dart" \
    | grep -v "\.freezed\.dart" \
    || true)
fi

VIOLATIONS=""

while IFS= read -r file; do
  [ -z "$file" ] && continue

  # Detect for-in loops over collection views without creating a snapshot.
  # Flag patterns like: registry.repositories, _map.values, object.property.entries
  # Skip: .toMap().entries (already creates snapshot), simple local variables
  results=$(
    awk -v file="$file" '
      {
        lines[NR] = $0
      }
      END {
        for (i = 1; i <= NR; i++) {
          line = lines[i]
          # Skip comments
          if (line ~ /^[[:space:]]*\/\//) {
            continue
          }
          # Match for-in loops over .values, .keys, .entries, .repositories
          if (line ~ /for[[:space:]]*\([^)]*in[[:space:]]*[^)]*\.(values|keys|entries|repositories)/) {
            # Skip if snapshot is created in the same line (.toMap().entries, List.from(), etc.)
            if (line ~ /\.toMap\(\)\.(entries|values|keys)|\.toList\(\)|\.toSet\(\)|List<[^>]*>\.from\(|List\.from\(|List\.unmodifiable\(|List<[^>]*>\.unmodifiable\(|\.toList\(growable:[[:space:]]*false\)/) {
              continue
            }

            # Flag if the pattern contains a dot before the collection access
            # This catches: registry.repositories, _map.values, object.property.entries
            # Pattern: identifier.identifier.collection OR identifier.collection (at least one dot)
            is_property = 0
            if (line ~ /in[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\.[a-zA-Z_][a-zA-Z0-9_]*\.(values|keys|entries|repositories)/) {
              # Matched pattern like "object.property.collection" (two dots)
              is_property = 1
            } else if (line ~ /in[[:space:]]*_[a-zA-Z_][a-zA-Z0-9_]*\.(values|keys|entries|repositories)/) {
              # Matched pattern like "_privateField.collection" (instance variable)
              is_property = 1
            } else if (line ~ /in[[:space:]]*this\.[a-zA-Z_][a-zA-Z0-9_]*\.(values|keys|entries|repositories)/) {
              # Matched "this.property.collection"
              is_property = 1
            } else if (line ~ /in[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\.repositories/) {
              # Special case: registry.repositories (one dot, common pattern we want to catch)
              is_property = 1
            }

            # Only flag if it looks like a property/getter
            if (is_property) {
              # Check for snapshot in previous lines (up to 10 lines back)
              snapshot_found = 0
              for (j = i - 1; j >= 1 && j >= i - 10; j--) {
                prev = lines[j]
                if (prev ~ /^[[:space:]]*\/\//) {
                  continue
                }
                # Check if previous line creates a snapshot
                if (prev ~ /\.toList\(|List<[^>]*>\.from\(|List\.from\(|List\.unmodifiable\(|List<[^>]*>\.unmodifiable\(|\.toSet\(|\.toMap\(|\.toList\(growable:[[:space:]]*false\)/) {
                  snapshot_found = 1
                  break
                }
                # Stop looking if we hit a method/function boundary
                if (prev ~ /^[[:space:]]*(void|Future|Widget|class|enum|mixin|@override|static)[[:space:]]/) {
                  break
                }
              }
              if (!snapshot_found) {
                print file ":" i ": Potential concurrent modification - iterate over a snapshot before the loop"
              }
            }
          }
        }
      }
    ' "$file" 2>/dev/null || true
  )

  if [ -n "$results" ]; then
    VIOLATIONS+="${results}"$'\n'
  fi
done <<< "$FILES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Potential concurrent modification issue: Iterating over collection without snapshot"
  echo "Note: When iterating over collections from getters/properties, create a snapshot first:"
  echo "  List<X>.from(registry.repositories)  // ✅ Creates snapshot"
  echo "  for (final X in registry.repositories)  // ❌ May throw ConcurrentModificationError"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No potential concurrent modification issues detected"
  exit 0
fi
