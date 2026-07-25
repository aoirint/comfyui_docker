# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Update ComfyUI to v0.28.0.
- Refresh the locked Python dependencies to match ComfyUI v0.28.0 requirements.

## [v0.2.0]

### Added

- Add a reusable ComfyUI update and smoke-test procedure.
- Add repository agent guidance and local Agent Skills for changelog, quality, security, GitHub Actions, git worktree, and review workflows.

### Changed

- Update ComfyUI to v0.21.0.
- Update Python dependencies.
- Store the ComfyUI database under `/data/user` so it persists with the container data directory.
- Update uv to 0.11.13.
- Configure uv dependency resolution with `exclude-newer`.
- Pin Docker base images by digest.
- Rework the release pipeline to derive GitHub Releases and Docker image tags from a new `VERSION` file and existing Git tags, with the release procedure documented in the README.

## [v0.1.0]

### Added

- Run ComfyUI v0.18.1 as a Docker container.

[Unreleased]: https://github.com/aoirint/comfyui_docker/compare/v0.2.0...HEAD
[v0.2.0]: https://github.com/aoirint/comfyui_docker/releases/tag/v0.2.0
[v0.1.0]: https://github.com/aoirint/comfyui_docker/releases/tag/v0.1.0
