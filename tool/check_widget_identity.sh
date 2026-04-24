#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Checking for widget identity drift (keys, builders, switchers)..."
dart run tool/check_widget_identity.dart
