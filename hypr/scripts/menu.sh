#!/bin/sh
# Menu central. Indices en el mismo orden que las opciones.
S="$HOME/.config/hypr/scripts"
i=$(printf '  Fondos\n  Temas\n  Atajos\n  Teclado\n  Configs\n  Captura\n  Energia\n' \
    | rofi -dmenu -format i -i -p "Menu" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 7; } textbox-prompt-colon { str: ""; }')
case "$i" in
    0) "$S/wallpaper.sh" ;;
    1) "$S/theme-selector.sh" ;;
    2) "$S/cheatsheet.sh" ;;
    3) "$S/keyboard.sh" ;;
    4) "$S/configs.sh" ;;
    5) "$S/screenshot.sh" ;;
    6) "$S/powermenu.sh" ;;
esac
