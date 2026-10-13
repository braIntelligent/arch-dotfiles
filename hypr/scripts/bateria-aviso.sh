#!/bin/sh
# Avisa cuando la bateria baja de 20 % y de 10 %. Lo lanza Hyprland al iniciar.
# Revisa una vez por minuto; cada aviso sale una sola vez hasta volver a enchufar.
B=""
for d in /sys/class/power_supply/*; do
    [ "$(cat "$d/type" 2>/dev/null)" = Battery ] || continue
    [ "$(cat "$d/scope" 2>/dev/null)" = Device ] && continue     # mouse o teclado inalambrico
    B=$d; break
done
[ -r "$B/capacity" ] || exit 0      # sin bateria: maquina virtual o equipo de escritorio

avisado=100
while :; do
    cap=$(cat "$B/capacity")
    # con limite de carga, el tope cuenta como 100 %, igual que en la barra
    tope=$(cat "$B/charge_control_end_threshold" 2>/dev/null)
    [ "${tope:-100}" -lt 100 ] 2>/dev/null && cap=$(( cap * 100 / tope ))
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
