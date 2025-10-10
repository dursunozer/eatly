# Eatly Vision Backend (FastAPI on HF Spaces)

- API: POST `/api/vision/analyze` (Body: image bytes, Content-Type: application/octet-stream)
- Query: `features=labels,objects` (opsiyonel), `threshold=0.20` (opsiyonel)

## Build & Run (Docker)
```
docker build -t eatly-vision .
docker run -p 7860:7860 eatly-vision
```

## HF Spaces
- Space type: Docker
- Hardware: T4/RTX GPU (mümkünse GPU seçin)
- Entrypoint: `uvicorn app.main:app --host 0.0.0.0 --port 7860`

