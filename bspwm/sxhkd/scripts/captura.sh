#!/bin/sh
# Capturas de pantalla con maim. Uso: captura.sh zona | pantalla
# Siempre guarda en ~/Pictures/capturas; "zona" ademas copia al portapapeles.
dir="$HOME/Pictures/capturas"
mkdir -p "$dir"
f="$dir/captura-$(date +%Y%m%d-%H%M%S).png"
case "$1" in
    zona)
        maim -s -u "$f" || exit 0
        xclip -selection clipboard -t image/png < "$f"
        ;;
    pantalla)
        maim -u "$f"
        ;;
    *)
        echo "uso: captura.sh zona | pantalla"
        exit 1
        ;;
esac
