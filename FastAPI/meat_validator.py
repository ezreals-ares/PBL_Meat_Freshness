"""Validasi heuristik non-daging (Opsi C) berbasis cakupan segmentasi & ambang confidence/entropi."""

from __future__ import annotations

import math
import os

import numpy as np

_TRUE_VALUES = {"1", "true", "yes", "on"}

DEFAULT_MIN_MEAT_COVERAGE = 0.10
DEFAULT_MIN_CONFIDENCE = 0.55
DEFAULT_MAX_NORMALIZED_ENTROPY = 0.95

REASON_LOW_COVERAGE = (
    "Objek daging tidak terdeteksi dengan jelas pada gambar. "
    "Arahkan kamera lebih dekat ke permukaan daging dengan pencahayaan cukup."
)
REASON_LOW_CONFIDENCE = (
    "Tingkat keyakinan model terlalu rendah untuk memastikan objek adalah daging. "
    "Coba ambil ulang foto lebih dekat dan fokus pada permukaan daging."
)


def _parse_bool_env(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in _TRUE_VALUES


def _parse_float_env(name: str, default: float, *, low: float = 0.0, high: float = 1.0) -> float:
    raw = os.getenv(name)
    if raw is None or not raw.strip():
        return default
    try:
        val = float(raw.strip())
    except ValueError:
        return default
    return min(high, max(low, val))


def is_non_meat_validation_enabled() -> bool:
    """Aktif secara default; dapat dimatikan via `NON_MEAT_VALIDATION_ENABLED=false`."""
    return _parse_bool_env("NON_MEAT_VALIDATION_ENABLED", default=True)


def get_min_meat_coverage() -> float:
    return _parse_float_env("NON_MEAT_MIN_COVERAGE", DEFAULT_MIN_MEAT_COVERAGE)


def get_min_confidence() -> float:
    return _parse_float_env("NON_MEAT_MIN_CONFIDENCE", DEFAULT_MIN_CONFIDENCE)


def get_max_normalized_entropy() -> float:
    return _parse_float_env("NON_MEAT_MAX_ENTROPY", DEFAULT_MAX_NORMALIZED_ENTROPY)


def normalized_entropy(probs: np.ndarray) -> float:
    """Hitung entropi Shannon ternormalisasi dalam rentang [0, 1]."""
    arr = np.asarray(probs, dtype=np.float64).ravel()
    if arr.size <= 1:
        return 0.0
    total = float(arr.sum())
    if total <= 0.0:
        return 1.0
    norm = arr / total
    positive = norm[norm > 0.0]
    if positive.size == 0:
        return 1.0
    entropy = float(-np.sum(positive * np.log(positive)))
    return min(1.0, max(0.0, entropy / math.log(arr.size)))


def validate_meat_coverage(meat_coverage: float) -> tuple[bool, str | None]:
    """Tolak gambar jika rasio piksel area daging di bawah ambang minimal."""
    if not is_non_meat_validation_enabled():
        return True, None
    if meat_coverage < get_min_meat_coverage():
        return False, REASON_LOW_COVERAGE
    return True, None


def validate_prediction_confidence(probs: np.ndarray) -> tuple[bool, str | None]:
    """Tolak prediksi jika confidence maksimum terlalu rendah atau entropi terlalu tinggi."""
    if not is_non_meat_validation_enabled():
        return True, None
    arr = np.asarray(probs, dtype=np.float64).ravel()
    if arr.size == 0:
        return False, REASON_LOW_CONFIDENCE

    max_prob = float(np.max(arr))
    entropy = normalized_entropy(arr)
    if max_prob < get_min_confidence() or entropy > get_max_normalized_entropy():
        return False, REASON_LOW_CONFIDENCE
    return True, None
