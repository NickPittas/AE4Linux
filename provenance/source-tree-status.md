# Source-tree status at repository creation

Source checkout:

```text
/home/npittas/.var/app/com.relative.Aegnux/cache/aegnux-debug/wine-src-11.12-ae-combined-fix
```

Base commit:

```text
996020f410e7a1aa2dd6b44cf740854ea524d31a
```

The checkout is dirty and contains both production changes and forbidden/unrelated material. It must not be copied wholesale into this repository. Known production areas in the dirty tree are:

```text
dlls/comdlg32/
dlls/d2d1/
dlls/dwrite/font.c
dlls/shell32/
dlls/win32u/
dlls/winex11.drv/
include/wine/gdi_driver.h
```

The dirty tree also contains test edits, test helpers, mock/harness files, `.pi` artifacts, plans, captures, and reverted experiments. Those are intentionally excluded from AE4Linux. The next source-recovery task is to derive production-only patches from the accepted binary provenance and review each patch against the accepted hashes.

This file is a warning against the most tempting but incorrect reproduction method: committing the entire dirty checkout.
