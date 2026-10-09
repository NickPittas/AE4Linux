#!/bin/sh
set -eu

app=${APP_ID:-com.relative.Aegnux}
# Example only: pass your actual absolute media path as the first argument.
media=${1:-/mnt/media}
case "$media" in
    /*) ;;
    *) echo "media path must be absolute" >&2; exit 2 ;;
esac

# Keep the document portal's sibling-frame directory read-only.
flatpak override --user --nofilesystem=/mnt --filesystem="$media:ro" "$app"
printf 'Configured %s read-only for %s\n' "$app" "$media"
flatpak override --user --show "$app"
