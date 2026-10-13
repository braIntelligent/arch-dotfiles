#!/bin/sh
# Pasa el escritorio a resolucion Retina (2560x1600) con todo al doble de tamano.
# Correr UNA vez en la VM, como usuario normal, DESPUES de copiar los configs 2x.
# Requiere en VMware Fusion: Settings > Display > "Use full resolution for Retina display".
# Deja respaldos .antes-retina de cada archivo que toca.
set -e
SALIDA=Virtual-1
MODO=2560x1600
MARCA="# retina-2x"

xrandr | grep -q "$MODO" || { echo "la VM no ofrece $MODO; revisa 'xrandr'"; exit 1; }
command -v xrdb >/dev/null || sudo pacman -S --needed --noconfirm xorg-xrdb

# 1. densidad y cursor: lo leen kitty, firefox y las aplicaciones GTK
xr="$HOME/.Xresources"
touch "$xr"
if ! grep -q "$MARCA" "$xr"; then
    cp "$xr" "$xr.antes-retina"
    sed -i '/^Xft\.dpi/d; /^Xcursor\.size/d' "$xr"
    printf '! %s\nXft.dpi: 192\nXcursor.size: 48\n' "${MARCA#\# }" >> "$xr"
    sed -i "s/^! retina-2x$/! $MARCA/" "$xr"
fi

# 2. resolucion y densidad al iniciar X, antes de que parta bspwm
xi="$HOME/.xinitrc"
if ! grep -q "$MARCA" "$xi"; then
    cp "$xi" "$xi.antes-retina"
    awk -v m="$MARCA" -v s="$SALIDA" -v r="$MODO" '
        !hecho && /^(sxhkd|exec)/ {
            print m
            print "xrandr --output " s " --mode " r
            print "[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources"
            hecho = 1
        }
        { print }
    ' "$xi.antes-retina" > "$xi"
fi

# 3. medidas en pixeles de bspwm: bordes, separacion y espacio de la barra, al doble
rc="$HOME/.config/bspwm/bspwmrc"
if ! grep -q "$MARCA" "$rc"; then
    cp "$rc" "$rc.antes-retina"
    awk '
        /^bspc config (border_width|window_gap|top_padding)[ \t]+[0-9]+[ \t]*$/ { $NF = $NF * 2 }
        { print }
    ' "$rc.antes-retina" > "$rc"
    printf '%s\n' "$MARCA" >> "$rc"
    chmod +x "$rc"
fi

echo "listo. Ahora sal de bspwm (Super + q) y vuelve a entrar con startx."
echo "para deshacer: restaura los archivos .antes-retina y los configs anteriores."
