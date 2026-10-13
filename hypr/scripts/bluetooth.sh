#!/bin/sh
# Abre bluetui (emparejar y conectar dispositivos Bluetooth) en una ventana flotante.
# Si ya esta abierto, lo cierra: la misma tecla abre y cierra, y no se apilan ventanas.
pkill -x bluetui && exit 0
# bluetui se cierra al instante si el servicio no esta andando: mejor avisar.
if ! systemctl is-active --quiet bluetooth; then
    notify-send -u critical "Bluetooth apagado" "Falta encender el servicio: sudo systemctl enable --now bluetooth"
    exit 1
fi
[ -f "$HOME/.config/hypr/es-vm" ] && export LIBGL_ALWAYS_SOFTWARE=1
exec kitty --class bluetooth -e bluetui
