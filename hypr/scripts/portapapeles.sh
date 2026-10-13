#!/bin/sh
# Historial del portapapeles (cliphist): lo elegido vuelve a quedar copiado.
# Dentro del menu, Supr borra la entrada marcada del historial.
while :; do
    sel=$(cliphist list \
        | rofi -dmenu -kb-cancel "Escape,Super+space,Super+Shift+V" -i -p "Portapapeles" \
               -display-columns 2 -kb-remove-char-forward "Control+d" -kb-custom-1 "Delete" \
               -theme "$HOME/.config/rofi/list.rasi" \
               -theme-str 'window { width: 760px; } listview { lines: 12; }')
    case $? in
        0)  [ -n "$sel" ] && printf '%s\n' "$sel" | cliphist decode | wl-copy
            exit 0 ;;
        10) [ -n "$sel" ] && printf '%s\n' "$sel" | cliphist delete ;;
        *)  exit 0 ;;
    esac
done
