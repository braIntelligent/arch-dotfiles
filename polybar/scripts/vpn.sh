#!/bin/sh
# Estado de la VPN (tun0) para polybar: IP si esta conectada, "disconnected" si no
vpn=$(ip -4 -o addr show tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
if [ -n "$vpn" ]; then
    echo "%{F#9ece6a}%{F-}  $vpn"
else
    echo "%{F#565f89}  disconnected%{F-}"
fi
