#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${FG:=0xffc0caf5}"
ICON=$(printf '\xef\x80\x97')   # nf  reloj (U+F017)
sketchybar --set "$NAME" icon="$ICON" icon.color=$FG label="$(date '+%H:%M')"
