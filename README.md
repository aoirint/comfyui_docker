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

## License

This repository's Dockerfile, documentation, and project-specific files are
licensed under the MIT License. See [LICENSE](LICENSE).

The published Docker image bundles
[Comfy-Org/ComfyUI](https://github.com/Comfy-Org/ComfyUI) at the commit
specified by `COMFYUI_COMMIT` in the Dockerfile. ComfyUI is licensed under the
GNU General Public License v3.0. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and the upstream license
information for details.

## Maintenance

- [Updating ComfyUI](docs/update-comfyui.md)

## Release procedure

Releases are driven by the root `VERSION` file and the Git tags on GitHub.

1. Update `VERSION` to the version to publish.
   - Stable releases use SemVer without a prerelease suffix, such as `0.2.0`.
   - Prereleases use SemVer with a prerelease suffix, such as `0.2.0-rc.1`.
2. Commit the `VERSION` change and merge it to `main`.
3. The build workflow checks whether `v<VERSION>` already exists on GitHub.
   - If the tag does not exist and `VERSION` is stable, it creates a latest GitHub Release and publishes Docker images tagged `v<VERSION>` and `latest`.
   - If the tag does not exist and `VERSION` is a prerelease, it creates a prerelease GitHub Release and publishes the Docker image tagged `edge`.
   - If `VERSION` is `0.0.0`, it is treated as an edge build and only the `edge` Docker image is updated.
   - If the tag already exists, the push is treated as an edge build and only the `edge` Docker image is updated.
