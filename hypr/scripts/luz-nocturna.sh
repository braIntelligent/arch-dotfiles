#!/bin/sh
# Enciende o apaga la luz nocturna (tono calido) a mano, con la misma tecla.
# Es un interruptor manual, independiente del horario de hyprsunset.conf: vale
# hasta la proxima transicion por horario o hasta que lo vuelvas a pulsar.
estado="${XDG_RUNTIME_DIR:-/tmp}/luz-nocturna"
temp=3500

if [ -f "$estado" ]; then
    hyprctl hyprsunset identity >/dev/null
    rm -f "$estado"
    notify-send -a luz "Luz nocturna apagada" "Pantalla en color normal"
else
    hyprctl hyprsunset temperature "$temp" >/dev/null
    : > "$estado"
    notify-send -a luz "Luz nocturna encendida" "${temp}K, tono calido"
fi
