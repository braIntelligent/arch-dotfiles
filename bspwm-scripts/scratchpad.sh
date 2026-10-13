#!/bin/sh
# Terminal desplegable (scratchpad) para bspwm: aparece/desaparece con el atajo.
CLASS=scratchpad
wid=$(xdotool search --class "^${CLASS}$" 2>/dev/null | head -1)
if [ -n "$wid" ]; then
    if bspc query -N -n "${wid}.hidden" >/dev/null 2>&1; then
        bspc node "$wid" --flag hidden=off --focus
    else
        bspc node "$wid" --flag hidden=on
    fi
else
    eval "$(xdotool getdisplaygeometry | awk '{print "W="$1";H="$2}')"
    w=$((W * 60 / 100)); h=$((H * 48 / 100)); x=$(((W - w) / 2)); y=0
    bspc rule -a "$CLASS" state=floating sticky=on rectangle="${w}x${h}+${x}+${y}"
    kitty --class "$CLASS" >/dev/null 2>&1 &
fi
