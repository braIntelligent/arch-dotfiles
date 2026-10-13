#!/bin/sh
# Abre una terminal con la actualizacion del sistema y, al terminar, refresca el
# contador de la barra.
[ -f "$HOME/.config/hypr/es-vm" ] && export LIBGL_ALWAYS_SOFTWARE=1
exec kitty --class actualizar -e sh -c 'sudo pacman -Syu; pkill -RTMIN+9 -x waybar; printf "\nEnter para cerrar "; read -r _'
