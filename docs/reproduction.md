# Recover the recorded AE4Linux state

This is a historical setup/recovery procedure, not an installer or a complete public reproduction recipe. The author recorded a working runtime; that result has not been independently reproduced here.

**Artifact mode** assumes you already possess matching captured runner, prefix, and rebuilt module files, plus your legally obtained AE/Aegnux installation. Those artifacts are not supplied by this repository, and hashes cannot reconstruct them. **Source-build mode** remains an incomplete outline until the missing clean patch series and build inputs listed in `docs/reproducibility-status.md` are recovered.

## 0. Preconditions

- Linux host with Flatpak, Git, `sha256sum`, `python3`, and a working NVIDIA/DXVK stack.
- A legally obtained Aegnux Flatpak bundle or repository access.
- A legally installed compatible After Effects copy.
- A writable per-user Flatpak data directory.
- A media root containing image-sequence siblings.
- Do not run this procedure while After Effects is running.

All paths below are examples. `$HOME` means your own home directory; replace `/mnt/media` with your actual media mount and set the variables for your target machine.

```sh
export APP_ID=com.relative.Aegnux
export AE4_ROOT="$HOME/AE4Linux"
export AEGNUX_BASE="$HOME/.var/app/$APP_ID/data/aegnux"
export AEGNUX_CACHE="$HOME/.var/app/$APP_ID/cache/aegnux-debug"
export MEDIA_ROOT=/mnt/media
```

## 1. Install the unchanged Aegnux application

Install the original Aegnux Flatpak and start it once so its per-user directories exist. Record the installed commit:

```sh
flatpak info "$APP_ID"
```

The accepted record uses commit:

```text
1fe2615cf776c1dd621436f7a0355f606887bdd92de985008c5e07e1c4e77bce
```

Do not replace the original `runner` or `wineprefix`.

## 2. Create the isolated runtime locations

Use separate paths:

```text
$AEGNUX_BASE/runner-11.12-test
$AEGNUX_BASE/wineprefix-11.12-test
```

If you already have a captured runner/prefix in a user-owned backup, preserve its symlinks and metadata when restoring it. This alone does not resolve the recorded hash discrepancy or establish a portable reproduction:

```sh
rsync -aHAX --numeric-ids backup/runner-11.12-test/ "$AEGNUX_BASE/runner-11.12-test/"
rsync -aHAX --numeric-ids backup/wineprefix-11.12-test/ "$AEGNUX_BASE/wineprefix-11.12-test/"
```

The accepted runner reports:

```text
wine-11.12.r0.gbc50fb14 (TkG Staging NTsync)
```

## 3. Install accepted runtime modules

If you already have matching built artifacts, stage the modules identified in `manifests/accepted-binaries.sha256` only into the isolated runner/prefix. This repository supplies their hashes, not the artifacts or all source/build inputs:

```text
runner-11.12-test/lib/wine/x86_64-unix/win32u.so
runner-11.12-test/lib/wine/x86_64-unix/winex11.so
runner-11.12-test/lib/wine/x86_64-unix/comdlg32.so
runner-11.12-test/lib/wine/x86_64-windows/d2d1.dll
runner-11.12-test/lib/wine/x86_64-windows/dwrite.dll
runner-11.12-test/lib/wine/x86_64-windows/shell32.dll
runner-11.12-test/lib/wine/x86_64-windows/comdlg32.dll
wineprefix-11.12-test/drive_c/windows/system32/d3d11.dll
wineprefix-11.12-test/drive_c/windows/system32/dxgi.dll
wineprefix-11.12-test/drive_c/windows/system32/nvcuda.dll
```

Run:

```sh
"$AE4_ROOT/scripts/verify-state.sh"
```

The checker expects the final patched `libcef.dll` too, so an unpatched installation can fail this initial check. Re-run it after step 4. It must pass before treating the local files as matching the recorded hashes; passing is not a functional compatibility test. An earlier inventory reported a `shell32.dll` mismatch; see `manifests/state-discrepancies.tsv`. That discrepancy remains unresolved in the record and has not been rechecked on the reader's machine.

## 4. Apply the AE CEF change

The accepted state changes only `AE/CEPHtmlEngine/libcef.dll`. The hash-gated helper refuses to patch an unexpected AE installation:

```sh
"$AE4_ROOT/scripts/apply-ae-cef-patch.sh" \
  "$AEGNUX_BASE/AE/CEPHtmlEngine/libcef.dll"
```

The helper checks the original hash, saves a rollback copy, changes offset `0x6d56ebe` from `a5` to `1c`, and verifies the accepted hash.

## 5. Configure Flatpak filesystem access

For sequence import, grant only the media root read-only:

```sh
flatpak override --user --nofilesystem=/mnt \
  --filesystem="$MEDIA_ROOT":ro "$APP_ID"
```

The portal returns a document-portal URI for the selected file. The Wine portal fix resolves `user.document-portal.host-path`, then returns one host path. AE scans sibling frames itself. Do not expand the result into a manually constructed multi-file array.

For the later NAS profile, use explicit approved mounts and `C:\NAS` links as documented in `docs/fixes-by-layer.md`; avoid broad `/mnt` access and offline CIFS roots.

## 6. Install the launcher

Copy `packaging/aegnux-after-effects.in` to `~/.local/bin/aegnux-after-effects`, substitute the local base paths, and make it executable. Install `packaging/adobe-after-effects-aegnux.desktop` under `~/.local/share/applications/`, then run:

```sh
chmod 755 "$HOME/.local/bin/aegnux-after-effects"
desktop-file-validate "$HOME/.local/share/applications/adobe-after-effects-aegnux.desktop"
update-desktop-database "$HOME/.local/share/applications"
```

The launcher must use:

```text
WINEPREFIX=wineprefix-11.12-test
PATH=runner-11.12-test/bin:/app/bin:/usr/bin
WINE_FORCE_PORTAL=1
WINEDEBUG=-all
DXVK_CONFIG_FILE=.../dxvk-ae-sync.conf
WINEDLLOVERRIDES=AdobeGrowthSDK=
```

## 7. Configure DXVK and CUDA paths

Install `packaging/dxvk-ae-sync.conf` as:

```text
$AEGNUX_CACHE/dxvk-ae-sync.conf
```

with:

```ini
dxgi.syncInterval = 1
```

Ensure the prefix `nvcuda.dll` resolves to the accepted asynchronous bridge and that `WINEDLLPATH` includes its Unix directory.

## 8. Launch and verify manually

```sh
gtk-launch adobe-after-effects-aegnux
```

Acceptance checklist:

- Import Sequence imports all sibling frames.
- Portal failure never falls back to Wine native `itemdlg` under FORCE policy.
- Motion/CEP content is visible, aligned, clickable, and interactive.
- Timeline and non-CEP panels remain stable.
- Viewport repaints while scrubbing/changing a layer without requiring Play.
- AE can open approved media paths.

No test, harness, or additional automated repro run is part of this guide.

## 9. Rollback

The original Aegnux runner/prefix are untouched. Restore the isolated runner/prefix from backup, restore the saved original `libcef.dll`, and remove the user launcher/desktop entry if needed. Re-run `scripts/verify-state.sh` against the isolated state after rollback.

## 10. Source-build mode (currently incomplete)

The intended clean build order is:

1. checkout Wine commit `996020f410e7a1aa2dd6b44cf740854ea524d31a`;
2. apply the production-only Wine patch series under `patches/wine/`;
3. configure a separate x86_64 WoW64/Mingw build with `--enable-win64`;
4. build the selected Wine modules;
5. checkout the exact DXVK source commit and apply its production-only patches;
6. build DXVK and the asynchronous nvcuda bridge;
7. stage into a new runner/prefix;
8. apply the hash-gated AE CEF byte patch;
9. run `scripts/verify-state.sh`.

This sequence is recorded now, but cannot honestly be called complete until every accepted binary has a clean source patch and build manifest.
