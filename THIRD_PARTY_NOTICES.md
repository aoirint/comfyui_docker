# Third-Party Notices

This project builds Docker images that include third-party software.

## Comfy-Org/ComfyUI

- Source: https://github.com/Comfy-Org/ComfyUI
- Bundled location in image: `/opt/ComfyUI`
- Version: see `COMFYUI_COMMIT` in `Dockerfile`
- License: GNU General Public License v3.0

The image includes the selected upstream checkout, including the license files
that are present in that checkout.

## aoirint/skills

- Source: [aoirint/skills](https://github.com/aoirint/skills), virtual paths
  under `.apm/skills/`
- Pinned commit:
  [`8a2bb13afb40cc31dbcd3280b74004834d428b4a`](https://github.com/aoirint/skills/tree/8a2bb13afb40cc31dbcd3280b74004834d428b4a)
- Deployed paths: `.agents/skills/{changelog-workflow,code-quality-check,commit-message-quality-check,git-worktree-workflow,github-actions-quality-check,gitignore-workflow,issue-quality-check,pull-request-quality-check,prose-quality-check,release-note-workflow,security-check,skill-quality-check}/`
- License: [MIT](https://github.com/aoirint/skills/blob/8a2bb13afb40cc31dbcd3280b74004834d428b4a/LICENSE)
