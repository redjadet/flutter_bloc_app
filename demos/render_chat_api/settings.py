"""Environment-driven settings for the Render FastAPI chat demo."""

from __future__ import annotations

from functools import lru_cache
from typing import Literal, Optional

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    cors_origins: str = Field(
        default="http://localhost:7357,http://127.0.0.1:7357",
        description="Comma-separated origins for CORSMiddleware.",
    )
    demo_shared_secret: Optional[str] = Field(default=None, alias="DEMO_SHARED_SECRET")
    firebase_project_id: Optional[str] = Field(default=None, alias="FIREBASE_PROJECT_ID")
    caller_auth_mode: Literal["firebase", "test_bypass"] = Field(
        default="firebase",
        alias="CALLER_AUTH_MODE",
    )
    allow_test_auth_bypass: bool = Field(
        default=False,
        alias="ALLOW_TEST_AUTH_BYPASS",
        description="Must never be true in production. Enables test_bypass caller auth.",
    )
    max_body_bytes: int = Field(default=256_000, alias="MAX_BODY_BYTES")
    max_idempotency_key_len: int = Field(default=128, alias="MAX_IDEMPOTENCY_KEY_LEN")
    response_cache_ttl_seconds: int = Field(default=900, alias="RESPONSE_CACHE_TTL_SECONDS")
    response_cache_max_entries: int = Field(default=256, alias="RESPONSE_CACHE_MAX_ENTRIES")
    hf_upstream_timeout_seconds: float = Field(
        default=120.0,
        alias="HF_UPSTREAM_TIMEOUT_SECONDS",
    )
    max_concurrent_120b: int = Field(default=2, alias="MAX_CONCURRENT_120B")
    rate_limit_per_uid_per_minute: int = Field(
        default=120,
        alias="RATE_LIMIT_PER_UID_PER_MINUTE",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


def parse_cors_origins(raw: str) -> list[str]:
    parts = [p.strip() for p in raw.split(",") if p.strip()]
    return parts if parts else ["http://localhost:7357"]


FROZEN_ALLOW_HEADERS: tuple[str, ...] = (
    "authorization",
    "content-type",
    "idempotency-key",
    "x-hf-authorization",
    "x-render-demo-secret",
)
