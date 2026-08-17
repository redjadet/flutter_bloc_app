#!/usr/bin/env bash
# Strip `final` from Freezed constructor/function parameters.
#
# Dart 3.13 language forbids `final` on ordinary function parameters.
# Re-run after `build_runner` until Freezed emits 3.13-safe params.
#
# Field declarations (`final List<T> _x;`) and locals (`final _that = this;`,
# `final value = ...`) are left intact.
#
# Regression: python3 tool/strip_freezed_dart_313_params_test.py

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

exec python3 "$SCRIPT_DIR/strip_freezed_dart_313_params.py" --root "$PROJECT_ROOT"
