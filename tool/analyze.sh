#!/bin/bash
# Wrapper script to run flutter analyze
# The native Dart 3.10 analyzer plugin (file_length_lint) runs automatically with flutter analyze

set -e

echo "Running flutter analyze..."
echo "Note: Native analyzer plugins (like file_length_lint) run automatically with flutter analyze"
flutter analyze "$@"

echo ""
echo "✅ Analysis complete!"


