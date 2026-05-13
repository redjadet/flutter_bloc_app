#!/usr/bin/env python3
"""Select an available iPhone simulator from `simctl list devices` JSON (stdin).

Prefers the newest iOS *runtime* that has at least one available iPhone, then
honors IOS_SIMULATOR_PREFERRED_NAMES order, else first device in that group.

Env:
  IOS_SIMULATOR_PREFERRED_NAMES — comma-separated device names (optional).
  IOS_SIMULATOR_PREFERRED_RUNTIME_VERSION — pin to exact major[.minor], e.g.
    26.5, 26-5, or 18 (optional). If unset, use latest installed runtime.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from typing import Any, Optional, Tuple

# e.g. com.apple.CoreSimulator.SimRuntime.iOS-26-5
_RUNTIME_VER = re.compile(r"iOS-(\d+)(?:-(\d+))?$", re.IGNORECASE)


def _parse_runtime_version(runtime_name: str) -> Optional[Tuple[int, int]]:
    m = _RUNTIME_VER.search(runtime_name.strip())
    if not m:
        return None
    major = int(m.group(1))
    minor = int(m.group(2)) if m.group(2) is not None else 0
    return (major, minor)


def _parse_version_pin(raw: str) -> Optional[Tuple[int, int]]:
    s = (raw or "").strip()
    if not s:
        return None
    low = s.lower()
    if low.startswith("ios"):
        s = s[3:].lstrip(" -_.")
    if "." in s:
        a, _, b = s.partition(".")
        return (int(a), int(b))
    if "-" in s:
        a, _, b = s.partition("-")
        return (int(a), int(b))
    if s.isdigit():
        return (int(s), 0)
    return None


def _preferred_names() -> list[str]:
    raw = os.environ.get("IOS_SIMULATOR_PREFERRED_NAMES", "")
    return [n.strip() for n in raw.split(",") if n.strip()]


def _collect(
    data: dict[str, Any],
    *,
    only_booted: bool,
) -> list[Tuple[Tuple[int, int], dict[str, Any]]]:
    out: list[Tuple[Tuple[int, int], dict[str, Any]]] = []
    for runtime_name, devices in data.get("devices", {}).items():
        if "iOS" not in runtime_name:
            continue
        ver = _parse_runtime_version(runtime_name)
        if ver is None:
            continue
        for device in devices:
            if not device.get("isAvailable", True):
                continue
            if "iPhone" not in device.get("name", ""):
                continue
            if only_booted and device.get("state") != "Booted":
                continue
            out.append((ver, device))
    return out


def _emit(device: dict[str, Any]) -> None:
    udid = device.get("udid", "")
    name = device.get("name", "")
    print(f"{udid}\t{name}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--booted",
        action="store_true",
        help="Only consider simulators in Booted state (for booted list JSON).",
    )
    args = parser.parse_args()

    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Invalid JSON from simctl: {e}", file=sys.stderr)
        raise SystemExit(1) from e

    pin = _parse_version_pin(os.environ.get("IOS_SIMULATOR_PREFERRED_RUNTIME_VERSION", ""))
    candidates = _collect(data, only_booted=args.booted)
    if not candidates:
        print("No matching iPhone simulators found.", file=sys.stderr)
        raise SystemExit(1)

    versions = [c[0] for c in candidates]
    if pin is not None:
        pinned = [c for c in candidates if c[0] == pin]
        if not pinned:
            print(
                f"No iPhone simulator on pinned runtime {pin[0]}.{pin[1]} "
                f"(IOS_SIMULATOR_PREFERRED_RUNTIME_VERSION).",
                file=sys.stderr,
            )
            raise SystemExit(1)
        candidates = pinned
    else:
        best = max(versions)
        candidates = [c for c in candidates if c[0] == best]

    preferred = _preferred_names()
    for pname in preferred:
        for _ver, dev in candidates:
            if dev.get("name") == pname:
                _emit(dev)
                return

    _emit(candidates[0][1])


if __name__ == "__main__":
    main()
