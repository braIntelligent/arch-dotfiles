#!/bin/sh
# Cambia la distribucion de teclado de la sesion.
cur=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .layout' | head -n1)
i=$(printf 'latam\nus\nes\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+e,Super+I" -i -p "Teclado" -mesg "Actual: $cur" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 3; } window { width: 620px; } textbox-prompt-colon { str: ""; }')
[ -n "$i" ] && hyprctl eval "hl.config({ input = { kb_layout = \"$i\" } })"
