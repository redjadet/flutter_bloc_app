#!/usr/bin/env bash
# beforeReadFile: deny agent Read on common local secret paths (convenience; not a guarantee).
# Owner: docs/ai/agent_customization_layers.md
# Output: {"permission":"allow"|"deny","user_message":?}
# Smoke: printf '%s' '{"file_path":"/tmp/.env","content":""}' | bash .cursor/hooks/block-sensitive-file-read.sh
set -euo pipefail

input="$(cat)"

python3 -c '
from __future__ import annotations

import json, os, sys

def respond(permission: str, user_message: str | None = None) -> None:
    out: dict[str, str] = {"permission": permission}
    if user_message:
        out["user_message"] = user_message
    json.dump(out, sys.stdout)
    sys.exit(0)

try:
    data = json.loads(sys.stdin.read() or "{}")
except json.JSONDecodeError:
    respond("deny", "Hook received invalid JSON; blocking read (fail-safe).")

path = (data.get("file_path") or "").strip()
if not path:
    respond("allow")

norm = path.replace("\\", "/")
base = os.path.basename(norm)
lower = norm.lower()

def is_ci_or_sample(p: str) -> bool:
    if "/ci/" in p or p.endswith(".sample") or p.endswith(".example"):
        return True
    if base.endswith(".sample") or base.endswith(".example"):
        return True
    return False

if is_ci_or_sample(norm):
    respond("allow")

secret_basenames = {
    ".env",
    ".env.local",
    ".envrc",
    ".env.android.release",
    ".env.ios.release",
    "key.properties",
    "secrets.json",
}

if base in secret_basenames:
    respond(
        "deny",
        "Local secret/config file blocked from agent read. Use security_and_secrets.md templates; do not paste contents into chat.",
    )

if base == "google-services.json" and not is_ci_or_sample(norm):
    respond(
        "deny",
        "google-services.json is gitignored client config; use samples/CI fixtures instead of reading the real file.",
    )

if base == "GoogleService-Info.plist" and not is_ci_or_sample(norm):
    respond(
        "deny",
        "GoogleService-Info.plist is gitignored client config; use samples/CI fixtures instead.",
    )

if lower.endswith((".jks", ".keystore", ".p12", ".mobileprovision")):
    respond("deny", "Signing material blocked from agent read.")

respond("allow")
' <<<"$input"
