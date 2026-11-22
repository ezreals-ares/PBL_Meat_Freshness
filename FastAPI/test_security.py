"""Unit test untuk autentikasi API key dan rate limiter FastAPI."""

from __future__ import annotations

import io
import os
import sys
import types
import unittest
from unittest.mock import patch

import numpy as np
from fastapi import Depends, FastAPI, HTTPException
from fastapi.testclient import TestClient
from PIL import Image

import security


def _import_main_with_litert_fallback():
    """Import `main`; sediakan stub `ai_edge_litert` jika DLL natif diblokir kebijakan OS."""
    try:
        import main as api_main
        return api_main
    except (ImportError, OSError):
        litert_mod = types.ModuleType("ai_edge_litert")
        interp_mod = types.ModuleType("ai_edge_litert.interpreter")

        class _StubInterpreter:
            def __init__(self, *args, **kwargs):
                pass

        interp_mod.Interpreter = _StubInterpreter
        litert_mod.interpreter = interp_mod
        sys.modules.setdefault("ai_edge_litert", litert_mod)
        sys.modules.setdefault("ai_edge_litert.interpreter", interp_mod)
        import main as api_main
        return api_main


api_main = _import_main_with_litert_fallback()


def _make_dummy_png_bytes() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (16, 16), color=(180, 40, 40)).save(buf, format="PNG")
    return buf.getvalue()


def _build_secured_test_app() -> FastAPI:
    app = FastAPI()

    @app.get("/open")
    def open_route():
        return {"ok": True}

    @app.post(
        "/protected",
        dependencies=[Depends(security.verify_api_key), Depends(security.enforce_rate_limit)],
    )
    def protected_route():
        return {"ok": True}

    return app


class ApiKeyAuthTests(unittest.TestCase):
    def setUp(self) -> None:
        security.rate_limiter.reset()
        self.app = _build_secured_test_app()
        self.client = TestClient(self.app)

    def test_dev_mode_allows_requests_without_api_key(self) -> None:
        with patch.dict(os.environ, {"API_KEY": "", "REQUIRE_API_KEY": "false"}, clear=False):
            resp = self.client.post("/protected")
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.json(), {"ok": True})

    def test_require_api_key_without_configured_key_returns_503(self) -> None:
        with patch.dict(os.environ, {"API_KEY": "", "REQUIRE_API_KEY": "true"}, clear=False):
            resp = self.client.post("/protected")
        self.assertEqual(resp.status_code, 503)

    def test_configured_api_key_rejects_missing_or_wrong_key_and_accepts_valid(self) -> None:
        env = {"API_KEY": "secret-primary, secret-secondary", "REQUIRE_API_KEY": "true"}
        with patch.dict(os.environ, env, clear=False):
            resp_missing = self.client.post("/protected")
            resp_wrong = self.client.post("/protected", headers={"X-API-Key": "salah"})
            resp_primary = self.client.post("/protected", headers={"X-API-Key": "secret-primary"})
            resp_secondary = self.client.post("/protected", headers={"X-API-Key": "secret-secondary"})

        self.assertEqual(resp_missing.status_code, 401)
        self.assertEqual(resp_wrong.status_code, 401)
        self.assertEqual(resp_primary.status_code, 200)
        self.assertEqual(resp_secondary.status_code, 200)

    def test_non_ascii_api_key_returns_401_instead_of_500(self) -> None:
        env = {"API_KEY": "secret-primary", "REQUIRE_API_KEY": "true"}
        with patch.dict(os.environ, env, clear=False):
            with self.assertRaises(HTTPException) as ctx:
                security.verify_api_key(provided_key="kunci-\u00e9")
        self.assertEqual(ctx.exception.status_code, 401)


class RateLimiterTests(unittest.TestCase):
    def setUp(self) -> None:
        security.rate_limiter.reset()
        self.app = _build_secured_test_app()
        self.client = TestClient(self.app)

    def test_sliding_window_blocks_excess_and_recovers_after_window(self) -> None:
        now = 100.0
        limiter = security.SlidingWindowRateLimiter(time_fn=lambda: now)

        limiter.check("client-a", max_requests=2, window_seconds=10)
        limiter.check("client-a", max_requests=2, window_seconds=10)

        with self.assertRaises(HTTPException) as ctx:
            limiter.check("client-a", max_requests=2, window_seconds=10)
        self.assertEqual(ctx.exception.status_code, 429)
        self.assertEqual(ctx.exception.headers["Retry-After"], "10")

        # IP lain tetap punya kuota sendiri
        limiter.check("client-b", max_requests=2, window_seconds=10)

        # Setelah lewat jendela 10 detik, client-a dapat mengirim lagi
        now = 110.1
        limiter.check("client-a", max_requests=2, window_seconds=10)

    def test_enforce_rate_limit_dependency_separates_forwarded_ips(self) -> None:
        env = {
            "API_KEY": "",
            "REQUIRE_API_KEY": "false",
            "RATE_LIMIT_ENABLED": "true",
            "RATE_LIMIT_REQUESTS": "2",
            "RATE_LIMIT_WINDOW_SECONDS": "60",
        }
        with patch.dict(os.environ, env, clear=False):
            r1 = self.client.post("/protected", headers={"X-Forwarded-For": "203.0.113.10, 10.0.0.1"})
            r2 = self.client.post("/protected", headers={"X-Forwarded-For": "203.0.113.10"})
            r3 = self.client.post("/protected", headers={"X-Forwarded-For": "203.0.113.10"})
            r_other = self.client.post("/protected", headers={"X-Forwarded-For": "203.0.113.20"})

        self.assertEqual(r1.status_code, 200)
        self.assertEqual(r2.status_code, 200)
        self.assertEqual(r3.status_code, 429)
        self.assertIn("Retry-After", r3.headers)
        self.assertEqual(r_other.status_code, 200)


class MainAppRouteWiringTests(unittest.TestCase):
    def setUp(self) -> None:
        security.rate_limiter.reset()

    def test_main_routes_protect_predict_endpoints_but_leave_health_open(self) -> None:
        class _FakeNetV2:
            def __init__(self, _path):
                pass

            def predict(self, _img):
                return np.array([0.8, 0.15, 0.05], dtype=np.float32)

        class _FakeSVM:
            def __init__(self, _path):
                pass

            def predict(self, _img):
                return np.array([0.1, 0.7, 0.2], dtype=np.float64), False

        env = {
            "API_KEY": "prod-secret-key",
            "REQUIRE_API_KEY": "true",
            "RATE_LIMIT_ENABLED": "true",
            "RATE_LIMIT_REQUESTS": "2",
            "RATE_LIMIT_WINDOW_SECONDS": "60",
        }
        img_bytes = _make_dummy_png_bytes()

        with (
            patch.dict(os.environ, env, clear=False),
            patch.object(api_main, "NetV2Classifier", _FakeNetV2),
            patch.object(api_main, "SVMClassifier", _FakeSVM),
            TestClient(api_main.app) as client,
        ):
            # Health dan root terbuka tanpa API key
            self.assertEqual(client.get("/health").status_code, 200)
            self.assertEqual(client.get("/").status_code, 200)

            # Predict ditolak tanpa API key, dan spam tanpa key ke-3 diblokir rate limiter (429)
            unauth_headers = {"X-Forwarded-For": "198.51.100.1"}
            unauth_svm = client.post(
                "/predict/svm",
                headers=unauth_headers,
                files={"file": ("sample.png", img_bytes, "image/png")},
            )
            unauth_netv2 = client.post(
                "/predict/netv2",
                headers=unauth_headers,
                files={"file": ("sample.png", img_bytes, "image/png")},
            )
            unauth_limited = client.post(
                "/predict/svm",
                headers=unauth_headers,
                files={"file": ("sample.png", img_bytes, "image/png")},
            )
            self.assertEqual(unauth_svm.status_code, 401)
            self.assertEqual(unauth_netv2.status_code, 401)
            self.assertEqual(unauth_limited.status_code, 429)

            # Request valid dari IP lain diterima sampai batas kuota (2), request ke-3 dibatasi (429)
            auth_headers = {
                "X-API-Key": "prod-secret-key",
                "X-Forwarded-For": "198.51.100.2",
            }
            ok1 = client.post(
                "/predict/svm",
                headers=auth_headers,
                files={"file": ("sample.png", img_bytes, "image/png")},
            )
            ok2 = client.post(
                "/predict/netv2",
                headers=auth_headers,
                files={"file": ("sample.png", img_bytes, "image/png")},
            )
            limited = client.post(
                "/predict/svm",
                headers=auth_headers,
                files={"file": ("sample.png", img_bytes, "image/png")},
            )

            self.assertEqual(ok1.status_code, 200)
            self.assertEqual(ok1.json()["model"], "svm")
            self.assertEqual(ok2.status_code, 200)
            self.assertEqual(ok2.json()["model"], "netv2")
            self.assertEqual(limited.status_code, 429)


if __name__ == "__main__":
    unittest.main()
