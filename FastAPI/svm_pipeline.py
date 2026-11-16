import warnings
from pathlib import Path

import cv2
import joblib
import numpy as np
from PIL import Image, ImageOps
from scipy import ndimage as ndi
from scipy.stats import skew
from skimage.feature import local_binary_pattern

IMG_SIZE = (224, 224)
MAX_PHOTO_SIDE = 416

# Parameter segmentasi sesuai SVM.ipynb
S_MIN, V_MIN = 0.12, 0.10
HUE_MAX_LOW, HUE_MIN_HIGH = 55, 290
K_BLUR, K_CLOSE, K_OPEN = 7, 13, 9
MIN_COVER = 0.10

# Parameter pembuang area meja kayu / nampan yang menyentuh tepi gambar
WOOD_HAB, WOOD_V, WOOD_S = 40, 0.65, 0.25
WOOD_MIN_FRAC = 0.01


def _white_patch(img01: np.ndarray, pct: int = 98, limit: tuple[float, float] = (0.7, 1.4)) -> np.ndarray:
    """Koreksi warna cahaya sederhana untuk menentukan mask segmentasi."""
    p = np.percentile(img01.reshape(-1, 3), pct, axis=0) + 1e-6
    gain = np.clip(p.mean() / p, *limit)
    return np.clip(img01 * gain, 0, 1).astype(np.float32)


def segment_meat(img01: np.ndarray) -> tuple[np.ndarray, bool]:
    """Pisahkan area daging dari latar. Kembalikan (mask 0/1, apakah fallback seluruh gambar)."""
    blur = cv2.GaussianBlur(_white_patch(img01), (K_BLUR, K_BLUR), 0)
    hsv = cv2.cvtColor(blur, cv2.COLOR_BGR2HSV)
    lab = cv2.cvtColor(blur, cv2.COLOR_BGR2Lab)
    h, s, v = hsv[..., 0], hsv[..., 1], hsv[..., 2]
    a, b = lab[..., 1], lab[..., 2]
    hab = np.degrees(np.arctan2(b, np.maximum(a, 1e-3)))

    raw = (((h <= HUE_MAX_LOW) | (h >= HUE_MIN_HIGH)) & (s >= S_MIN) & (v >= V_MIN)).astype(np.uint8)

    kayu = ((hab >= WOOD_HAB) & (v < WOOD_V) & (s >= WOOD_S)).astype(np.uint8)
    kayu = cv2.morphologyEx(kayu, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7)))
    n, lab_k, stats, _ = cv2.connectedComponentsWithStats(kayu, connectivity=8)
    height, width = kayu.shape
    buang = np.zeros_like(kayu)
    for k in range(1, n):
        x0, y0, w0, h0, area = stats[k]
        touches_edge = x0 <= 2 or y0 <= 2 or x0 + w0 >= width - 2 or y0 + h0 >= height - 2
        if touches_edge and area >= WOOD_MIN_FRAC * height * width:
            buang[lab_k == k] = 1

    nokayu = (raw & (buang == 0)).astype(np.uint8)
    closed = cv2.morphologyEx(nokayu, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (K_CLOSE, K_CLOSE)))
    opened = cv2.morphologyEx(closed, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (K_OPEN, K_OPEN)))

    n2, lab2, stats2, _ = cv2.connectedComponentsWithStats(opened, connectivity=8)
    if n2 > 1:
        k = 1 + int(np.argmax(stats2[1:, cv2.CC_STAT_AREA]))
        largest = (lab2 == k).astype(np.uint8)
    else:
        largest = opened

    filled = ndi.binary_fill_holes(largest > 0).astype(np.uint8)
    if filled.mean() < MIN_COVER:
        return np.ones(filled.shape, np.uint8), True
    return filled, False


def _prop_hist(vals: np.ndarray, bins: int, rng: tuple[float, float]) -> np.ndarray:
    h, _ = np.histogram(np.clip(vals, rng[0], rng[1]), bins=bins, range=rng)
    return h / max(h.sum(), 1)


def _l2_hist(vals: np.ndarray, bins: int, rng: tuple[float, float]) -> np.ndarray:
    h, _ = np.histogram(np.clip(vals, rng[0], rng[1]), bins=bins, range=rng)
    h = h.astype(np.float64)
    norm = np.linalg.norm(h)
    return h / norm if norm > 0 else h


def _shift_hue(h_deg: np.ndarray) -> np.ndarray:
    return (h_deg + 40) % 360


def _moments(x: np.ndarray) -> list[float]:
    return [float(x.mean()), float(x.std()), float(np.nan_to_num(skew(x)))]


def extract_features_lanjutan(img01: np.ndarray, mask: np.ndarray) -> np.ndarray:
    """Ekstrak 183 fitur Lanjutan (Lab, HSV, momen warna, luminans relatif, LBP 3 skala, Sobel, kilap/pucat)."""
    m = mask > 0
    lab = cv2.cvtColor(img01, cv2.COLOR_BGR2Lab)
    hsv = cv2.cvtColor(img01, cv2.COLOR_BGR2HSV)
    L, a, b = lab[..., 0][m], lab[..., 1][m], lab[..., 2][m]
    h, s, v = hsv[..., 0][m], hsv[..., 1][m], hsv[..., 2][m]

    parts = [
        _l2_hist(a, 24, (-5, 45)),
        _l2_hist(b, 24, (-5, 45)),
        _l2_hist(_shift_hue(h), 20, (0, 100)),
        _l2_hist(s, 24, (0, 1)),
        np.array(
            _moments(a)
            + _moments(b)
            + _moments(s)
            + [float(L.std() / (L.mean() + 1e-6)), float(np.nan_to_num(skew(L)))]
        ),
        _l2_hist(L / (L.mean() + 1e-6), 16, (0, 2)),
    ]

    gray = cv2.cvtColor(img01, cv2.COLOR_BGR2GRAY)
    for r, p in [(1, 8), (2, 16), (3, 24)]:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            lbp = local_binary_pattern(gray, p, r, method="uniform")
        parts.append(_prop_hist(lbp[m], p + 2, (0, p + 2)))

    gn = gray / (gray[m].mean() + 1e-6)
    gx = cv2.Sobel(gn, cv2.CV_32F, 1, 0, ksize=3)
    gy = cv2.Sobel(gn, cv2.CV_32F, 0, 1, ksize=3)
    parts.append(_prop_hist(np.sqrt(gx**2 + gy**2)[m], 8, (0, 1.0)))

    parts.append(
        np.array(
            [
                np.mean((v > 0.92) & (s < 0.25)),
                np.mean((s < 0.18) & (v > 0.45) & (v <= 0.92)),
            ]
        )
    )
    return np.concatenate(parts)


def preprocess_for_svm(image: Image.Image) -> tuple[np.ndarray, bool]:
    """Siapkan foto -> (fitur 1x183, segmentation_fallback)."""
    im = ImageOps.exif_transpose(image).convert("RGB")
    im.thumbnail((MAX_PHOTO_SIDE, MAX_PHOTO_SIDE), Image.Resampling.LANCZOS)
    img_u8 = cv2.resize(cv2.cvtColor(np.array(im), cv2.COLOR_RGB2BGR), IMG_SIZE)
    img01 = img_u8.astype(np.float32) / 255.0
    mask, fallback = segment_meat(img01)
    features = extract_features_lanjutan(img01, mask).reshape(1, -1)
    return features, fallback


class SVMClassifier:
    """Wrapper inference untuk pipeline StandardScaler + SVC."""

    def __init__(self, model_path: Path):
        self.pipeline = joblib.load(model_path)

    def predict(self, image: Image.Image) -> tuple[np.ndarray, bool]:
        features, fallback = preprocess_for_svm(image)
        probs = self.pipeline.predict_proba(features)[0]
        return probs, fallback
