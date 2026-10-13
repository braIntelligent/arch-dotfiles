#!/bin/sh
# Abre un config en nvim sin tener que buscar el archivo.
choice=$(printf 'hyprland\nwaybar\nestilo\nkitty\nrofi\nzshrc\np10k\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+R" -i -p "Editar config" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 7; } textbox-prompt-colon { str: ""; }')
case "$choice" in
    hyprland) f="$HOME/.config/hypr/hyprland.lua" ;;
    waybar)   f="$HOME/.config/waybar/config.jsonc" ;;
    estilo)   f="$HOME/.config/waybar/style.css" ;;
    kitty)    f="$HOME/.config/kitty/kitty.conf" ;;
    rofi)     f="$HOME/.config/rofi/config.rasi" ;;
    zshrc)    f="$HOME/.zshrc" ;;
    p10k)     f="$HOME/.p10k.zsh" ;;
    *) exit 0 ;;
esac
[ -f "$HOME/.config/hypr/es-vm" ] && export LIBGL_ALWAYS_SOFTWARE=1
kitty -e nvim "$f"
