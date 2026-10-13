#!/bin/sh
# Paquetes con actualizacion pendiente, para waybar. Sin pendientes no muestra nada.
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"
n=$(checkupdates 2>/dev/null | wc -l)
[ "${n:-0}" -gt 0 ] && echo "<span color='${cyan:-#7dcfff}'></span>  $n"
exit 0
