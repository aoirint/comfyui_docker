# Third-Party Notices

This project builds Docker images that include third-party software.

## Comfy-Org/ComfyUI

- Source: <https://github.com/Comfy-Org/ComfyUI>
- Bundled location in image: `/opt/ComfyUI`
- Version: see `COMFYUI_COMMIT` in `Dockerfile`
- License: GNU General Public License v3.0

The image includes the selected upstream checkout, including the license files
that are present in that checkout.

## aoirint/skills

- Source: [aoirint/skills](https://github.com/aoirint/skills), virtual paths
  under `.apm/skills/`
- Pinned commit:
  [`6a1e6431bbaed762f55783c3dcd7dc4b07736596`](https://github.com/aoirint/skills/tree/6a1e6431bbaed762f55783c3dcd7dc4b07736596)
- Deployed paths: `.agents/skills/{apm-workflow,changelog-workflow,code-quality-check,commit-message-quality-check,docker-quality-check,git-worktree-workflow,github-workflow,gitignore-workflow,prose-quality-check,python-quality-check,release-note-workflow,security-check}/`
- License: [MIT](https://github.com/aoirint/skills/blob/6a1e6431bbaed762f55783c3dcd7dc4b07736596/LICENSE)
- Copyright: Copyright (c) 2026 aoirint
