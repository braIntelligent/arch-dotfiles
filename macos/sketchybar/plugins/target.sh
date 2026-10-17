#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${RED:=0xfff7768e}" "${DIM:=0xff565f89}"
ICON=$(printf '\xef\x81\x9b')   # nf  crosshair (U+F05B)
FILE="$HOME/.config/sketchybar/target"
if [ -s "$FILE" ] && [ -n "$(tr -d '[:space:]' < "$FILE")" ]; then
  sketchybar --set "$NAME" icon="$ICON" icon.color=$RED label="$(cat "$FILE")"
else
  sketchybar --set "$NAME" icon="$ICON" icon.color=$DIM label="no target"
fi
