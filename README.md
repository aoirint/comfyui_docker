# ComfyUI in Docker

- <https://github.com/Comfy-Org/ComfyUI>

## Requirements

- Ubuntu 24.04 or later
- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) 29 or later
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- NVIDIA GeForce RTX 4000 series, 5000 series
  - 1000 series does not work due to CUDA compatibility.
  - 2000 series and 3000 series might work, but untested.

## Usage

### 1. Build Docker image

```shell
sudo docker build -t comfyui .
```

### 2. Run ComfyUI

```shell
# Create permanent directories (UID:GID = 1000:1000)
mkdir -p \
  ./data/input \
  ./data/output \
  ./data/models/checkpoints \
  ./data/models/controlnet \
  ./data/models/loras \
  ./data/custom_nodes
sudo chown -R 1000:1000 ./data

sudo docker run --gpus all --rm --init -it -v "./data:/data" -p "127.0.0.1:8188:8188/tcp" comfyui
```

## Data directories

- Put checkpoint models in `./data/models/checkpoints`
- Put ControlNet models in `./data/models/controlnet`
- Put LoRA models in `./data/models/loras`
- Put custom nodes in `./data/custom_nodes`
- Generated images are written to `./data/output`
