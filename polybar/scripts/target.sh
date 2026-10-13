#!/bin/sh
# Maquina objetivo para polybar. Siempre visible.
# Se define con: settarget <ip> [nombre]   y se quita con: cleartarget
file="$HOME/.config/polybar/target"
if [ -s "$file" ] && [ -n "$(tr -d '[:space:]' < "$file")" ]; then
    echo "%{F#f7768e}%{F-}  $(cat "$file")"
else
    echo "%{F#565f89}  no target%{F-}"
fi
