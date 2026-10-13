#!/bin/sh
# Estado de la VPN (tun0) para waybar
vpn=$(ip -4 -o addr show tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
if [ -n "$vpn" ]; then
    echo "<span color='#9ece6a'></span>  $vpn"
else
    echo "<span color='#565f89'>  disconnected</span>"
fi
