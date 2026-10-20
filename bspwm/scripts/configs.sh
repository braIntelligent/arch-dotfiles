#!/bin/sh
# Abre un config en nvim sin tener que buscar el archivo.
choice=$(printf 'bspwm\nsxhkd\npolybar\npicom\nkitty\nrofi\nzshrc\np10k\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+e" -i -p "Editar config" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 8; } textbox-prompt-colon { str: ""; }')
case "$choice" in
    bspwm)   f="$HOME/.config/bspwm/bspwmrc" ;;
    sxhkd)   f="$HOME/.config/sxhkd/sxhkdrc" ;;
    polybar) f="$HOME/.config/polybar/config.ini" ;;
    picom)   f="$HOME/.config/picom/picom.conf" ;;
    kitty)   f="$HOME/.config/kitty/kitty.conf" ;;
    rofi)    f="$HOME/.config/rofi/config.rasi" ;;
    zshrc)   f="$HOME/.zshrc" ;;
    p10k)    f="$HOME/.p10k.zsh" ;;
    *) exit 0 ;;
esac
kitty -e nvim "$f"
