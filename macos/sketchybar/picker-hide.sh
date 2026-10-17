#!/usr/bin/env bash
# Oculta el selector y devuelve los dots de workspaces.
SB="/Users/amnesia/.local/bin/sketchybar"
"$SB" --set picker drawing=off \
      --set space.1 drawing=on --set space.2 drawing=on --set space.3 drawing=on \
      --set space.4 drawing=on --set space.5 drawing=on >/dev/null 2>&1
