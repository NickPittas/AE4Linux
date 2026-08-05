#!/bin/sh
set -eu

base=${AEGNUX_BASE:-"$HOME/.var/app/com.relative.Aegnux/data/aegnux"}
prefix="$base/wineprefix-11.12-test"
runner="$base/runner-11.12-test"
ae="$base/AE"

fail=0
check() {
    expected=$1
    path=$2
    if [ ! -e "$path" ]; then
        printf 'MISSING  %s\n' "$path" >&2
        fail=1
        return
    fi
    actual=$(sha256sum "$path" | awk '{print $1}')
    if [ "$actual" = "$expected" ]; then
        printf 'OK       %s\n' "$path"
    else
        printf 'MISMATCH %s\n  expected %s\n  actual   %s\n' "$path" "$expected" "$actual" >&2
        fail=1
    fi
}

check 2cc44807519826a97018d053c7617304dfd35277cd6888f0cae0ce5e51149702 "$runner/lib/wine/x86_64-unix/win32u.so"
check 461c1b039cf37b5f1e6326dc6689a063df330bd4471e5f497e18bc4acf2c0d9a "$runner/lib/wine/x86_64-unix/winex11.so"
check 19a31529409ec3221ae2564e7fa9d0e03fdd6020d411e66d1af86b5e23d99426 "$runner/lib/wine/x86_64-unix/comdlg32.so"
check 11548d4dd67b4a055b29d30352eed2aeee4c73a918333d24ae003cca604ca845 "$runner/lib/wine/x86_64-windows/d2d1.dll"
check 75997044be1853994c896fafc393896fec95642b6f148ce3b6af496debbb2c07 "$runner/lib/wine/x86_64-windows/dwrite.dll"
check 9ede77760b4e8979ca81a637b274851395a358c581ebc9c8db6d5574cc497f79 "$runner/lib/wine/x86_64-windows/shell32.dll"
check 47761e13750d88d87fc501ae1c099250a9eb231a22ac4777aee220acbf81499c "$runner/lib/wine/x86_64-windows/comdlg32.dll"
check b599a539b235a44c7844d583fb32acb14c43b819c869b32764c06be19e7b06df "$prefix/drive_c/windows/system32/d3d11.dll"
check 856e2e73922524703c738505dc97a47fdd761d80617616b1db36f0bec2adaf73 "$prefix/drive_c/windows/system32/dxgi.dll"
check 00a64eb017b2fe16604ca462e4295562094810b93eaea7d1f28ed71fa21465a6 "$prefix/drive_c/windows/system32/nvcuda.dll"
check a7ce53fa92016a3f6bcb12f4e8ce3b85222b58d7139a0063f9e5e9ad144b397f "$ae/CEPHtmlEngine/libcef.dll"

if command -v flatpak >/dev/null 2>&1; then
    flatpak override --user --show com.relative.Aegnux | sed -n '1,80p'
fi

[ "$fail" -eq 0 ] || exit 1
printf 'AE4Linux accepted-state hash check passed.\n'
