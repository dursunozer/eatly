# CPU-friendly base image for HF Spaces
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/data/.cache/huggingface \
    TRANSFORMERS_CACHE=/data/.cache/huggingface/transformers \
    HF_HUB_CACHE=/data/.cache/huggingface/hub \
    HUGGINGFACE_HUB_CACHE=/data/.cache/huggingface/hub \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PORT=7860

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create writable cache directory on HF Spaces
RUN mkdir -p /data/.cache/huggingface && chmod -R 777 /data

COPY requirements.txt /app/requirements.txt
# Install CPU-only PyTorch first, then other deps
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu torch && \
    pip install --no-cache-dir -r /app/requirements.txt

COPY app /app/app

EXPOSE 7860

CMD ["sh", "-lc", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]

