"""Bounded concurrency for 120B upstream calls (STOP #6 saturation → 503)."""

from __future__ import annotations

import asyncio
from contextlib import asynccontextmanager

from exceptions import Saturation


class ConcurrencyGate:
    """Reject immediately when all slots are busy (retryable overload)."""

    def __init__(self, limit: int) -> None:
        self._limit = max(1, limit)
        self._active = 0
        self._lock = asyncio.Lock()

    @asynccontextmanager
    async def slot(self):
        async with self._lock:
            if self._active >= self._limit:
                raise Saturation()
            self._active += 1
        try:
            yield
        finally:
            async with self._lock:
                self._active -= 1
