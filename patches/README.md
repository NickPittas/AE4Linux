# Patch inventory

Patch files are intentionally labelled by confidence.

- `accepted` — recovered from an accepted runtime or explicitly accepted source change.
- `provisional` — useful upstream/provenance input, but not yet proven byte-for-byte equivalent to the final deployed module.
- `rejected` — never place in an install/build order.

Current recovered patches:

| Path | Status | Scope |
|---|---|---|
| `wine/winex11/cep-v71-to-v87.patch` | accepted geometry result | Generic foreign CEP surface alignment |
| `wine/comdlg32/force-portal-no-native-fallback.patch` | accepted behavior | FORCE portal policy |
| `wine/comdlg32/xdg-portal-base.patch` | provisional base | Portal implementation backport; final local source still needs clean split |

The accepted D2D, DirectWrite, win32u, DXVK, and nvcuda source changes are currently represented by hashes and provenance notes only. They must be recovered into clean production-only patch files before the repository claims source-build reproducibility.
