# AE4Linux

Reproducibility record for running Adobe After Effects on Linux through Aegnux and a separately patched Wine 11.12 runtime.

## Status

This repository is **private** and currently contains the first provenance package. The working machine has a validated accepted runtime, but the complete clean source patch series is not yet reconstructed. The repository therefore records both (including a currently unresolved shell32 hash discrepancy):

- exact accepted runtime hashes and machine-local source locations;
- the patches and scripts already recovered;
- the remaining gaps that must be closed before claiming portable one-command reproduction.

It intentionally does not contain Adobe binaries, an After Effects installation, user extensions, a Wine prefix, a Flatpak bundle, or a 100+ GB cache.

## Accepted runtime at capture time

| Layer | Accepted artifact |
|---|---|
| Aegnux | `com.relative.Aegnux`, system Flatpak, commit `1fe2615cf776c1dd621436f7a0355f606887bdd92de985008c5e07e1c4e77bce` |
| Wine runner | Wine `11.12.r0.gbc50fb14`, separate `runner-11.12-test` |
| Wine prefix | separate `wineprefix-11.12-test` |
| Portal dialogs | patched `comdlg32.dll` + `comdlg32.so` |
| AE/CEF | one hash-gated byte patch to `AE/CEPHtmlEngine/libcef.dll` |
| DXVK/CUDA | accepted DXVK binaries and asynchronous nvcuda bridge, hash recorded in `manifests/accepted-binaries.sha256` |

## Start here

1. Read `docs/fixes-by-layer.md`.
2. Read `docs/reproduction.md`.
3. Run `scripts/verify-state.sh` against the existing machine-local installation.
4. Do not copy the Wine prefix or AE directory into Git.
5. Before using a different machine, resolve the open gaps in `docs/reproducibility-status.md`.

## Repository layout

- `docs/` — architecture, fix ledger, reproduction procedure, accepted/rejected state.
- `patches/` — recovered source patches, labelled accepted or provisional.
- `manifests/` — hashes, commits, paths, and environment assumptions.
- `scripts/` — hash-gated verification and setup helpers.
- `packaging/` — launcher and desktop-entry templates with machine-local paths parameterized.
- `provenance/` — source-tree provenance notes, never runtime payloads.

## Important boundary

A private GitHub repository is not a licence to redistribute Adobe or third-party binaries. Reproduction uses the user's legally installed AE/Aegnux files, verifies their original hashes, and applies only the documented local transformation. Rebuilt Wine/DXVK artifacts may be stored separately as private release assets if their licences permit it; source patches remain the canonical record.
