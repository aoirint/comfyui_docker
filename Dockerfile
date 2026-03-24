# syntax=docker/dockerfile:1

ARG CUDA_RUNTIME_TAG=13.2.0-cudnn-runtime-ubuntu24.04
ARG UV_VERSION=0.11.0
ARG PYTHON_VERSION=3.12.13
ARG COMFYUI_REPO=https://github.com/Comfy-Org/ComfyUI.git
ARG COMFYUI_COMMIT=ebf6b52e322664af91fcdc8b8848d31d5fb98f66

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM nvidia/cuda:${CUDA_RUNTIME_TAG} AS builder

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG UV_VERSION
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
        ca-certificates \
        ffmpeg \
        git \
        libgl1 \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1
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
    cd /opt/ComfyUI
    git checkout --detach "${COMFYUI_COMMIT}"
SH


FROM nvidia/cuda:${CUDA_RUNTIME_TAG} AS runtime

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PROJECT_ENVIRONMENT=/opt/python-venv \
    PATH=/opt/python-venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    CLI_ARGS="--listen 0.0.0.0 --port 8188 --disable-auto-launch" \
    COMFYUI_HOME=/opt/ComfyUI

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked <<'SH'
    apt-get update

    apt-get install -y --no-install-recommends \
        ca-certificates \
        ffmpeg \
        libgl1 \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1
SH

COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /opt/python /opt/python
COPY --from=builder /opt/python-venv /opt/python-venv
COPY --from=builder /opt/ComfyUI /opt/ComfyUI

RUN <<'SH'
    groupadd -o -g 1000 comfy
    useradd -m -o -u 1000 -g 1000 -g comfy -s /bin/bash comfy
    mkdir -p /data/input /data/output /data/models
    chown -R comfy:comfy /data /opt/ComfyUI
SH

WORKDIR /opt/ComfyUI

USER comfy

EXPOSE 8188
VOLUME ["/data"]

ENTRYPOINT ["python", "main.py"]
