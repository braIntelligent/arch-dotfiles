#!/usr/bin/env bash
# Muestra el nombre/hint del modo en el picker (y oculta los dots). $1 = texto.
SB="/Users/amnesia/.local/bin/sketchybar"
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${ACCENT:=0xff7aa2f7}"
"$SB" --set picker drawing=on label.color="$ACCENT" label="$1" \
      --set space.1 drawing=off --set space.2 drawing=off --set space.3 drawing=off \
      --set space.4 drawing=off --set space.5 drawing=off >/dev/null 2>&1
