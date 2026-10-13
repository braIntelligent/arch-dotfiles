#!/bin/sh
# Menu de capturas (grim + slurp). Guarda en ~/Pictures/capturas y copia al portapapeles.
dir="$HOME/Pictures/capturas"; mkdir -p "$dir"
f="$dir/captura-$(date +%Y%m%d-%H%M%S).png"
i=$(printf '  Zona\n  Pantalla\n  Ventana\n  Zona 3s\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+p,Super+P" -format i -i -p "Captura" \
           -mesg "Carpeta: $dir" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 4; } window { width: 820px; } textbox-prompt-colon { str: ""; }')
sleep 0.3   # que el menu alcance a desaparecer de la imagen
case "$i" in
    0) area=$(slurp) || exit 0; grim -g "$area" "$f" ;;
    1) grim "$f" ;;
    2) area=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
       grim -g "$area" "$f" ;;
    3) sleep 3; area=$(slurp) || exit 0; grim -g "$area" "$f" ;;
    *) exit 0 ;;
esac
[ -f "$f" ] && wl-copy -t image/png < "$f"
