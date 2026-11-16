import io
import threading
from contextlib import asynccontextmanager
from pathlib import Path

import numpy as np
from ai_edge_litert.interpreter import Interpreter
from fastapi import FastAPI, File, HTTPException, UploadFile
from PIL import Image, ImageOps, UnidentifiedImageError

from svm_pipeline import SVMClassifier

BASE_DIR = Path(__file__).parent
NETV2_MODEL_PATH = BASE_DIR / "mobilenetv2_meat_freshness_quantized.tflite"
SVM_MODEL_PATH = BASE_DIR / "svm_meat_fitur_lanjutan.pkl"

IMG_SIZE = (224, 224)
# Urutan kelas sesuai TrainModel_MobileNetV2.ipynb & SVM.ipynb (0=FRESH, 1=HALF-FRESH, 2=SPOILED)
CLASS_NAMES = ["fresh", "half-fresh", "spoiled"]
MAX_UPLOAD_BYTES = 10 * 1024 * 1024


def preprocess_netv2(image: Image.Image) -> np.ndarray:
    """Resize ke 224x224 RGB dan normalisasi ke [0, 1] sesuai ImageDataGenerator(rescale=1./255)."""
    image = ImageOps.exif_transpose(image).convert("RGB").resize(IMG_SIZE)
    arr = np.asarray(image, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)


class NetV2Classifier:
    """Wrapper inference untuk model MobileNetV2 TFLite."""

    def __init__(self, model_path: Path):
        self.interpreter = Interpreter(model_path=str(model_path))
        self.interpreter.allocate_tensors()
        self.input_index = self.interpreter.get_input_details()[0]["index"]
        self.output_index = self.interpreter.get_output_details()[0]["index"]
        self.lock = threading.Lock()  # interpreter tidak thread-safe

    def predict(self, image: Image.Image) -> np.ndarray:
        x = preprocess_netv2(image)
        with self.lock:
            self.interpreter.set_tensor(self.input_index, x)
            self.interpreter.invoke()
            probs = self.interpreter.get_tensor(self.output_index)[0].copy()

        if not np.isclose(probs.sum(), 1.0, atol=1e-3) or (probs < 0).any():
            e = np.exp(probs - probs.max())
            probs = e / e.sum()
        return probs


async def _read_uploaded_image(file: UploadFile) -> Image.Image:
    data = await file.read()
    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(413, "File terlalu besar (maks 10MB)")
    try:
        image = Image.open(io.BytesIO(data))
        image.load()
        return image
    except (UnidentifiedImageError, OSError):
        raise HTTPException(400, "File bukan gambar yang valid")


def _format_prediction(model_name: str, probs: np.ndarray, **extra) -> dict:
    idx = int(np.argmax(probs))
    result = {
        "model": model_name,
        "label": CLASS_NAMES[idx],
        "confidence": float(probs[idx]),
        "probabilities": {name: float(p) for name, p in zip(CLASS_NAMES, probs)},
    }
    result.update(extra)
    return result


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.netv2 = NetV2Classifier(NETV2_MODEL_PATH)
    app.state.svm = SVMClassifier(SVM_MODEL_PATH)
    yield


app = FastAPI(title="PBL Meat Freshness API", lifespan=lifespan)


@app.get("/")
def root():
    return {
        "message": "Meat Freshness API. Lihat /docs",
        "endpoints": ["/predict/netv2", "/predict/svm", "/health"],
    }


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict/netv2")
async def predict_netv2(file: UploadFile = File(...)):
    image = await _read_uploaded_image(file)
    probs = app.state.netv2.predict(image)
    return _format_prediction("netv2", probs)


@app.post("/predict/svm")
async def predict_svm(file: UploadFile = File(...)):
    image = await _read_uploaded_image(file)
    probs, fallback = app.state.svm.predict(image)
    return _format_prediction("svm", probs, segmentation_fallback=fallback)
