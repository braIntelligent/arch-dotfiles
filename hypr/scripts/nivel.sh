#!/bin/sh
# Cambia el volumen, el brillo o la luz del teclado y muestra el nivel en pantalla.
# uso: nivel.sh vol +|-|mudo     nivel.sh mic mudo
#      nivel.sh brillo +|-       nivel.sh teclado +|-
# El aviso sale por mako (regla "osd" en su config). Se guarda su numero para que
# el siguiente lo reemplace en vez de apilarse.
id_f="${XDG_RUNTIME_DIR:-/tmp}/osd-id"
osd() {
    notify-send -a osd -p -r "$(cat "$id_f" 2>/dev/null || echo 0)" -h "int:value:$2" "$1  $3" > "$id_f"
}
pct() { brightnessctl -m "$@" | cut -d, -f4 | tr -d '%'; }

case "$1" in
    vol)
        # sube y baja de 5 en 5 sobre multiplos de 5, entre 0 y 100: asi "0 %" es
        # silencio de verdad (restando 5 % a secas podia quedar un resto audible)
        paso() {
            wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk -v d="$1" '{
                n = int(($2 * 100 + 2.5) / 5) * 5 + d
                if (n < 0) n = 0; if (n > 100) n = 100
                print n }'
        }
        case "$2" in
            +)    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$(paso 5)%" ;;
            -)    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$(paso -5)%" ;;
            mudo) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        esac
        v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        n=$(printf '%s\n' "$v" | awk '{ printf "%d", $2 * 100 + 0.5 }')
        case "$v" in
            *MUTED*) osd "" 0 "silencio" ;;
            *)       osd "" "$n" "$n%" ;;
        esac ;;
    mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        case "$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)" in
            *MUTED*) osd "" 0 "microfono apagado" ;;
            *)       osd "" 100 "microfono encendido" ;;
        esac ;;
    brillo)
        brightnessctl -q -e4 -n2 set "5%$2"
        n=$(pct); osd "" "$n" "$n%" ;;
    teclado)
        brightnessctl -q --device='*kbd_backlight' set "10%$2"
        n=$(pct --device='*kbd_backlight'); osd "" "$n" "$n%" ;;
    *) echo "uso: nivel.sh vol|mic|brillo|teclado +|-|mudo"; exit 1 ;;
esac
