#!/bin/sh
# Barra en dos modos: "normal" (metricas del equipo) y "htb" (IP, VPN y target).
# uso: barra.sh            lanza la barra en el modo guardado
#      barra.sh cambiar    pasa al otro modo (queda guardado para la proxima sesion)
estado="$HOME/.cache/barra"
modo=$(cat "$estado" 2>/dev/null)
[ "$modo" = htb ] || modo=normal

if [ "$1" = cambiar ]; then
    [ "$modo" = htb ] && modo=normal || modo=htb
    printf '%s\n' "$modo" > "$estado"
    # se relanza suelto: si lo llamo la propia barra (clic en el logo), al
    # cerrarla no se lleva consigo a este script
    exec setsid -f "$0"
fi

case "$modo" in
    htb) cfg=htb.jsonc ;;
    *)   cfg=config.jsonc ;;
esac
pkill -x waybar 2>/dev/null
setsid waybar -c "$HOME/.config/waybar/$cfg" >/dev/null 2>&1 &
