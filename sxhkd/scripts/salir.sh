#!/bin/sh
# Pide confirmacion con rofi antes de salir de bspwm. "No" va primero:
# un Enter por accidente no cierra nada.
r=$(printf 'No\nSi, salir\n' | rofi -dmenu -i -p 'Salir de bspwm' \
    -theme-str 'listview { lines: 2; } entry { placeholder: ""; }')
[ "$r" = "Si, salir" ] && bspc quit
