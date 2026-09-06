#!/usr/bin/env bash
# Verify generated ABI, Rust crate, and real Dart-to-Rust host bridge.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRATE_DIR="$ROOT/packages/secure_core_bridge/rust/secure_core"

if [[ ! -d "$CRATE_DIR" ]]; then
  echo "secure_core crate missing at $CRATE_DIR" >&2
  exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo not found; install Rust 1.98.1 (see packages/secure_core_bridge/README.md)" >&2
  exit 1
fi

EXPECTED_RUSTC="$(awk -F '"' '/^channel[[:space:]]*=/{print $2}' "$CRATE_DIR/rust-toolchain.toml")"
if [[ -z "$EXPECTED_RUSTC" ]]; then
  echo "Rust channel missing from $CRATE_DIR/rust-toolchain.toml" >&2
  exit 1
fi
ACTUAL_RUSTC="$(rustc --version | awk '{print $2}')"
if [[ "$ACTUAL_RUSTC" != "$EXPECTED_RUSTC" ]]; then
  echo "rustc $ACTUAL_RUSTC != required $EXPECTED_RUSTC" >&2
  exit 1
fi

cd "$ROOT"
dart run packages/secure_core_bridge/tool/generate_bindings.dart --check

cd "$CRATE_DIR"
cargo fmt --check
cargo check --locked
cargo clippy --all-targets --all-features -- -D warnings
cargo test --locked

cd "$ROOT"
dart test packages/secure_core_bridge

echo "check_secure_core|ok"
