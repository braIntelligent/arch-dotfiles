#!/bin/sh
# Pide confirmacion antes de salir de Hyprland. "No" va primero.
r=$(printf 'No\nSi\n' | rofi -dmenu -no-click-to-exit -i -p "Salir de Hyprland?" -theme "$HOME/.config/rofi/confirm.rasi")
[ "$r" = Si ] && hyprctl dispatch 'hl.dsp.exit()'
