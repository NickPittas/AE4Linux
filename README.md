# AE4Linux

**Research notes and recovered patches for Adobe After Effects on Linux—not an installer or a complete, reproducible build.** This repository records the author's experiments with Aegnux and a separately patched Wine 11.12 runtime. It does not provide an official or supported Linux version of After Effects.

## Status

The author recorded a working runtime on the original machine. That result has not been independently reproduced here, and the complete clean source patch series has not yet been recovered. The repository contains:

- recorded runtime hashes and source provenance;
- recovered patches, labelled accepted or provisional;
- verification/setup helpers and a technical fix ledger;
- missing source/build inputs and a recorded, unresolved `shell32.dll` hash discrepancy.

The discrepancy describes an earlier inventory, not a fresh check of a reader's installation. Neither the captured setup nor the current repository should be treated as a verified, portable release.

## Recorded runtime snapshot

These identify the captured setup, not compatibility guarantees or a claim that its artifacts are publicly available.

| Layer | Recorded artifact |
|---|---|
| Aegnux | `com.relative.Aegnux`, system Flatpak, commit `1fe2615cf776c1dd621436f7a0355f606887bdd92de985008c5e07e1c4e77bce` |
| Wine runner | Wine `11.12.r0.gbc50fb14`, separate `runner-11.12-test` |
| Wine prefix | separate `wineprefix-11.12-test` |
| Portal dialogs | patched `comdlg32.dll` + `comdlg32.so` |
| AE/CEF | one hash-gated byte patch to `AE/CEPHtmlEngine/libcef.dll` |
| DXVK/CUDA | recorded DXVK binaries and asynchronous nvcuda bridge; hashes in [`manifests/accepted-binaries.sha256`](manifests/accepted-binaries.sha256) |

## Start here

1. [Reproducibility status](docs/reproducibility-status.md) — missing inputs and the recorded hash discrepancy.
2. [Patch inventory](patches/README.md) — accepted/provisional source patches and remaining gaps.
3. [Fixes by layer](docs/fixes-by-layer.md) — the author's observations and accepted/rejected changes.
4. [Recovery procedure](docs/reproduction.md) — historical setup steps for someone who already has matching artifacts, plus an incomplete source-build outline.

`scripts/verify-state.sh` checks files in an **existing local installation** against recorded hashes. It cannot install After Effects, restore missing artifacts, rebuild the runtime, or demonstrate functional compatibility. A matching captured runner, prefix, rebuilt modules, and legally obtained AE/Aegnux installation are not supplied by this repository.

## Repository layout and privacy

- `docs/` — architecture, fix ledger, recovery procedure, and limitations.
- `patches/` — recovered source patches, labelled by confidence.
- `manifests/` — hashes, commits, paths, and captured environment details.
- `scripts/` and `packaging/` — verification/setup helpers and launcher templates.
- `provenance/` — source-tree notes, never runtime payloads.

Current personal path examples have been replaced with `$HOME` and `/mnt/media`; choose paths for your own machine. Old commits may still contain the original details. No history rewrite is part of this cleanup.

## License and third-party boundary

Copyright (C) 2026 NickPittas for original repository contributions.

Unless an existing file-specific notice states otherwise, this repository's original scripts, packaging files, documentation, and original patch contributions are licensed under the **GNU Lesser General Public License, version 2.1 or (at your option) any later version** (`LGPL-2.1-or-later`). See [LICENSE](LICENSE) for the full terms. This material is distributed **without any warranty**, including the implied warranties of merchantability or fitness for a particular purpose.

Existing upstream code and patch portions retain their copyright and license notices. This license does not relicense Adobe, Aegnux, or other separately obtained third-party software, and does not grant permission to redistribute their binaries or a user-installed Wine prefix. Any rebuilt Wine/DXVK/nvcuda release assets must comply with their own applicable licenses, including notices and corresponding-source obligations where required.
