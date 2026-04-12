"""In-process response cache (single-worker only; STOP #3 user scope)."""

from __future__ import annotations

import hashlib
import json
import time
from dataclasses import dataclass
from typing import Any


def _payload_fingerprint(messages_payload: list[dict[str, Any]], model: str) -> str:
    normalized = json.dumps(
        {"m": messages_payload, "model": model},
        sort_keys=True,
        separators=(",", ":"),
    )
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()


@dataclass
class CacheEntry:
    value: dict[str, Any]
    expires_at: float


class ResponseCache:
    def __init__(self, *, ttl_seconds: int, max_entries: int) -> None:
        self._ttl = ttl_seconds
        self._max = max_entries
        self._data: dict[str, CacheEntry] = {}

    def _key(self, uid: str, idempotency_key: str, fingerprint: str) -> str:
        return f"{uid}:{idempotency_key}:{fingerprint}"

    def get(self, uid: str, idempotency_key: str, messages: list[dict], model: str) -> dict[str, Any] | None:
        fp = _payload_fingerprint(messages, model)
        k = self._key(uid, idempotency_key, fp)
        now = time.monotonic()
        entry = self._data.get(k)
        if not entry:
            return None
        if entry.expires_at < now:
            del self._data[k]
            return None
        return entry.value

    def set(self, uid: str, idempotency_key: str, messages: list[dict], model: str, value: dict[str, Any]) -> None:
        if len(self._data) >= self._max:
            self._evict_one()
        fp = _payload_fingerprint(messages, model)
        k = self._key(uid, idempotency_key, fp)
        self._data[k] = CacheEntry(value=value, expires_at=time.monotonic() + self._ttl)

    def _evict_one(self) -> None:
        if not self._data:
            return
        oldest = min(self._data.items(), key=lambda kv: kv[1].expires_at)
        del self._data[oldest[0]]
