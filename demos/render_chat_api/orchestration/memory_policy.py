"""v1 deterministic context windowing (needs_context → memory)."""

from __future__ import annotations

from schemas import ChatMessage

_MAX_MESSAGES = 16
_MAX_TOTAL_CHARS = 8000


def apply_memory_window(messages: list[ChatMessage]) -> list[ChatMessage]:
    """Keep the tail of the conversation within caps."""
    trimmed = messages[-_MAX_MESSAGES:]
    while trimmed:
        total = sum(len(m.content) for m in trimmed)
        if total <= _MAX_TOTAL_CHARS:
            return trimmed
        trimmed = trimmed[1:]
    return trimmed
