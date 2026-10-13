#!/bin/sh
# Aplica el ultimo fondo elegido; si no hay, usa el que exista en ~/Pictures.
w=$(cat "$HOME/.cache/wall" 2>/dev/null)
[ -f "$w" ] || w="$HOME/Pictures/fondo.jpg"
[ -f "$w" ] && feh --bg-fill "$w"
