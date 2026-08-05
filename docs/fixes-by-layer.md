# Fix ledger by layer

This is the consolidated map of changes that matter to the accepted After Effects/Aegnux runtime. A candidate is called **accepted** only when the later runtime record says it was deployed and the user/runtime evidence passed its stated gate. Diagnostic and rejected candidates are listed separately.

## 1. Aegnux and Flatpak layer

### Unchanged

- The installed Aegnux Flatpak was not rebuilt.
- Flatpak app ID: `com.relative.Aegnux`.
- Installed commit: `1fe2615cf776c1dd621436f7a0355f606887bdd92de985008c5e07e1c4e77bce`.
- The original Aegnux runner/prefix remain at `data/aegnux/runner` and `data/aegnux/wineprefix`.

### Added per-user runtime

- Separate Wine runner: `data/aegnux/runner-11.12-test`.
- Separate prefix: `data/aegnux/wineprefix-11.12-test`.
- Launcher: `~/.local/bin/aegnux-after-effects`.
- Desktop entry: `~/.local/share/applications/adobe-after-effects-aegnux.desktop`.
- Launcher forces the portal path with `WINE_FORCE_PORTAL=1` and uses `WINEDEBUG=-all` for normal operation.

### Filesystem policy

The sequence fix requires the host directory containing sibling frames to be visible inside the sandbox. The safe minimum is read-only access, for example:

```sh
flatpak override --user --nofilesystem=/mnt \
  --filesystem=/mnt/Mandalore:ro com.relative.Aegnux
```

The later accepted NAS profile uses explicit approved mounts and `C:\NAS` links. It is documented in `docs/reproduction.md`; do not broaden `/mnt` merely for convenience.

## 2. Wine `comdlg32`: XDG portal dialogs

Recovered production surface:

- `dlls/comdlg32/itemdlg.c`
- `dlls/comdlg32/filedlg.c`
- `dlls/comdlg32/portal_dbus.c`
- `dlls/comdlg32/unixlib.c`
- `dlls/comdlg32/unixlib.h`
- `dlls/comdlg32/cdlg32.c`
- `dlls/comdlg32/Makefile.in`

Behavior:

- XDG portal open/save dialogs for modern and legacy common-dialog callers.
- Custom checkbox and combo-box choices required by AE.
- Empty custom labels receive a valid fallback label.
- When the selected combo item would be lost by the portal option limit, the selected item is retained in the truncated payload.
- `PORTAL_POLICY_FORCE` refuses native Wine `itemdlg` fallback after a portal failure. This is required because FORCE must never silently change dialog implementations.
- Portal document URIs are resolved using `user.document-portal.host-path` so AE receives the host path when sibling files are needed.
- Import Sequence keeps one selected host path and lets AE scan neighbouring frames natively. An earlier multi-item expansion was removed because it crashed before AE callbacks.
- AE callback ordering reaches the expected `OnFileOk` path.

Final deployed pair:

```text
comdlg32.dll  47761e13750d88d87fc501ae1c099250a9eb231a22ac4777aee220acbf81499c
comdlg32.so   19a31529409ec3221ae2564e7fa9d0e03fdd6020d411e66d1af86b5e23d99426
```

Recovered portal patches are in `patches/wine/comdlg32/`. The large MR10060-derived patch is provenance input; the final local source must still be split and reviewed into a clean series.

## 3. Wine D2D and X11 presentation

Accepted runtime modules include:

- `d2d1.dll` — command-list playback, layer/mask state handling, unpremultiply behavior, and layer-aware Flush/EndDraw presentation.
- `winex11.so` — generic foreign CEP-surface client-origin alignment and per-surface transform caching.
- `win32u.so` — retained client-surface/native-owner behavior required by the accepted viewport path.

The CEP alignment patch is recovered at `patches/wine/winex11/cep-v71-to-v87.patch`. It is generic: it uses foreign HWND/toplevel geometry and runtime transforms, not Motion IDs, PIDs, XIDs, fixed offsets, or fixed DPI values.

Accepted hashes:

```text
win32u.so  2cc44807519826a97018d053c7617304dfd35277cd6888f0cae0ce5e51149702
winex11.so 461c1b039cf37b5f1e6326dc6689a063df330bd4471e5f497e18bc4acf2c0d9a
d2d1.dll   11548d4dd67b4a055b29d30352eed2aeee4c73a918333d24ae003cca604ca845
```

The accepted user result was: CEP placement and input alignment correct, timeline/UI stable, and viewport repaint retained. The remaining CEP renderer/driver boundary is documented as unresolved rather than hidden.

## 4. Wine DirectWrite and Shell32

### DirectWrite

Accepted `dwrite.dll` changes cover:

- lookup fallback for family names with ASCII spaces removed;
- typographic/Win32 informational family-name lookup without creating duplicate families;
- serialized glyph-analysis lazy state;
- checked glyph-origin/bounds handling to prevent invalid finite-range conversion and out-of-bounds writes;
- release cleanup serialized with the per-analysis lock.

Accepted hash:

```text
75997044be1853994c896fafc393896fec95642b6f148ce3b6af496debbb2c07
```

### Shell32

The accepted-state record says the original Wine 11.12 `shell32.dll` was restored after rejecting v94. Its recorded rollback hash is:

```text
9ede77760b4e8979ca81a637b274851395a358c581ebc9c8db6d5574cc497f79
```

However, the currently observed `runner-11.12-test` contains `12ad530bf3097d7bb6fbb46bb5f3278df7012bc154d3cf42673056d3700133f6`, matching the locally built modified shell32. This is a release blocker and is intentionally reported by `scripts/verify-state.sh`; no silent repair is performed. The v94 ShellView cache experiment passed focused tests but made AE folder enumeration/multi-select laggy and is rejected.

## 5. DXVK and CUDA bridge

The accepted prefix retains:

- asynchronous D3D11/Vulkan/CUDA external-memory interop;
- GPU timeline semaphore ordering rather than CPU waits or queue drains;
- shared-resource STORAGE usage from allocation time;
- process-lifetime dead tombstones for escaped CUDA graphics handles;
- no fake CUDA success, no CPU readback, and no XSync workaround.

Accepted prefix hashes:

```text
d3d11.dll   b599a539b235a44c7844d583fb32acb14c43b819c869b32764c06be19e7b06df
dxgi.dll    856e2e73922524703c738505dc97a47fdd761d80617616b1db36f0bec2adaf73
nvcuda.so   00a64eb017b2fe16604ca462e4295562094810b93eaea7d1f28ed71fa21465a6
```

The viewport fix was a combined DXVK/nvcuda/ownership result, not a standalone `nvcuda` fake-success patch.

## 6. Adobe/AE files

The accepted state changed one Adobe-owned file:

```text
AE/CEPHtmlEngine/libcef.dll
```

The transformation is one byte at offset `0x6d56ebe`:

```text
original  0xa5
accepted  0x1c
```

Original hash:

```text
4257c0e495aa2bb872a30c76787e7acbf02d42c338014072ff541ebd2d4c45e4
```

Accepted hash:

```text
a7ce53fa92016a3f6bcb12f4e8ce3b85222b58d7139a0063f9e5e9ad144b397f
```

The patch addresses the proven Blink placeholder-baseline DCHECK branch. It is applied only after the original hash is verified. No Motion files, licence data, AE project files, or extension payloads are committed.

## 7. Runtime configuration

- `dxgi.syncInterval = 1` in `dxvk-ae-sync.conf`.
- `WINEDLLOVERRIDES=AdobeGrowthSDK=`.
- `WINEPATH` points to the installed Mocha UI binaries.
- `WINEDLLPATH` includes the accepted nvcuda bridge.
- `WINE_FORCE_PORTAL=1`.
- Normal launcher uses `WINEDEBUG=-all`; tracing belongs only to diagnostic captures.
- Accepted NAS profile uses explicit Flatpak mount permissions and `C:\NAS` links to avoid probing offline CIFS mounts.

## Rejected or diagnostic-only work

Do not deploy these as fixes:

- synchronous Vulkan CPU readback, `vkQueueWaitIdle`, per-child fence waits;
- root/top-level HDC composition;
- XSync-as-fix;
- named-pixmap substitution;
- global Vulkan ownership priority that blacked the AE viewport;
- ShellView v94 cache;
- native-child candidates that produced transient or unstable panels;
- broad tracing during AE acceptance;
- failed multi-frame portal expansion;
- test, mock, harness, and probe artifacts.
