"""Auth failure logs must not echo caller token material."""

from __future__ import annotations

import logging
from types import SimpleNamespace
from typing import Any

import pytest

import auth


def test_invalid_firebase_token_log_omits_token(
    monkeypatch: pytest.MonkeyPatch,
    caplog: pytest.LogCaptureFixture,
) -> None:
    secret_token = "leaky-token-segment"

    def _raise(*_args: Any, **_kwargs: Any) -> dict[str, Any]:
        raise ValueError(f"Wrong number of segments in token: b'{secret_token}'")

    monkeypatch.setattr(auth.id_token, "verify_firebase_token", _raise)
    settings: Any = SimpleNamespace(
        caller_auth_mode="firebase",
        firebase_project_id="demo-project",
    )

    with caplog.at_level(logging.INFO, logger=auth.logger.name):
        with pytest.raises(auth.CallerAuthError) as excinfo:
            auth.verify_firebase_bearer(
                settings=settings,
                authorization=f"Bearer {secret_token}",
            )

    assert excinfo.value.reason == "invalid_token"
    records = [r for r in caplog.records if r.getMessage() == "firebase_token_invalid"]
    assert records, "expected firebase_token_invalid log"
    for record in records:
        assert secret_token not in repr(record.__dict__)
        assert getattr(record, "reason", None) == "ValueError"
