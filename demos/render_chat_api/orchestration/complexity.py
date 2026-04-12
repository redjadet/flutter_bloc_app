"""STOP #7 — deterministic simple vs complex heuristic."""

from __future__ import annotations

import re

from schemas import ChatMessage

_MARKERS = (
    "compare",
    "analyze",
    "design",
    "architecture",
    "refactor",
    "debug",
    "step-by-step",
)

_CODE_FENCE = re.compile(r"```")


def is_complex_request(messages: list[ChatMessage]) -> bool:
    """Return True when the latest user message triggers the 'complex' path."""
    user_messages = [m for m in messages if m.role == "user"]
    if not user_messages:
        return False
    latest = user_messages[-1].content
    total_chars = sum(len(m.content) for m in messages)

    if len(latest) > 400:
        return True
    if total_chars > 1200:
        return True
    if len(messages) > 8:
        return True
    if _CODE_FENCE.search(latest):
        return True

    marker_hits = sum(1 for k in _MARKERS if k.lower() in latest.lower())
    listish = bool(re.search(r"(?m)^\s*([-*]|\d+\.)", latest))
    if listish:
        marker_hits += 1
    return marker_hits >= 2
