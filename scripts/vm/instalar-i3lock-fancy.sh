#!/bin/sh
# i3lock-fancy (bloqueo de pantalla con captura difuminada) + atajo en sxhkd.
# Correr como usuario normal. Se puede repetir sin duplicar el atajo.
set -e
sudo pacman -S --needed i3lock imagemagick scrot wmctrl git make

tmp=$(mktemp -d)
git clone --depth=1 https://github.com/meskarune/i3lock-fancy.git "$tmp/i3lock-fancy"
( cd "$tmp/i3lock-fancy" && sudo make install )
rm -rf "$tmp"

rc="$HOME/.config/sxhkd/sxhkdrc"
if grep -q 'i3lock-fancy' "$rc"; then
    echo "el atajo ya estaba en sxhkdrc"
elif grep -q '^super + shift + x' "$rc"; then
    echo "OJO: 'super + shift + x' ya esta en uso en sxhkdrc; agrega el atajo a mano con otra tecla"
else
    cat >> "$rc" <<'KEYS'

# bloquear pantalla
super + shift + x
    /usr/bin/i3lock-fancy
KEYS
    echo "atajo agregado: super + shift + x"
fi

pkill -USR1 -x sxhkd 2>/dev/null || true
echo "listo"
