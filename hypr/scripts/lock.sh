#!/bin/sh
# Bloqueo de pantalla. En VMware hyprlock necesita dibujar por software.
[ -f "$HOME/.config/hypr/es-vm" ] && export LIBGL_ALWAYS_SOFTWARE=1
exec hyprlock
