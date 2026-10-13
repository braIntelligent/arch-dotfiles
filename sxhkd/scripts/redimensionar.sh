#!/bin/sh
# Mueve el borde de la ventana enfocada en la direccion de la flecha.
# Funciona igual si la ventana esta a la izquierda o a la derecha (arriba o abajo).
# Uso: redimensionar.sh izquierda | derecha | arriba | abajo
paso=40
case "$1" in
    derecha)   bspc node -z right  "$paso" 0 || bspc node -z left   "$paso" 0 ;;
    izquierda) bspc node -z right "-$paso" 0 || bspc node -z left  "-$paso" 0 ;;
    abajo)     bspc node -z bottom 0  "$paso" || bspc node -z top 0  "$paso" ;;
    arriba)    bspc node -z bottom 0 "-$paso" || bspc node -z top 0 "-$paso" ;;
    *) echo "uso: redimensionar.sh izquierda|derecha|arriba|abajo"; exit 1 ;;
esac
