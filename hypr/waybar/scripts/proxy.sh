#!/bin/sh
# Estado del proxy (Caido) para waybar
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"
if pgrep -x caido-cli >/dev/null; then
    echo "<span color='${yellow:-#e0af68}'></span>  proxy"
else
    echo "<span color='${dim:-#565f89}'>  proxy off</span>"
fi
