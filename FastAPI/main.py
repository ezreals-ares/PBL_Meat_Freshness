import io
import threading
from contextlib import asynccontextmanager
from pathlib import Path

import numpy as np
from ai_edge_litert.interpreter import Interpreter
from fastapi import FastAPI, File, HTTPException, UploadFile
from PIL import Image, UnidentifiedImageError

MODEL_PATH = Path(__file__).parent / "mobilenetv2_meat_freshness_quantized.tflite"
IMG_SIZE = (224, 224)
# TODO: sesuaikan urutan & nama kelas dengan urutan saat training (output model: 3 kelas).
CLASS_NAMES = ["fresh", "half-fresh", "spoiled"]
MAX_UPLOAD_BYTES = 10 * 1024 * 1024


def preprocess(image: Image.Image) -> np.ndarray:
    """Resize ke 224x224 dan normalisasi ke [-1, 1] (mobilenet_v2.preprocess_input)."""
    image = image.convert("RGB").resize(IMG_SIZE)
    arr = np.asarray(image, dtype=np.float32)
    arr = arr / 127.5 - 1.0
    return np.expand_dims(arr, axis=0)


class Classifier:
    def __init__(self, model_path: Path):
        self.interpreter = Interpreter(model_path=str(model_path))
        self.interpreter.allocate_tensors()
        self.input_index = self.interpreter.get_input_details()[0]["index"]
        self.output_index = self.interpreter.get_output_details()[0]["index"]
        self.lock = threading.Lock()  # interpreter tidak thread-safe

    def predict(self, x: np.ndarray) -> np.ndarray:
        with self.lock:
            self.interpreter.set_tensor(self.input_index, x)
            self.interpreter.invoke()
            return self.interpreter.get_tensor(self.output_index)[0].copy()


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.classifier = Classifier(MODEL_PATH)
    yield


app = FastAPI(title="PBL Meat Freshness API", lifespan=lifespan)


@app.get("/")
def root():
    return {"message": "Meat Freshness API. Lihat /docs"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    data = await file.read()
    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(413, "File terlalu besar (maks 10MB)")
    try:
        image = Image.open(io.BytesIO(data))
        image.load()
    except (UnidentifiedImageError, OSError):
        raise HTTPException(400, "File bukan gambar yang valid")

    probs = app.state.classifier.predict(preprocess(image))
    # Jika output belum berupa probabilitas (logits), terapkan softmax.
    if not np.isclose(probs.sum(), 1.0, atol=1e-3) or (probs < 0).any():
        e = np.exp(probs - probs.max())
        probs = e / e.sum()

    idx = int(np.argmax(probs))
    return {
        "label": CLASS_NAMES[idx],
        "confidence": float(probs[idx]),
        "probabilities": {n: float(p) for n, p in zip(CLASS_NAMES, probs)},
    }
