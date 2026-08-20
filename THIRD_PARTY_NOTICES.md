# Third-Party Notices

This project builds Docker images that include third-party software.

## Comfy-Org/ComfyUI

- Source: <https://github.com/Comfy-Org/ComfyUI>
- Bundled location in image: `/opt/ComfyUI`
- Version: see `COMFYUI_COMMIT` in `Dockerfile`
- License: GNU General Public License v3.0

The image includes the selected upstream checkout, including the license files
that are present in that checkout.

## NVIDIA CUDA

- Source: <https://hub.docker.com/r/nvidia/cuda>
- Bundled location in image: base operating system and CUDA runtime libraries
- Version: see `CUDA_RUNTIME_IMAGE` in `Dockerfile`
- License:
  [NVIDIA Deep Learning Container License](https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license)

The base image includes `/NGC-DL-CONTAINER-LICENSE` with the applicable license
terms. Ubuntu packages installed on top of the base image retain their package
copyright files under `/usr/share/doc`.

## aoirint/skills

- Source: [aoirint/skills](https://github.com/aoirint/skills), virtual paths
  under `.apm/skills/`
- Pinned commit:
  [`0e41c088efb2bdf44ca58564bb5168d119ac9135`](https://github.com/aoirint/skills/tree/0e41c088efb2bdf44ca58564bb5168d119ac9135)
- Deployed paths: `.agents/skills/{apm-workflow,changelog-workflow,code-quality-check,commit-message-quality-check,docker-quality-check,git-worktree-workflow,github-workflow,gitignore-workflow,prose-quality-check,python-quality-check,release-note-workflow,security-check}/`
- License: [MIT](https://github.com/aoirint/skills/blob/0e41c088efb2bdf44ca58564bb5168d119ac9135/LICENSE)
- Copyright: Copyright (c) 2026 aoirint
