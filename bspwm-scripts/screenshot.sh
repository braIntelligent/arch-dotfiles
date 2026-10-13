#!/bin/sh
# Capturas (maim). Guarda en ~/Pictures/capturas y copia al portapapeles.
dir="$HOME/Pictures/capturas"; mkdir -p "$dir"
f="$dir/captura-$(date +%Y%m%d-%H%M%S).png"
i=$(printf '  Zona\n  Pantalla\n  Ventana\n  Zona 3s\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+S,Super+P" -format i -i -p "Captura" \
           -mesg "Carpeta: $dir" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 4; } window { width: 1640px; } textbox-prompt-colon { str: ""; }')
case "$i" in
    0) maim -s -u "$f" || exit 0 ;;
    1) maim -u "$f" ;;
    2) maim -u -i "$(xdotool getactivewindow)" "$f" ;;
    3) sleep 3; maim -s -u "$f" || exit 0 ;;
    *) exit 0 ;;
esac
[ -f "$f" ] && xclip -selection clipboard -t image/png < "$f" 2>/dev/null
notify-send "Captura guardada" "$f" 2>/dev/null
