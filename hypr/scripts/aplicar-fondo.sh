#!/bin/sh
# Aplica el ultimo fondo elegido (el mismo archivo que usa el escritorio bspwm).
w=$(cat "$HOME/.cache/wall" 2>/dev/null)
[ -f "$w" ] || w="$HOME/Pictures/fondo.jpg"
# el bloqueo de pantalla usa el mismo fondo, a traves de este enlace
[ -f "$w" ] && ln -sf "$w" "$HOME/.cache/fondo-bloqueo"
pkill -x swaybg 2>/dev/null
[ -f "$w" ] && setsid swaybg -m fill -i "$w" >/dev/null 2>&1 &
