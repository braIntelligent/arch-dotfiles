#!/bin/sh
# Menu de temas con vista previa: izquierda/derecha (o h/l) aplican el tema vecino
# al instante, Enter lo deja y Escape vuelve al que estaba.
# rofi 1.7.5 no avisa cuando cambia la seleccion, asi que esas teclas cierran el
# menu con un codigo de salida (kb-custom en temas.rasi) y aqui se reabre.
S="$HOME/.config/bspwm/scripts"
tdir="$HOME/.config/bspwm/themes"
map=$(for f in "$tdir"/*.sh; do ( . "$f"; printf '%s\t%s\n' "$name" "$(basename "$f" .sh)" ); done)
total=$(printf '%s\n' "$map" | wc -l)
cols=$total; [ "$cols" -gt 6 ] && cols=6
id_de() { printf '%s\n' "$map" | sed -n "$(( $1 + 1 ))p" | cut -f2; }
aplicar() { [ "$(cat "$HOME/.cache/theme" 2>/dev/null)" = "$1" ] || "$S/set-theme.sh" "$1"; }

orig=$(cat "$HOME/.cache/theme" 2>/dev/null)
i=$(printf '%s\n' "$map" | awk -F'\t' -v t="$orig" '$2==t {print NR-1; exit}')
i=${i:-0}

while :; do
    sel=$(printf '%s\n' "$map" | cut -f1 \
        | rofi -dmenu -format i -selected-row "$i" -kb-cancel "Escape,Super+space,Super+T" -i -p "Tema" \
               -mesg "h / l: probar    Enter: dejar    Esc: volver a $orig" \
               -theme "$HOME/.config/rofi/temas.rasi" \
               -theme-str "listview { columns: $cols; } textbox-prompt-colon { str: \"\"; }")
    case $? in
        10) i=$(( (i + 1) % total )) ;;
        11) i=$(( (i - 1 + total) % total )) ;;
        0)  [ -n "$sel" ] && i=$sel
            aplicar "$(id_de "$i")"; exit 0 ;;
        *)  [ -n "$orig" ] && aplicar "$orig"; exit 0 ;;
    esac
    aplicar "$(id_de "$i")"
done
