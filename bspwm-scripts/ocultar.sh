#!/bin/sh
# Alterna el escritorio actual: oculta todas las ventanas visibles, o las trae
# de vuelta si ya estaban ocultas.
# Excluye las "sticky" para no tocar la terminal desplegable (scratchpad).
ocultas=$(bspc query -N -n '.hidden.local.window.!sticky')
if [ -n "$ocultas" ]; then
    for w in $ocultas; do
        bspc node "$w" -g hidden=off
    done
    bspc node "$w" -f
else
    for w in $(bspc query -N -n '.local.window.!hidden.!sticky'); do
        bspc node "$w" -g hidden=on
    done
fi
