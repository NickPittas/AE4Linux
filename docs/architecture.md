# Runtime architecture

```text
AE.exe / CEPHtmlEngine.exe
        │ Win32 APIs, D2D, DWrite, common dialogs
        ▼
Wine 11.12 runner
  ├─ PE DLLs: comdlg32, d2d1, dwrite, shell32
  └─ Unix DLLs: win32u, winex11, comdlg32
        │ Vulkan / DXVK / external-memory interop
        ▼
Wine prefix modules
  ├─ d3d11.dll
  ├─ dxgi.dll
  └─ nvcuda.dll → asynchronous bridge
        │
        ▼
Aegnux Flatpak + XDG desktop portal + host media mounts
```

## Ownership boundaries

- **Aegnux/Flatpak** supplies the unchanged app sandbox and portal runtime.
- **Wine PE DLLs** implement the Windows-facing contracts AE calls.
- **Wine Unix DLLs** connect client surfaces, X11, Vulkan, and host windows.
- **DXVK/nvcuda** preserve GPU-only synchronization between D3D11, Vulkan, and CUDA.
- **AE/CEF** contains the one documented Adobe binary transformation.
- **Launcher/config** selects the isolated runner/prefix and prevents accidental use of the original Aegnux state.

A fix belongs in the lowest layer that owns the broken contract. The repository keeps those layers separate so a future rebuild cannot accidentally combine a rejected experiment with an accepted module.
