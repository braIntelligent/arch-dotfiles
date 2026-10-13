#!/bin/sh
# IP de la red local para polybar
lan=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p')
if [ -n "$lan" ]; then
    echo "%{F#7aa2f7}%{F-}  $lan"
else
    echo "%{F#f7768e}%{F-}  sin red"
fi
