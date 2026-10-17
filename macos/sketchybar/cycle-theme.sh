#!/usr/bin/env bash
# Cicla temas con preview en vivo. uso: cycle-theme.sh <next|prev|cur>
dir="$1"
SB="/Users/amnesia/.local/bin/sketchybar"
tdir="$HOME/.config/sketchybar/themes"
ids=(); for f in "$tdir"/*.sh; do [ -f "$f" ] && ids+=("$(basename "$f" .sh)"); done
n=${#ids[@]}; [ "$n" -eq 0 ] && exit 0

cur=$(cat "$HOME/.cache/theme" 2>/dev/null)
idx=0; for i in "${!ids[@]}"; do [ "${ids[$i]}" = "$cur" ] && idx=$i; done
case "$dir" in
  next) idx=$(( (idx + 1) % n ));;
  prev) idx=$(( (idx - 1 + n) % n ));;
esac
id="${ids[$idx]}"
[ "$dir" != cur ] && "$HOME/.config/sketchybar/set-theme.sh" "$id" >/dev/null 2>&1

name=$(. "$tdir/$id.sh"; echo "$name")
# muestra el selector y oculta los dots (solo queda el selector al centro)
"$SB" --set picker drawing=on label="◀ $name ▶" \
      --set space.1 drawing=off --set space.2 drawing=off --set space.3 drawing=off \
      --set space.4 drawing=off --set space.5 drawing=off >/dev/null 2>&1
