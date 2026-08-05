#!/bin/sh
set -eu

file=${1:-"$HOME/.var/app/com.relative.Aegnux/data/aegnux/AE/CEPHtmlEngine/libcef.dll"}
original=4257c0e495aa2bb872a30c76787e7acbf02d42c338014072ff541ebd2d4c45e4
accepted=a7ce53fa92016a3f6bcb12f4e8ce3b85222b58d7139a0063f9e5e9ad144b397f
offset=$((0x6d56ebe))

[ -f "$file" ] || { echo "missing: $file" >&2; exit 1; }
actual=$(sha256sum "$file" | awk '{print $1}')
if [ "$actual" = "$accepted" ]; then
    echo "already accepted: $file"
    exit 0
fi
[ "$actual" = "$original" ] || {
    echo "refusing unexpected libcef.dll hash: $actual" >&2
    exit 1
}

backup="$file.original.$(date -u +%Y%m%dT%H%M%SZ)"
cp -a "$file" "$backup"
python3 - "$file" "$offset" <<'PY'
import mmap
import sys

path, offset = sys.argv[1], int(sys.argv[2])
with open(path, "r+b") as stream:
    with mmap.mmap(stream.fileno(), 0) as data:
        if data[offset] != 0xA5:
            raise SystemExit("unexpected byte at libcef patch offset")
        data[offset] = 0x1C
        data.flush()
PY

actual=$(sha256sum "$file" | awk '{print $1}')
[ "$actual" = "$accepted" ] || { echo "post-patch hash mismatch: $actual" >&2; exit 1; }
printf 'patched %s\nbackup %s\n' "$file" "$backup"
