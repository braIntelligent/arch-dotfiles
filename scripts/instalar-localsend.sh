#!/bin/sh
# LocalSend: enviar archivos y texto por la red local a un iPhone, Mac u otro equipo
# (parecido a AirDrop; el otro lado necesita la app LocalSend). No esta en los
# repositorios de Arch ARM: se baja la version oficial para aarch64, verificada.
# Correr como usuario normal (pide sudo). Queda en /opt/localsend y se abre con "localsend".
set -eu
VER=1.18.2
SHA256=dd61f74f1ce3f4e25aca41cd3ce650d6a99353d7baba81a8139807275b88e606

[ "$(uname -m)" = aarch64 ] || { echo "este script es para aarch64"; exit 1; }
sudo pacman -S --needed --noconfirm gtk3 libayatana-appindicator

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fL -o "$tmp/ls.tar.gz" \
    "https://github.com/localsend/localsend/releases/download/v$VER/LocalSend-$VER-linux-arm-64.tar.gz"
echo "$SHA256  $tmp/ls.tar.gz" | sha256sum -c -

sudo rm -rf /opt/localsend
sudo mkdir -p /opt/localsend
sudo tar xf "$tmp/ls.tar.gz" -C /opt/localsend
sudo ln -sf /opt/localsend/localsend_app /usr/local/bin/localsend
echo "listo: abrelo con 'localsend' o desde el lanzador (Super + Espacio)"
