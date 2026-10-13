#!/bin/sh
# Estado de la VPN (tun0) para waybar
# colores del tema activo
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"
vpn=$(ip -4 -o addr show tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
if [ -n "$vpn" ]; then
    echo "<span color='${green:-#9ece6a}'></span>  $vpn"
else
    echo "<span color='${dim:-#565f89}'>  disconnected</span>"
fi
