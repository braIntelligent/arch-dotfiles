#!/bin/sh
# Capturas con grim. Uso: captura.sh zona | pantalla
# Guarda en ~/Pictures/capturas; "zona" ademas copia al portapapeles.
dir="$HOME/Pictures/capturas"; mkdir -p "$dir"
f="$dir/captura-$(date +%Y%m%d-%H%M%S).png"
case "$1" in
    zona)     area=$(slurp) || exit 0
              grim -g "$area" "$f" && wl-copy -t image/png < "$f" ;;
    pantalla) grim "$f" ;;
    *) echo "uso: captura.sh zona | pantalla"; exit 1 ;;
esac
