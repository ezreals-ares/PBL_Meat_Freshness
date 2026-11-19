"""Autentikasi API key dan pembatas laju (sliding-window rate limiter) untuk FastAPI."""

from __future__ import annotations

import hmac
import math
import os
import threading
import time
from collections import defaultdict, deque
from typing import Callable

from fastapi import HTTPException, Request, Security
from fastapi.security import APIKeyHeader

API_KEY_HEADER_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_HEADER_NAME, auto_error=False)

_TRUE_VALUES = {"1", "true", "yes", "on"}
_MAX_BUCKET_COUNT = 10_000


def _parse_bool_env(name: str, default: bool = False) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in _TRUE_VALUES


def _parse_int_env(name: str, default: int, minimum: int = 1) -> int:
    raw = os.getenv(name)
    if raw is None or not raw.strip():
        return default
    try:
        value = int(raw.strip())
    except ValueError:
        return default
    return max(minimum, value)


def get_configured_api_keys() -> tuple[str, ...]:
    """Ambil daftar API key dari variabel lingkungan `API_KEY` (mendukung pemisah koma)."""
    raw = os.getenv("API_KEY", "")
    keys = [part.strip() for part in raw.split(",") if part.strip()]
    return tuple(keys)


def is_api_key_configured() -> bool:
    """Mengembalikan `True` apabila minimal satu API key telah dikonfigurasi."""
    return bool(get_configured_api_keys())


def verify_api_key(provided_key: str | None = Security(api_key_header)) -> None:
    """Validasi header `X-API-Key` terhadap env `API_KEY` menggunakan comparison constant-time."""
    expected_keys = get_configured_api_keys()

    if not expected_keys:
        if _parse_bool_env("REQUIRE_API_KEY", default=False):
            raise HTTPException(
                status_code=503,
                detail="API key belum dikonfigurasi pada server.",
            )
        return

    candidate = provided_key.strip() if provided_key else ""
    candidate_bytes = candidate.encode("utf-8")
    matched = False
    for expected in expected_keys:
        if hmac.compare_digest(candidate_bytes, expected.encode("utf-8")):
            matched = True

    if not candidate or not matched:
        raise HTTPException(
            status_code=401,
            detail="API key tidak valid atau tidak disertakan.",
            headers={"WWW-Authenticate": "ApiKey"},
        )


def _get_client_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for", "")
    if forwarded:
        first_ip = forwarded.split(",")[0].strip()
        if first_ip:
            return first_ip
    if request.client and request.client.host:
        return request.client.host
    return "unknown"


class SlidingWindowRateLimiter:
    """Rate limiter berbasis sliding window in-memory yang thread-safe."""

    def __init__(self, time_fn: Callable[[], float] = time.monotonic) -> None:
        self._time_fn = time_fn
        self._lock = threading.Lock()
        self._requests: dict[str, deque[float]] = defaultdict(deque)

    def reset(self) -> None:
        """Hapus seluruh riwayat bucket permintaan (berguna untuk pengujian)."""
        with self._lock:
            self._requests.clear()

    def _prune_stale_buckets(self, cutoff: float) -> None:
        stale_keys = [
            key
            for key, bucket in self._requests.items()
            if not bucket or bucket[-1] <= cutoff
        ]
        for key in stale_keys:
            del self._requests[key]

    def check(
        self,
        client_id: str,
        *,
        max_requests: int = 30,
        window_seconds: int = 60,
    ) -> None:
        now = self._time_fn()
        cutoff = now - window_seconds

        with self._lock:
            if len(self._requests) > _MAX_BUCKET_COUNT:
                self._prune_stale_buckets(cutoff)

            bucket = self._requests[client_id]
            while bucket and bucket[0] <= cutoff:
                bucket.popleft()

            if len(bucket) >= max_requests:
                retry_after = max(1, math.ceil(bucket[0] + window_seconds - now))
                raise HTTPException(
                    status_code=429,
                    detail=f"Terlalu banyak permintaan. Coba lagi dalam {retry_after} detik.",
                    headers={"Retry-After": str(retry_after)},
                )

            bucket.append(now)


rate_limiter = SlidingWindowRateLimiter()


def enforce_rate_limit(request: Request) -> None:
    """Dependency FastAPI untuk membatasi laju request per IP klien."""
    if not _parse_bool_env("RATE_LIMIT_ENABLED", default=True):
        return

    max_requests = _parse_int_env("RATE_LIMIT_REQUESTS", default=30, minimum=1)
    window_seconds = _parse_int_env("RATE_LIMIT_WINDOW_SECONDS", default=60, minimum=1)
    rate_limiter.check(
        _get_client_ip(request),
        max_requests=max_requests,
        window_seconds=window_seconds,
    )
