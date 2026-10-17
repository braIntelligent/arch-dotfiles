#!/usr/bin/env bash
# Alterna la barra entre modo "lab" (ip/vpn/target) y "sys" (wifi/volume/battery/cpu/memory).
SB="/Users/amnesia/.local/bin/sketchybar"
STATE="$HOME/.config/sketchybar/mode"
LAB="ip vpn target"
SYS="wifi volume battery cpu memory"
# frecuencia al estar visible; ocultos quedan en 0 (volume va por evento)
freq() { case "$1" in wifi) echo 15;; battery) echo 60;; cpu|memory) echo 3;; *) echo 0;; esac; }  # ip/vpn/target van por evento

cur=$(cat "$STATE" 2>/dev/null)
[ "$cur" = "sys" ] && new="lab" || new="sys"
echo "$new" > "$STATE"

if [ "$new" = "lab" ]; then
  for it in $LAB; do "$SB" --set "$it" drawing=on  update_freq=$(freq $it); done
  for it in $SYS; do "$SB" --set "$it" drawing=off update_freq=0; done
else
  for it in $LAB; do "$SB" --set "$it" drawing=off update_freq=0; done
  for it in $SYS; do "$SB" --set "$it" drawing=on  update_freq=$(freq $it); done
fi
"$SB" --update >/dev/null 2>&1
