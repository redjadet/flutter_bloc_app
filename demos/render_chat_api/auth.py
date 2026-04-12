"""Caller authentication (Firebase ID token) and optional demo shared secret."""

from __future__ import annotations

import logging
from typing import TYPE_CHECKING

from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

if TYPE_CHECKING:
    from settings import Settings

logger = logging.getLogger(__name__)


class CallerAuthError(Exception):
    """Raised when Authorization cannot be verified."""

    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


def verify_demo_secret(
    *,
    settings: Settings,
    x_render_demo_secret: str | None,
) -> None:
    expected = settings.demo_shared_secret
    if not expected:
        return
    if not x_render_demo_secret or x_render_demo_secret.strip() != expected:
        raise CallerAuthError("demo_secret_mismatch")


def verify_firebase_bearer(
    *,
    settings: Settings,
    authorization: str | None,
) -> str:
    """Return verified Firebase uid (sub)."""
    if settings.caller_auth_mode == "test_bypass":
        if not settings.allow_test_auth_bypass:
            raise CallerAuthError("test_bypass_disabled")
        if not authorization or not authorization.lower().startswith("bearer "):
            raise CallerAuthError("missing_bearer")
        token = authorization.split(" ", 1)[1].strip()
        if not token:
            raise CallerAuthError("empty_bearer")
        return "test-uid"

    if not authorization or not authorization.lower().startswith("bearer "):
        raise CallerAuthError("missing_bearer")
    token = authorization.split(" ", 1)[1].strip()
    if not token:
        raise CallerAuthError("empty_bearer")

    project_id = settings.firebase_project_id
    if not project_id:
        logger.error("FIREBASE_PROJECT_ID missing while caller_auth_mode=firebase")
        raise CallerAuthError("server_misconfigured")

    try:
        info = id_token.verify_firebase_token(
            token,
            google_requests.Request(),
            audience=project_id,
        )
    except ValueError as e:
        logger.info("firebase_token_invalid", extra={"reason": str(e)})
        raise CallerAuthError("invalid_token") from e

    uid = info.get("sub")
    if not uid or not isinstance(uid, str):
        raise CallerAuthError("missing_sub")
    return uid


def verify_caller_uid(
    *,
    settings: Settings,
    authorization: str | None,
) -> str:
    return verify_firebase_bearer(settings=settings, authorization=authorization)
