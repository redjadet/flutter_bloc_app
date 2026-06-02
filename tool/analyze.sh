#!/bin/bash
# Wrapper script to run flutter analyze
# custom_lint runs workspace lints (including file_length_lint) on top of analyzer

set -e

echo "Running flutter analyze..."
flutter analyze "$@"

echo ""
echo "Running custom_lint..."
dart run custom_lint

echo ""
echo "✅ Analysis + custom_lint complete!"


