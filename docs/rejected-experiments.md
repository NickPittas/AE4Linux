# Rejected and diagnostic work

These experiments explain why the accepted package must not be rebuilt by copying every file in the cache.

- Vulkan CPU readback and per-child fence waits: nonzero source pixels were observed, but synchronous waits froze AE and GDI copies did not produce visible output.
- `vkQueueWaitIdle`: did not make the workspace usable.
- XSync before copies: AE became black except for the menu.
- Root/top-level HDC composition: detached and overlapping fragments.
- Named-pixmap substitution: about 79.7% black and pixel-identical frames.
- Native-child candidates: transient visibility but unstable final layout; not accepted.
- Global Vulkan ownership priority: blackened the accepted AE viewport; rolled back.
- ShellView v94 cache: focused tests passed, but AE enumeration and multi-select became laggy; original shell32 restored.
- Portal multi-frame expansion: discovered frames but passed a malformed/non-terminated result and crashed before AE callbacks; removed. Final fix returns one resolved host path and lets AE scan siblings.
- Broad SEH/debug traces: perturbed CEP startup and heartbeat; diagnostic-only.

No item in this ledger should be deployed by the setup scripts.
