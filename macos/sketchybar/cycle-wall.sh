#!/usr/bin/env bash
# Cicla wallpapers con preview en vivo. uso: cycle-wall.sh <next|prev|cur>
dir="$1"
SB="/Users/amnesia/.local/bin/sketchybar"
wdir="$HOME/Pictures/wallpapers"
files=(); for f in "$wdir"/*; do [ -f "$f" ] && files+=("$f"); done
n=${#files[@]}
[ "$n" -eq 0 ] && { osascript -e 'display notification "No hay fondos en ~/Pictures/wallpapers" with title "Wallpaper"'; exit 0; }

cur=$(cat "$HOME/.cache/wall" 2>/dev/null)
idx=0; for i in "${!files[@]}"; do [ "${files[$i]}" = "$cur" ] && idx=$i; done
case "$dir" in
  next) idx=$(( (idx + 1) % n ));;
  prev) idx=$(( (idx - 1 + n) % n ));;
esac
w="${files[$idx]}"
echo "$w" > "$HOME/.cache/wall"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$w\"" 2>/dev/null

nombre=$(basename "$w"); nombre="${nombre%.*}"   # sin extension
"$SB" --set picker drawing=on label="◀ $nombre ▶" \
      --set space.1 drawing=off --set space.2 drawing=off --set space.3 drawing=off \
      --set space.4 drawing=off --set space.5 drawing=off >/dev/null 2>&1
