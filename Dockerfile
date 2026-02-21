FROM node:20-bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/yourname/toxiscan-yolk
LABEL org.opencontainers.image.description="ToxiScan runtime: Node.js 20 + Python 3.11 + HuggingFace"

RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    python3.11-venv \
    build-essential \
    curl \
    git \
    iproute2 \
  && rm -rf /var/lib/apt/lists/*

# Make python3 point to 3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Make python point to 3.11
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip --break-system-packages

# Install Python ML deps at image build time so startup is fast
# CPU-only PyTorch — much smaller image (~800MB vs ~2.5GB GPU)
RUN pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cpu \
    torch==2.3.1+cpu \
    --break-system-packages

RUN pip install --no-cache-dir \
    fastapi==0.111.0 \
    "uvicorn[standard]==0.30.1" \
    transformers==4.41.2 \
    sentencepiece==0.2.0 \
    accelerate==0.31.0 \
    python-Levenshtein==0.25.1 \
    --break-system-packages

# HuggingFace cache dir — Pterodactyl will volume-mount /data
ENV TRANSFORMERS_CACHE=/data/hf_cache
ENV HF_HOME=/data/hf_cache

# Pterodactyl requires this user/home
RUN useradd -m -d /home/container -s /bin/bash container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
