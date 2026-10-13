#!/bin/sh
# IP de la red local para waybar
# colores del tema activo
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"
lan=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p')
if [ -n "$lan" ]; then
    echo "<span color='${blue:-#7aa2f7}'></span>  $lan"
else
    echo "<span color='${red:-#f7768e}'></span>  sin red"
fi
