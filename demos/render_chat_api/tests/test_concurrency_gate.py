"""Concurrency gate (503 saturation path)."""

from __future__ import annotations

import pytest

from exceptions import Saturation
from orchestration.concurrency_gate import ConcurrencyGate


@pytest.mark.asyncio
async def test_second_slot_raises_saturation_when_limit_one() -> None:
    gate = ConcurrencyGate(1)
    with pytest.raises(Saturation):
        async with gate.slot():
            async with gate.slot():
                pass  # unreachable
