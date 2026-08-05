#!/bin/sh
set -eu

app=${APP_ID:-com.relative.Aegnux}
media=${1:-/mnt/Mandalore}
case "$media" in
    /*) ;;
    *) echo "media path must be absolute" >&2; exit 2 ;;
esac

# Keep the document portal's sibling-frame directory read-only.
flatpak override --user --nofilesystem=/mnt --filesystem="$media:ro" "$app"
printf 'Configured %s read-only for %s\n' "$app" "$media"
flatpak override --user --show "$app"
