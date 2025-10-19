Git hooks for USDX-Lyrics
=========================

This repository includes a client-side pre-push hook that checks GitHub for an existing
published release with the same version tag as defined in `addons/usdx_lyrics/plugin.cfg`.

Purpose
-------
Prevent accidental pushes that would create duplicate published releases for the same version.

Installation
------------
You can enable the hooks in two ways:

1) Use Git's `core.hooksPath` (recommended for repository-local hooks):

   git config core.hooksPath .githooks

   This tells Git to run hooks from the `.githooks/` folder in this repository.

2) Symlink the hook into `.git/hooks/pre-push`:

   ln -s ../../.githooks/pre-push .git/hooks/pre-push

Requirements
------------
- The hook will attempt to call the GitHub API and therefore needs a token with repo read access.
- Set the token in the environment variable `GITHUB_PAT` before pushing, for example:

  export GITHUB_PAT="ghp_..."

Fallback: the hook will also look for `github.token` in your git config (not recommended).

Behavior
--------
- If `GITHUB_PAT` (or `github.token`) is missing, the hook will skip the check and allow the push.
- If a published release (draft == false and published_at != null) already exists for the tag (normalized to `v<version>`), the hook fails and the push is aborted.
- If the release is not published (draft or unpublished) or no release exists, the push is allowed.

Notes
-----
- Client-side hooks run locally — to enforce this check for all contributors, add instructions in
  your CONTRIBUTING.md or use server-side protection (branch protection rules plus required
  status checks in CI).
- If you want the check to happen in CI (e.g., PR validation), see `.github/workflows/release.yml` which
  includes a `check-published` job that enforces the same rule.
