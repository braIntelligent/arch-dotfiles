#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${BLUE:=0xff7aa2f7}" "${RED:=0xfff7768e}"
ICON=$(printf '\xef\x82\xac')   # nf  globo/red (U+F0AC)
IFACE=$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')
LAN=""
[ -n "$IFACE" ] && LAN=$(ipconfig getifaddr "$IFACE" 2>/dev/null)
[ -z "$LAN" ] && LAN=$(ipconfig getifaddr en0 2>/dev/null)
if [ -n "$LAN" ]; then
  sketchybar --set "$NAME" icon="$ICON" icon.color=$BLUE label="$LAN"
else
  sketchybar --set "$NAME" icon="$ICON" icon.color=$RED label="sin red"
fi
