#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${FG:=0xffc0caf5}" "${DIM:=0xff565f89}"
# volume_change trae el volumen en $INFO; osascript solo al arrancar o si falta
if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  VOL=$INFO; MUTED=false
else
  read -r VOL MUTED < <(osascript -e 'set v to get volume settings' -e '(output volume of v as text) & " " & (output muted of v as text)' 2>/dev/null)
fi
[ -z "$VOL" ] && { sketchybar --set "$NAME" icon="?" label=""; exit 0; }
if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ]; then
  ICON=$(printf '\xef\x80\xa6')   # nf  mute (U+F026)
  sketchybar --set "$NAME" icon="$ICON" icon.color=$DIM label="mute"
else
  ICON=$(printf '\xef\x80\xa8')   # nf  volumen (U+F028)
  sketchybar --set "$NAME" icon="$ICON" icon.color=$FG label="${VOL}%"
fi
