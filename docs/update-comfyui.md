# Updating ComfyUI

This document describes the repeatable process for updating the ComfyUI version
used by this Docker image and verifying that the resulting image starts
correctly.

Use this procedure for routine ComfyUI updates, dependency lockfile refreshes,
and Docker image validation.

## Scope

The update normally touches these files:

- `Dockerfile`
- `pyproject.toml`
- `uv.lock`
- `CHANGELOG.md`

The repository uses `pyproject.toml` as the local dependency declaration, but
the source of truth for ComfyUI runtime dependencies is the upstream
`requirements.txt` at the selected ComfyUI commit.

## Prerequisites

Install or make available:

- Git
- Docker Engine with BuildKit
- `uv`
- `hadolint`

The validation commands below assume the image name `comfyui:cooldown-test`.
Use another temporary tag if that tag is already meaningful in your local
environment.

## 1. Select The Target Version

List upstream version tags:

```shell
git ls-remote --tags https://github.com/Comfy-Org/ComfyUI.git 'refs/tags/v*'
```

For a candidate tag, fetch the exact commit and release date:

```shell
git clone --filter=blob:none --no-checkout https://github.com/Comfy-Org/ComfyUI.git /tmp/comfyui-upstream
git -C /tmp/comfyui-upstream fetch --tags origin
git -C /tmp/comfyui-upstream show --no-patch --format='%H %ci %s' vX.Y.Z
```

Only adopt a ComfyUI release after the repository cooldown window has passed.
The current baseline is a minimum of 7 days after the upstream release timestamp
or tag commit timestamp.

Record the selected commit SHA. Prefer the tag commit for released versions
instead of a branch name.

## 2. Read Upstream Requirements

Print the upstream requirements for the selected version:

```shell
git -C /tmp/comfyui-upstream show vX.Y.Z:requirements.txt
```

Update `pyproject.toml` so its `[project].dependencies` match the upstream
`requirements.txt`.

Keep the comment above the first dependency pointed at the exact upstream
commit, for example:

```toml
# https://github.com/Comfy-Org/ComfyUI/blob/<commit-sha>/requirements.txt
```

When translating requirements:

- Keep pinned versions exactly pinned.
- Keep lower bounds and compatible-release specifiers as upstream writes them.
- Include the dependencies listed under upstream comments such as
  `#non essential dependencies` when this image currently includes them.
- Preserve local package source settings such as the PyTorch CUDA index unless
  the update intentionally changes the CUDA or PyTorch packaging strategy.

## 3. Update The Dockerfile

Set `COMFYUI_COMMIT` to the selected upstream commit:

```dockerfile
ARG COMFYUI_COMMIT=<commit-sha>
```

Keep base images pinned by digest:

```dockerfile
ARG CUDA_RUNTIME_IMAGE=nvidia/cuda:<tag>@sha256:<digest>
ARG UV_IMAGE=ghcr.io/astral-sh/uv:<tag>@sha256:<digest>
```

To refresh a base image digest, inspect the image:

```shell
docker buildx imagetools inspect nvidia/cuda:<tag>
docker buildx imagetools inspect ghcr.io/astral-sh/uv:<tag>
```

Use the multi-architecture index digest unless the image is intentionally
limited to one platform.

Keep apt packages version-pinned so `hadolint` can verify the Dockerfile:

```dockerfile
apt-get install -y --no-install-recommends \
    ca-certificates=<version> \
    ffmpeg=<version>
```

To find apt candidate versions for the pinned CUDA runtime image:

```shell
docker run --rm 'nvidia/cuda:<tag>@sha256:<digest>' bash -lc \
  'set -euo pipefail; apt-get update >/dev/null; apt-cache policy ca-certificates ffmpeg git libgl1 libglib2.0-0t64 libsm6 libxext6 libxrender1'
```

ComfyUI stores its local database outside the model and output directories by
default. This image keeps runtime data under `/data`, so the entrypoint should
continue to pass:

```shell
--database-url sqlite:////data/user/comfyui.db
```

Also ensure `/data/user` is created and owned by the runtime user.

## 4. Refresh `uv.lock`

Run lockfile resolution from the repository root or the update worktree:

```shell
uv lock --upgrade
```

The repository configures:

```toml
[tool.uv]
exclude-newer = "P7D"
```

Keep that setting enabled. It prevents newly published packages from being
selected before the cooldown window has passed.

After the lockfile update, verify it is consistent:

```shell
uv lock --check
```

Review the resolver output and `uv.lock` diff for unexpected package upgrades.
If a package appears newer than the cooldown policy should allow, stop and
investigate before building the image.

## 5. Run Static Checks

Run Dockerfile linting:

```shell
hadolint Dockerfile
```

Run Docker's build checks:

```shell
docker build --check .
```

Both commands should complete without warnings for routine updates.

If `hadolint` reports `DL3008`, pin the affected apt package versions.
If it reports `DL3003` or `SC2164` around a `cd`, prefer `git -C` or `WORKDIR`
instead of changing directories inside a shell block.

## 6. Build The Image

Build the image:

```shell
docker build --progress=plain -t comfyui:cooldown-test .
```

The first build after a dependency update can take several minutes because the
CUDA, PyTorch, and ComfyUI workflow-template wheels are large.

If the build fails while pulling `ghcr.io/astral-sh/uv`, check local Docker
authentication state first. The image may still be publicly readable even when
an expired local credential causes Docker to fail.

## 7. Run Smoke Tests

Check that core Python packages import:

```shell
docker run --rm --entrypoint python comfyui:cooldown-test -c \
  'import torch, torchvision, torchaudio; print(torch.__version__); print(torchvision.__version__); print(torchaudio.__version__)'
```

Start ComfyUI in CPU mode for an environment-independent HTTP smoke test:

```shell
docker run --rm -d \
  --name comfyui-cooldown-test \
  -p 127.0.0.1:18188:8188 \
  comfyui:cooldown-test \
  --cpu
```

Wait for the frontend route and API to respond:

```shell
for i in $(seq 1 60); do
  if curl -fsS -o /tmp/comfyui-index.html http://127.0.0.1:18188/; then
    echo ready
    break
  fi
  sleep 2
done

curl -fsS http://127.0.0.1:18188/system_stats
docker logs --tail 140 comfyui-cooldown-test
```

Confirm:

- `/` returns HTTP 200.
- `/system_stats` reports the selected ComfyUI version.
- `required_frontend_version` matches the upstream frontend package version.
- `installed_templates_version` matches the upstream workflow templates version.
- The log reaches `Starting server`.
- Database migrations complete or the existing database opens successfully.
- There is no `Failed to initialize database` error.

Stop the test container after validation:

```shell
docker stop comfyui-cooldown-test
```

## 8. Review And Record The Change

Review the diff:

```shell
git diff --stat
git diff --check
git diff -- Dockerfile pyproject.toml CHANGELOG.md
```

Update `CHANGELOG.md` under `Unreleased` with maintainer-facing notes. Include:

- The target ComfyUI version.
- Any base image digest updates.
- Any persistence, entrypoint, or runtime behavior changes.
- Any noteworthy validation result or limitation.

## 9. Commit

Commit the completed update after the checks pass:

```shell
git add CHANGELOG.md Dockerfile pyproject.toml uv.lock
git commit -m "build: update ComfyUI to vX.Y.Z"
```

If an AI coding agent materially authored the change, include the repository's
expected co-author trailer.

## Troubleshooting

### Database initialization fails

If the log contains `Failed to initialize database` and the server still starts,
verify the entrypoint includes:

```shell
--database-url sqlite:////data/user/comfyui.db
```

Also verify `/data/user` exists and is owned by the runtime UID/GID.

### The first curl fails with connection reset

This can happen while ComfyUI is still starting. Continue polling until the
server is ready or until the retry loop times out.

### Docker build takes a long time at `exporting layers`

This is expected for full CUDA/PyTorch images. The final virtual environment
layer is large.

### The smoke test runs without GPU

The documented smoke test intentionally uses `--cpu` so it can run on machines
without NVIDIA runtime access. A separate GPU test can be run with:

```shell
docker run --gpus all --rm --init -it \
  -v "./data:/data" \
  -p "127.0.0.1:8188:8188/tcp" \
  comfyui:cooldown-test
```

Use the GPU test when validating CUDA hardware compatibility or runtime
configuration changes.
