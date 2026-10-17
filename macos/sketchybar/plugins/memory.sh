#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null
: "${GREEN:=0xff73daca}" "${YELLOW:=0xffe0af68}" "${RED:=0xfff7768e}"
ICON=$(printf '\xef\x87\x80')   # nf  database (U+F1C0) para RAM
FREE=$(memory_pressure 2>/dev/null | awk -F: '/free percentage/{gsub(/[ %]/,"",$2); print $2}')
[ -z "$FREE" ] && { sketchybar --set "$NAME" icon="$ICON" label="?"; exit 0; }
USED=$((100 - FREE))
if   [ "$USED" -ge 85 ]; then COLOR=$RED
elif [ "$USED" -ge 65 ]; then COLOR=$YELLOW
else                          COLOR=$GREEN
fi
sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${USED}%"
