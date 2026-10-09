# Reproducibility status

## Honest status

The author recorded a working runtime on the original machine, but that result has not been independently reproduced here. The work accumulated in a large dirty Wine checkout and cache. This public repository is an incomplete recovery/provenance record, not an installer or a complete clean rebuild recipe. “Accepted” labels describe the recorded observations, not a compatibility guarantee.

### Recovered

- The public Git repository is `https://github.com/NickPittas/AE4Linux`.
- Accepted binary hashes are recorded.
- The accepted Aegnux Flatpak commit, Wine runner version, prefix separation, launcher environment, Flatpak policy, and AE one-byte change are recorded.
- The generic CEP alignment patch and FORCE portal fallback patch are preserved.
- Rejected approaches are explicitly separated from accepted behavior.

### Unresolved discrepancy recorded during repository inventory

An earlier inventory recorded accepted-state `shell32.dll` hash `9ede7776…`, but observed hash `12ad530b…` in the deployed `runner-11.12-test`, a locally built ShellView-modified binary. `scripts/verify-state.sh` rejects that mismatch by design. The record contains no resolution; this is a historical observation, not a fresh check of any current installation.

### Still required before portable one-command reproduction

1. Split the dirty Wine checkout into clean production-only patches, excluding tests, mocks, harnesses, plans, debug tracing, and reverted variants.
2. Reconstruct the accepted D2D, DirectWrite, Shell32, win32u, winex11, and comdlg32 patch series from the exact upstream Wine 11.12 commit.
3. Recover the exact accepted DXVK source commit/diff and the nvcuda bridge source commit/diff. Current records identify binaries and provenance but do not yet form a clean build input.
4. Record the exact configure flags, compiler/toolchain image, and build commands for each accepted module.
5. Replace machine-local artifact paths with repository-relative build inputs or documented release assets, with redistribution rights and source provenance established.
6. Add a release manifest mapping every staged file to source commit, patch series, build command, and SHA-256.
7. Add a clean installer that creates a separate runner/prefix and refuses to overwrite the original Aegnux state.

Until these are complete, `scripts/verify-state.sh` checks file hashes in an existing installation; it cannot rebuild one from an empty machine or verify functional behavior. Artifact recovery requires matching runner, prefix, and module files not supplied by this repository.

## Why the prefix is excluded

The accepted prefix is approximately 103 GB and contains user-installed Adobe software, caches, user configuration, and proprietary components. Copying it is useful for forensic rollback but not a reproducible or portable build input.

## Why AE is represented as a patch, not a binary

The accepted AE change is a one-byte transformation of `libcef.dll`. The repository records original/accepted hashes and applies the byte only to a matching locally installed file. This preserves provenance without redistributing Adobe software.

## Release model

The canonical model should be:

- Git: source patches, scripts, manifests, docs.
- Any release assets: rebuilt Wine/DXVK/nvcuda modules only in compliance with their applicable licenses, including attribution/notices and corresponding source where required. Private visibility is not a redistribution permission.
- User machine: Aegnux Flatpak, legally installed AE, prefix, user extensions, media.
- Verification: hash-gated staging and rollback.
