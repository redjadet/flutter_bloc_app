"""Lightweight in-memory rate limits (per uid + per IP)."""

from __future__ import annotations

import time
from collections import defaultdict


class SlidingWindowCounter:
    def __init__(self, *, limit: int, window_seconds: float = 60.0) -> None:
        self._limit = limit
        self._window = window_seconds
        self._events: dict[str, list[float]] = defaultdict(list)

    def check(self, key: str) -> bool:
        """Return True if under limit (and record this hit)."""
        now = time.monotonic()
        q = self._events[key]
        cutoff = now - self._window
        while q and q[0] < cutoff:
            q.pop(0)
        if len(q) >= self._limit:
            return False
        q.append(now)
        return True
