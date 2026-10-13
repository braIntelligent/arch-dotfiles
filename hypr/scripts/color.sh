#!/bin/sh
# Selector de color: se apunta a un punto de la pantalla y su codigo queda copiado.
command -v hyprpicker >/dev/null || { notify-send -u critical "Color" "Falta el paquete hyprpicker"; exit 1; }
c=$(hyprpicker -a -f hex) || exit 0
[ -n "$c" ] && notify-send -a color "  $c" "copiado"
