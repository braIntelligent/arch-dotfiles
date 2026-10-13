#!/bin/sh
# Graba la pantalla con wf-recorder. La misma orden que inicia la grabacion la detiene.
# uso: grabar.sh [pantalla|zona] [audio]     "audio" agrega el sonido del sistema
# Guarda en ~/Videos/grabaciones. Mientras graba, la barra muestra un punto rojo
# (clic para detener).
dir="$HOME/Videos/grabaciones"; mkdir -p "$dir"

if pkill -INT -x wf-recorder; then
    pkill -RTMIN+8 -x waybar
    notify-send "  Grabacion guardada" "$dir"
    exit 0
fi

f="$dir/grabacion-$(date +%Y%m%d-%H%M%S).mp4"
zona=""
[ "$1" = zona ] && { zona=$(slurp) || exit 0; }
audio=""
case " $* " in *" audio "*) audio=$(pactl get-default-sink 2>/dev/null).monitor ;; esac

# yuv420p: el formato que abren todos los reproductores (QuickTime incluido)
setsid wf-recorder -x yuv420p ${zona:+-g "$zona"} ${audio:+--audio="$audio"} -f "$f" >/dev/null 2>&1 &
sleep 0.5
pkill -RTMIN+8 -x waybar
