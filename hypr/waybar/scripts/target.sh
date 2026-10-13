#!/bin/sh
# Maquina objetivo para waybar. Se define con: settarget <ip> [nombre]
# colores del tema activo
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"
file="$HOME/.config/hypr/target"
if [ -s "$file" ] && [ -n "$(tr -d '[:space:]' < "$file")" ]; then
    echo "<span color='${red:-#f7768e}'></span>  $(cat "$file")"
else
    echo "<span color='${dim:-#565f89}'>  no target</span>"
fi
