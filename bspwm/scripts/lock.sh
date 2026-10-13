#!/bin/sh
# Bloqueo de pantalla. Si esta i3lock-color, muestra reloj y fondo difuminado.
if command -v i3lock-color >/dev/null 2>&1; then
    tmp=/tmp/lock.png
    maim -u "$tmp" 2>/dev/null && convert "$tmp" -scale 10% -scale 1000% "$tmp" 2>/dev/null
    i3lock-color \
        ${tmp:+-i "$tmp"} \
        --clock --time-str="%H:%M" --date-str="%A %d %B" \
        --time-size=64 --date-size=20 \
        --time-pos="x+w/2:y+h/2-40" --date-pos="x+w/2:y+h/2+20" \
        --time-color=c0caf5ff --date-color=7aa2f7ff \
        --inside-color=1a1b2688 --ring-color=7aa2f7ff \
        --line-uses-inside --keyhl-color=bb9af7ff --ringver-color=73dacaff \
        --ringwrong-color=f7768eff --verif-text="" --wrong-text="" \
        --radius=110 --ring-width=8
elif command -v i3lock-fancy >/dev/null 2>&1; then
    i3lock-fancy
else
    i3lock -c 1a1b26
fi
