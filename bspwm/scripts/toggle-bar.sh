#!/bin/sh
# Oculta/muestra la polybar y ajusta el padding para que las ventanas tomen el espacio.
PAD=96
if [ "$(bspc config top_padding)" -gt 0 ] 2>/dev/null; then
    bspc config top_padding 0
    polybar-msg cmd hide >/dev/null 2>&1
else
    bspc config top_padding "$PAD"
    polybar-msg cmd show >/dev/null 2>&1
fi
