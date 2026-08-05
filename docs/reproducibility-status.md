# Reproducibility status

## Honest status

The original machine has a working accepted runtime, but the work was accumulated in a large dirty Wine checkout and cache. This repository is the recovery point, not yet a complete clean rebuild recipe.

### Recovered

- A private Git remote exists at `https://github.com/NickPittas/AE4Linux`.
- Accepted binary hashes are recorded.
- The accepted Aegnux Flatpak commit, Wine runner version, prefix separation, launcher environment, Flatpak policy, and AE one-byte change are recorded.
- The generic CEP alignment patch and FORCE portal fallback patch are preserved.
- Rejected approaches are explicitly separated from accepted behavior.

### Current blocker discovered during repository inventory

The accepted-state prose records original `shell32.dll` hash `9ede7776…`, but the currently deployed `runner-11.12-test` has hash `12ad530b…`, the locally built ShellView-modified binary. `scripts/verify-state.sh` fails on this mismatch by design. No rollback or replacement has been performed.

### Still required before portable one-command reproduction

1. Split the dirty Wine checkout into clean production-only patches, excluding tests, mocks, harnesses, plans, debug tracing, and reverted variants.
2. Reconstruct the accepted D2D, DirectWrite, Shell32, win32u, winex11, and comdlg32 patch series from the exact upstream Wine 11.12 commit.
3. Recover the exact accepted DXVK source commit/diff and the nvcuda bridge source commit/diff. Current records identify binaries and provenance but do not yet form a clean build input.
4. Record the exact configure flags, compiler/toolchain image, and build commands for each accepted module.
5. Replace machine-local artifact paths with repository-relative inputs or documented private release assets.
6. Add a release manifest mapping every staged file to source commit, patch series, build command, and SHA-256.
7. Add a clean installer that creates a separate runner/prefix and refuses to overwrite the original Aegnux state.

Until these are complete, `scripts/verify-state.sh` verifies an existing installation; it does not pretend to rebuild one from an empty machine.

## Why the prefix is excluded

The accepted prefix is approximately 103 GB and contains user-installed Adobe software, caches, user configuration, and proprietary components. Copying it is useful for forensic rollback but not a reproducible or portable build input.

## Why AE is represented as a patch, not a binary

The accepted AE change is a one-byte transformation of `libcef.dll`. The repository records original/accepted hashes and applies the byte only to a matching locally installed file. This preserves provenance without redistributing Adobe software.

## Release model

The canonical model should be:

- Git: source patches, scripts, manifests, docs.
- Private GitHub Release assets: rebuilt Wine/DXVK/nvcuda modules only when licences allow.
- User machine: Aegnux Flatpak, legally installed AE, prefix, user extensions, media.
- Verification: hash-gated staging and rollback.
