#!/bin/sh
# Menu de capturas (grim + slurp). Guarda en ~/Pictures/capturas y copia al portapapeles.
# Tambien graba video (grabar.sh). Con una grabacion en curso, el menu lo avisa, dice
# cuanto lleva y cambia las opciones de grabar por una sola: "Detener".
dir="$HOME/Pictures/capturas"; mkdir -p "$dir"
f="$dir/captura-$(date +%Y%m%d-%H%M%S).png"
G="$HOME/.config/hypr/scripts/grabar.sh"

capturas='  Zona\n  Pantalla\n  Ventana\n  Zona 3s\n'
pid=$(pgrep -x wf-recorder | head -n1)
fila=0      # opcion que parte marcada
if [ -n "$pid" ]; then
    s=$(ps -o etimes= -p "$pid" | tr -d ' ')
    t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
    [ -f "$t" ] && . "$t"
    mesg=$(printf '<span foreground="'"${red:-#f7768e}"'">  Grabando</span>   lleva %d:%02d' $(( s / 60 )) $(( s % 60 )))
    opciones="${capturas}  Detener\n"
    cols=5; ancho=980; fila=4       # parte marcada "Detener": basta Enter
else
    mesg="Carpeta: $dir"
    opciones="${capturas}  Grabar\n  Con audio\n  Grabar zona\n"
    cols=7; ancho=1240
fi

o=$(printf "$opciones" \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+Shift+S" -i -p "Captura" -selected-row "$fila" \
           -mesg "$mesg" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str "listview { columns: $cols; } window { width: ${ancho}px; } textbox-prompt-colon { str: \"\"; }")
sleep 0.3   # que el menu alcance a desaparecer de la imagen
case "$o" in
    *"Zona 3s")     sleep 3; area=$(slurp) || exit 0; grim -g "$area" "$f" ;;
    *"Zona")        area=$(slurp) || exit 0; grim -g "$area" "$f" ;;
    *"Pantalla")    grim "$f" ;;
    *"Ventana")     area=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
                    grim -g "$area" "$f" ;;
    *"Detener")     exec "$G" ;;
    *"Grabar zona") exec "$G" zona ;;
    *"Con audio")   exec "$G" pantalla audio ;;
    *"Grabar")      exec "$G" pantalla ;;
    *) exit 0 ;;
esac
[ -f "$f" ] && wl-copy -t image/png < "$f"
