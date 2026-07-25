# syntax=docker/dockerfile:1

ARG CUDA_RUNTIME_IMAGE=nvidia/cuda:13.2.0-cudnn-runtime-ubuntu24.04@sha256:7a31e9bfb2086e4b1ac08aa8e4718d7860730ecc6a9882d2f1e5ed6239f8ef5b
ARG UV_IMAGE=ghcr.io/astral-sh/uv:0.11.29@sha256:eb2843a1e56fd9e30c7276ce1a52cba86e64c7b385f5e3279a0e08e02dd058fc
ARG PYTHON_VERSION=3.12.13
ARG COMFYUI_REPO=https://github.com/Comfy-Org/ComfyUI.git
ARG COMFYUI_COMMIT=700821e1364eaab0e8f21c538a2131719fec57bf

FROM ${UV_IMAGE} AS uv

FROM ${CUDA_RUNTIME_IMAGE} AS builder

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG PYTHON_VERSION
ARG COMFYUI_REPO
ARG COMFYUI_COMMIT

ENV DEBIAN_FRONTEND=noninteractive \
    UV_NO_PROGRESS=1 \
    UV_LINK_MODE=copy \
    UV_CACHE_DIR=/root/.cache/uv \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PROJECT_ENVIRONMENT=/opt/python-venv \
    PATH=/opt/python-venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<'SH'
    apt-get update

    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        ffmpeg=7:6.1.1-3ubuntu5 \
        git=1:2.43.0-1ubuntu7.3 \
        libgl1=1.7.0-1build1 \
        libglib2.0-0t64=2.80.0-6ubuntu3.8 \
        libsm6=2:1.2.3-1build3 \
        libxext6=2:1.3.4-1build2 \
        libxrender1=1:0.9.10-1.1build1
SH

COPY --from=uv /uv /usr/local/bin/uv

WORKDIR /opt/app

COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked <<SH
    uv python install "${PYTHON_VERSION}"
    uv sync --frozen --no-dev --no-install-project --python "${PYTHON_VERSION}"
SH

RUN <<SH
    git clone "${COMFYUI_REPO}" /opt/ComfyUI
    git -C /opt/ComfyUI checkout --detach "${COMFYUI_COMMIT}"
SH


FROM ${CUDA_RUNTIME_IMAGE} AS runtime

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PROJECT_ENVIRONMENT=/opt/python-venv \
    PATH=/opt/python-venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    COMFYUI_HOME=/opt/ComfyUI

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<'SH'
    apt-get update

    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        ffmpeg=7:6.1.1-3ubuntu5 \
        libgl1=1.7.0-1build1 \
        libglib2.0-0t64=2.80.0-6ubuntu3.8 \
        libsm6=2:1.2.3-1build3 \
        libxext6=2:1.3.4-1build2 \
        libxrender1=1:0.9.10-1.1build1
SH

COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /opt/python /opt/python
COPY --from=builder /opt/python-venv /opt/python-venv
COPY --from=builder /opt/ComfyUI /opt/ComfyUI

RUN <<'SH'
    groupadd -o -g 1000 comfy
    useradd -m -o -u 1000 -g 1000 -g comfy -s /bin/bash comfy

    mkdir -p \
        /data/input \
        /data/output \
        /data/models/checkpoints \
        /data/models/controlnet \
        /data/models/loras \
        /data/custom_nodes \
        /data/user
    chown -R comfy:comfy /data /opt/ComfyUI
SH

WORKDIR /opt/ComfyUI

USER comfy

EXPOSE 8188

ENTRYPOINT ["python", "main.py", "--listen", "0.0.0.0", "--base-directory", "/data", "--database-url", "sqlite:////data/user/comfyui.db"]
