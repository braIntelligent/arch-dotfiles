#!/bin/sh
# IP de la red local para waybar
lan=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p')
if [ -n "$lan" ]; then
    echo "<span color='#7aa2f7'></span>  $lan"
else
    echo "<span color='#f7768e'></span>  sin red"
fi
