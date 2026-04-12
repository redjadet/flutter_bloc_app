"""Post-generation safety filter (v1 — lightweight)."""

from __future__ import annotations

import re

_EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")


def filter_output(text: str) -> str:
    """Redact obvious email patterns; empty-after-filter returns safe placeholder."""
    redacted = _EMAIL.sub("[redacted]", text)
    if not redacted.strip():
        return "I cannot provide that response."
    return redacted
