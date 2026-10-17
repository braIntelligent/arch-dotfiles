#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null
: "${GREEN:=0xff73daca}" "${FG:=0xffc0caf5}" "${YELLOW:=0xffe0af68}" "${RED:=0xfff7768e}"
INFO=$(pmset -g batt)
PERC=$(echo "$INFO" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
[ -z "$PERC" ] && { sketchybar --set "$NAME" icon="?" label=""; exit 0; }
CHARGING=$(echo "$INFO" | grep -c "AC Power")
if [ "$CHARGING" -eq 1 ]; then
  ICON=$(printf '\xef\x83\xa7'); COLOR=$GREEN          # rayo (U+F0E7)
else
  if   [ "$PERC" -ge 80 ]; then ICON=$(printf '\xef\x89\x80'); COLOR=$GREEN
  elif [ "$PERC" -ge 55 ]; then ICON=$(printf '\xef\x89\x81'); COLOR=$FG
  elif [ "$PERC" -ge 35 ]; then ICON=$(printf '\xef\x89\x82'); COLOR=$YELLOW
  elif [ "$PERC" -ge 15 ]; then ICON=$(printf '\xef\x89\x83'); COLOR=$YELLOW
  else                          ICON=$(printf '\xef\x89\x84'); COLOR=$RED
  fi
fi
sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${PERC}%"
