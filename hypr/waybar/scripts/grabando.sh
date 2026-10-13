#!/bin/sh
# Punto rojo en la barra mientras hay una grabacion de pantalla en curso.
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"
pgrep -x wf-recorder >/dev/null && echo "<span color='${red:-#f7768e}'>  REC</span>"
exit 0
