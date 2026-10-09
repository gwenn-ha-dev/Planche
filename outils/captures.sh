#!/bin/bash
# README captures — CHARTE.md §12. `make shots` delegates here.
#
# Each shot launches the built app on one view, in one language, and captures
# its window with the charter's capturer. The pictures are drawn by
# outils/echantillons.swift: a contact sheet of real photos would be personal
# data. They go inside the app's sandbox container, the one place the sandboxed
# app may read without an Open panel; the launch arguments that pick the view
# are documented in ContentView.swift.
set -euo pipefail
cd "$(dirname "$0")/.."
capturer=${CHARTE:-../../Charte}/outils/capturer.sh
app=build/Planche.app
[ -d "$app" ] || { echo "captures: build the app first (make package)" >&2; exit 1; }

folder=$HOME/Library/Containers/dev.gwennha.Planche/Data/tmp/captures/Horizons
swift outils/echantillons.swift "$folder"

shot() {  # shot <language> <out> <launch arguments…>
  local lang=$1 out=$2; shift 2
  pkill -x Planche 2>/dev/null || true
  sleep 1
  open -n "$app" --args -ApplePersistenceIgnoreState YES \
    -AppleLanguages "($lang)" -AppleLocale "${lang}_$( [ "$lang" = en ] && echo GB || echo FR )" \
    -folder "$folder" -thumbnailSize 160 "$@"
  sleep 5
  "$capturer" Planche "$out"
}

for lang in en fr; do
  suffix=$( [ "$lang" = en ] && echo "" || echo ".fr" )
  shot "$lang" "docs/img/gallery$suffix.png"
  shot "$lang" "docs/img/selection$suffix.png" -thumbnailSize 240 -select dune-2.jpg,dune-4.jpg,ridge-1.png
  shot "$lang" "docs/img/detail$suffix.png" -show shore-1.jpg
  shot "$lang" "docs/img/shortcuts$suffix.png" -shortcuts YES
done
pkill -x Planche 2>/dev/null || true
