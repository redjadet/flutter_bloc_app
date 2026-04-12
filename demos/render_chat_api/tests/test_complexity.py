"""Unit tests for STOP #7 complexity heuristic."""

from __future__ import annotations

from orchestration.complexity import is_complex_request
from schemas import ChatMessage


def test_short_message_is_simple() -> None:
    msgs = [ChatMessage(role="user", content="Hi")]
    assert is_complex_request(msgs) is False


def test_long_latest_user_is_complex() -> None:
    msgs = [ChatMessage(role="user", content="x" * 401)]
    assert is_complex_request(msgs) is True


def test_code_fence_is_complex() -> None:
    msgs = [ChatMessage(role="user", content="```\nfoo\n```")]
    assert is_complex_request(msgs) is True


def test_two_markers_complex() -> None:
    msgs = [
        ChatMessage(
            role="user",
            content="Please analyze and compare these options.",
        ),
    ]
    assert is_complex_request(msgs) is True
