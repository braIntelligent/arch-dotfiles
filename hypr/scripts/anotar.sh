#!/bin/sh
# Captura una zona y la abre en satty para anotarla: flechas, recuadros, texto y
# difuminado para tapar datos. Ahi mismo, Ctrl+C copia y Ctrl+S guarda.
command -v satty >/dev/null || { notify-send -u critical "Anotar" "Falta el paquete satty"; exit 1; }
dir="$HOME/Pictures/capturas"; mkdir -p "$dir"
area=$(slurp) || exit 0
grim -g "$area" - | satty --filename - --early-exit --copy-command wl-copy \
    --output-filename "$dir/captura-$(date +%Y%m%d-%H%M%S).png"
