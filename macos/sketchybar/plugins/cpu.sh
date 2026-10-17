#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null
: "${GREEN:=0xff73daca}" "${YELLOW:=0xffe0af68}" "${RED:=0xfff7768e}"
ICON=$(printf '\xef\x8b\x9b')   # nf  microchip (U+F2DB)
# rapido (instantaneo): suma %cpu de procesos / nucleos. Aproximado pero sirve.
NCPU=$(sysctl -n hw.ncpu 2>/dev/null); NCPU=${NCPU:-1}
CPU=$(ps -A -o %cpu= 2>/dev/null | awk -v n="$NCPU" '{s+=$1} END{v=s/n; if(v>100)v=100; printf "%d", v}')
[ -z "$CPU" ] && CPU=0
if   [ "$CPU" -ge 85 ]; then COLOR=$RED
elif [ "$CPU" -ge 50 ]; then COLOR=$YELLOW
else                         COLOR=$GREEN
fi
sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${CPU}%"
