"""Concurrency gate (503 saturation path)."""

from __future__ import annotations

import asyncio
import pytest

from exceptions import Saturation
from orchestration.concurrency_gate import ConcurrencyGate


def test_second_slot_raises_saturation_when_limit_one() -> None:
    async def run() -> None:
        gate = ConcurrencyGate(1)
        with pytest.raises(Saturation):
            async with gate.slot():
                async with gate.slot():
                    pass  # unreachable

    asyncio.run(run())
