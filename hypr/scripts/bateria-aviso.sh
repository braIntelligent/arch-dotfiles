#!/bin/sh
# Avisa cuando la bateria baja de 20 % y de 10 %. Lo lanza Hyprland al iniciar.
# Revisa una vez por minuto; cada aviso sale una sola vez hasta volver a enchufar.
B=/sys/class/power_supply/macsmc-battery
[ -r "$B/capacity" ] || B=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -r "$B/capacity" ] || exit 0      # sin bateria: maquina virtual o equipo de escritorio

avisado=100
while :; do
    cap=$(cat "$B/capacity")
    if [ "$(cat "$B/status")" != Discharging ]; then
        avisado=100
    elif [ "$cap" -le 10 ] && [ "$avisado" -gt 10 ]; then
        notify-send -u critical "  Bateria al $cap %" "Enchufa el cargador"
        avisado=10
    elif [ "$cap" -le 20 ] && [ "$avisado" -gt 20 ]; then
        notify-send "  Bateria al $cap %" "Queda poca carga"
        avisado=20
    fi
    sleep 60
done
