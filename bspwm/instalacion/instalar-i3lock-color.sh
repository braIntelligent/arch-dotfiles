#!/bin/sh
# Compila i3lock-color (lockscreen con reloj en vivo) desde el fuente.
# No existe en los repos de Arch ARM. Correr como usuario normal.
set -e
sudo pacman -S --needed --noconfirm base-devel git autoconf pkgconf cairo \
    libxcb xcb-util-image xcb-util-xrm libev libjpeg-turbo pam libxkbcommon \
    xcb-util xorgproto imagemagick
tmp=$(mktemp -d)
git clone --depth=1 https://github.com/Raymo111/i3lock-color.git "$tmp/i3lc"
cd "$tmp/i3lc"
sh ./install-i3lock-color.sh
cd /; rm -rf "$tmp"
echo "listo: i3lock-color instalado (lock.sh ya lo usara automaticamente)"
