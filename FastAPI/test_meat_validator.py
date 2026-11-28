"""Unit & integration test untuk validasi non-daging heuristik (Opsi C) FastAPI."""

from __future__ import annotations

import io
import os
import unittest
from unittest.mock import patch

import numpy as np
from fastapi.testclient import TestClient
from PIL import Image

import meat_validator
import security
from test_security import api_main


def _make_rgb_png_bytes(rgb: tuple[int, int, int], size: tuple[int, int] = (64, 64)) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", size, color=rgb).save(buf, format="PNG")
    return buf.getvalue()


class MeatValidatorUnitTests(unittest.TestCase):
    def test_validate_meat_coverage_rejects_below_threshold_and_accepts_above(self) -> None:
        env = {
            "NON_MEAT_VALIDATION_ENABLED": "true",
            "NON_MEAT_MIN_COVERAGE": "0.10",
        }
        with patch.dict(os.environ, env, clear=False):
            ok_low, reason_low = meat_validator.validate_meat_coverage(0.04)
            ok_pass, reason_pass = meat_validator.validate_meat_coverage(0.25)

        self.assertFalse(ok_low)
        self.assertIsNotNone(reason_low)
        self.assertTrue(ok_pass)
        self.assertIsNone(reason_pass)

    def test_validate_prediction_confidence_rejects_low_confidence_or_uniform_entropy(self) -> None:
        env = {
            "NON_MEAT_VALIDATION_ENABLED": "true",
            "NON_MEAT_MIN_CONFIDENCE": "0.55",
            "NON_MEAT_MAX_ENTROPY": "0.95",
        }
        with patch.dict(os.environ, env, clear=False):
            ok_uniform, reason_uniform = meat_validator.validate_prediction_confidence(
                np.array([0.34, 0.33, 0.33])
            )
            ok_low, reason_low = meat_validator.validate_prediction_confidence(
                np.array([0.50, 0.30, 0.20])
            )
            ok_clear, reason_clear = meat_validator.validate_prediction_confidence(
                np.array([0.85, 0.10, 0.05])
            )

        self.assertFalse(ok_uniform)
        self.assertIsNotNone(reason_uniform)
        self.assertFalse(ok_low)
        self.assertIsNotNone(reason_low)
        self.assertTrue(ok_clear)
        self.assertIsNone(reason_clear)

    def test_validation_can_be_disabled_via_env(self) -> None:
        with patch.dict(os.environ, {"NON_MEAT_VALIDATION_ENABLED": "false"}, clear=False):
            self.assertEqual(meat_validator.validate_meat_coverage(0.0), (True, None))
            self.assertEqual(
                meat_validator.validate_prediction_confidence(np.array([0.34, 0.33, 0.33])),
                (True, None),
            )


class PredictNonMeatEndpointTests(unittest.TestCase):
    def setUp(self) -> None:
        security.rate_limiter.reset()

    def test_non_meat_blue_image_is_rejected_by_both_endpoints_without_running_inference(self) -> None:
        called = {"netv2": 0, "svm": 0}

        class _FakeNetV2:
            def __init__(self, _path):
                pass

            def predict(self, _img):
                called["netv2"] += 1
                return np.array([0.9, 0.05, 0.05], dtype=np.float32)

        class _FakeSVM:
            def __init__(self, _path):
                pass

            def predict_from_prepared(self, _img01, _mask):
                called["svm"] += 1
                return np.array([0.9, 0.05, 0.05], dtype=np.float64)

        env = {
            "API_KEY": "",
            "REQUIRE_API_KEY": "false",
            "RATE_LIMIT_ENABLED": "false",
            "NON_MEAT_VALIDATION_ENABLED": "true",
        }
        blue_bytes = _make_rgb_png_bytes((30, 90, 210))

        with (
            patch.dict(os.environ, env, clear=False),
            patch.object(api_main, "NetV2Classifier", _FakeNetV2),
            patch.object(api_main, "SVMClassifier", _FakeSVM),
            TestClient(api_main.app) as client,
        ):
            r_netv2 = client.post(
                "/predict/netv2",
                files={"file": ("sky.png", blue_bytes, "image/png")},
            )
            r_svm = client.post(
                "/predict/svm",
                files={"file": ("sky.png", blue_bytes, "image/png")},
            )

        self.assertEqual(r_netv2.status_code, 200)
        body_netv2 = r_netv2.json()
        self.assertFalse(body_netv2["is_meat"])
        self.assertEqual(body_netv2["label"], "non_meat")
        self.assertTrue(body_netv2["reason"])
        self.assertEqual(called["netv2"], 0)

        self.assertEqual(r_svm.status_code, 200)
        body_svm = r_svm.json()
        self.assertFalse(body_svm["is_meat"])
        self.assertEqual(body_svm["label"], "non_meat")
        self.assertTrue(body_svm["segmentation_fallback"])
        self.assertTrue(body_svm["reason"])
        self.assertEqual(called["svm"], 0)

    def test_low_confidence_red_image_is_rejected_as_non_meat_while_confident_passes(self) -> None:
        class _LowConfNetV2:
            def __init__(self, _path):
                pass

            def predict(self, _img):
                return np.array([0.40, 0.35, 0.25], dtype=np.float32)

        class _HighConfSVM:
            def __init__(self, _path):
                pass

            def predict_from_prepared(self, _img01, _mask):
                return np.array([0.88, 0.08, 0.04], dtype=np.float64)

        env = {
            "API_KEY": "",
            "REQUIRE_API_KEY": "false",
            "RATE_LIMIT_ENABLED": "false",
            "NON_MEAT_VALIDATION_ENABLED": "true",
        }
        red_bytes = _make_rgb_png_bytes((185, 45, 45))

        with (
            patch.dict(os.environ, env, clear=False),
            patch.object(api_main, "NetV2Classifier", _LowConfNetV2),
            patch.object(api_main, "SVMClassifier", _HighConfSVM),
            TestClient(api_main.app) as client,
        ):
            r_low = client.post(
                "/predict/netv2",
                files={"file": ("uncertain.png", red_bytes, "image/png")},
            )
            r_ok = client.post(
                "/predict/svm",
                files={"file": ("fresh.png", red_bytes, "image/png")},
            )

        self.assertEqual(r_low.status_code, 200)
        self.assertFalse(r_low.json()["is_meat"])
        self.assertEqual(r_low.json()["label"], "non_meat")
        self.assertIn("fresh", r_low.json()["probabilities"])

        self.assertEqual(r_ok.status_code, 200)
        self.assertTrue(r_ok.json()["is_meat"])
        self.assertEqual(r_ok.json()["label"], "fresh")
        self.assertIsNone(r_ok.json()["reason"])
        self.assertGreaterEqual(r_ok.json()["meat_coverage"], 0.10)


if __name__ == "__main__":
    unittest.main()
