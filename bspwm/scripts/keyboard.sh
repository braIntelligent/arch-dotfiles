#!/bin/sh
# Cambia la distribucion de teclado de X.
cur=$(setxkbmap -query | awk '/layout/ {print $2}')
i=$(printf 'latam\nus\nes\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+e,Super+I" -i -p "Teclado" -mesg "Actual: $cur" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 3; } window { width: 1240px; } textbox-prompt-colon { str: ""; }')
[ -n "$i" ] && setxkbmap "$i" && notify-send "Teclado: $i" 2>/dev/null
