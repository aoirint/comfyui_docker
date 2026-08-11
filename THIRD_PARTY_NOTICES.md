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
  [`2c77fb8583c437c7e47cd293f4bc703f410b9be0`](https://github.com/aoirint/skills/tree/2c77fb8583c437c7e47cd293f4bc703f410b9be0)
- Deployed paths: `.agents/skills/{apm-workflow,changelog-workflow,code-quality-check,commit-message-quality-check,docker-quality-check,git-worktree-workflow,github-workflow,gitignore-workflow,prose-quality-check,python-quality-check,release-note-workflow,security-check}/`
- License: [MIT](https://github.com/aoirint/skills/blob/2c77fb8583c437c7e47cd293f4bc703f410b9be0/LICENSE)
- Copyright: Copyright (c) 2026 aoirint
