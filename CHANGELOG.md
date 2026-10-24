# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.5.0] - 2026-10-24 UTC

### Changed

- Update ComfyUI from v0.32.0 to v0.41.0 and align the frontend, workflow
  templates, embedded documentation, and runtime dependencies with upstream.
- Update Python from 3.12.13 to 3.12.15 and refresh the Python lockfile,
  including PyTorch 2.14.1 and torchvision 0.29.1 on CUDA 13.0.
- Update uv to 0.13.1, Ubuntu CA certificates, Git, GLib, and the Docker
  build/setup GitHub Actions.

### Removed

- Remove torchaudio, which ComfyUI v0.41.0 no longer imports or requires.

### Security

- Update certifi, filelock, and setuptools to releases containing the fixes
  identified by the dependency advisory audit.
- Remove the compromised emSign CA from the system and Python CA bundles.

### Notes

- The maintainer authorized cooldown exceptions for trusted security
  advisories. Apply narrow exceptions for certifi 2026.10.19
  ([GHSA-6q48-6c7w-9gw2](https://github.com/certifi/python-certifi/security/advisories/GHSA-6q48-6c7w-9gw2)),
  filelock 4.2.1
  ([GHSA-2g95-wg33-c5x2](https://github.com/tox-dev/filelock/security/advisories/GHSA-2g95-wg33-c5x2)),
  setuptools 84.1.0
  ([GHSA-xmj3-9gf7-h52w](https://github.com/pypa/setuptools/security/advisories/GHSA-xmj3-9gf7-h52w)),
  and Ubuntu ca-certificates 20260816ubuntu0.24.04.1
  ([USN-8944-1](https://ubuntu.com/security/notices/USN-8944-1)).
  Review the temporary Python exceptions after 2026-10-27 UTC.

## [v0.4.0] - 2026-08-20 UTC

### Changed

- Update ComfyUI to v0.32.0 and refresh its locked runtime dependencies.
- Update the CUDA runtime image to v13.3.1.
- Update the uv base image to v0.12.3.

## [v0.3.0] - 2026-07-25 UTC

### Changed

- Update ComfyUI to v0.28.0.
- Refresh the locked Python dependencies to match ComfyUI v0.28.0 requirements.
- Update the uv base image to v0.11.29.
- Refresh GitHub Actions pins with a seven-day release cooldown.

## [v0.2.0]

### Added

- Add a reusable ComfyUI update and smoke-test procedure.
- Add repository agent guidance and local Agent Skills for changelog, quality,
  security, GitHub Actions, git worktree, and review workflows.

### Changed

- Update ComfyUI to v0.21.0.
- Update Python dependencies.
- Store the ComfyUI database under `/data/user` so it persists with the container data directory.
- Update uv to 0.11.13.
- Configure uv dependency resolution with `exclude-newer`.
- Pin Docker base images by digest.
- Rework the release pipeline to derive GitHub Releases and Docker image tags
  from a new `VERSION` file and existing Git tags, with the release procedure
  documented in the README.

## [v0.1.0]

### Added

- Run ComfyUI v0.18.1 as a Docker container.

[Unreleased]: https://github.com/aoirint/comfyui_docker/compare/v0.5.0...HEAD
[v0.5.0]: https://github.com/aoirint/comfyui_docker/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/aoirint/comfyui_docker/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/aoirint/comfyui_docker/releases/tag/v0.3.0
[v0.2.0]: https://github.com/aoirint/comfyui_docker/releases/tag/v0.2.0
[v0.1.0]: https://github.com/aoirint/comfyui_docker/releases/tag/v0.1.0
