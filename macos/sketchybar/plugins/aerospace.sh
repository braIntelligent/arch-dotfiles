#!/usr/bin/env bash
# Workspace como dot: focused=YELLOW lleno (resalta sobre el resto), ocupado=OCCUPIED lleno, vacio=DIM hueco.
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null
: "${YELLOW:=0xffe0af68}" "${OCCUPIED:=0xffbb9af7}" "${DIM:=0xff565f89}"

SID="$1"
AS="$HOME/.local/bin/aerospace"
FOCUSED="${FOCUSED_WORKSPACE:-$($AS list-workspaces --focused 2>/dev/null)}"
COUNT=$($AS list-windows --workspace "$SID" 2>/dev/null | grep -c .)

FILLED=$(printf '\xef\x84\x91')   # nf  circulo lleno (U+F111)
EMPTY=$(printf '\xef\x84\x8c')    # nf  circulo hueco (U+F10C)

if [ "$SID" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" label="$FILLED" label.color=$YELLOW
elif [ "${COUNT:-0}" -gt 0 ]; then
  sketchybar --set "$NAME" label="$FILLED" label.color=$OCCUPIED
else
  sketchybar --set "$NAME" label="$EMPTY" label.color=$DIM
fi
