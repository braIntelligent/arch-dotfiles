#!/bin/sh
# Caido: proxy para auditar aplicaciones web (alternativa liviana a Burp Suite).
# Se instala la version de consola: corre en segundo plano y su interfaz se abre en
# el navegador. No esta en los repositorios; se baja la oficial para aarch64, verificada.
# Correr como usuario normal (pide sudo). Queda como /usr/local/bin/caido-cli.
# Despues: clic en "proxy" en la barra de HTB, o ~/.config/hypr/scripts/caido.sh
set -eu
VER=0.58.3
SHA512_B64='0zYHgW+BRZvqgbX+Fy3Esd+ecibjS8bRilGXNUOlh+V1K8iCY/ZOygACZmZYdAElMMniDIUcZFj3P4jcX6DLrw=='

[ "$(uname -m)" = aarch64 ] || { echo "este script es para aarch64"; exit 1; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fL -o "$tmp/caido.tar.gz" "https://caido.download/releases/v$VER/caido-cli-v$VER-linux-aarch64.tar.gz"
# Caido publica la suma SHA-512 en base64
suma=$(sha512sum "$tmp/caido.tar.gz" | cut -d' ' -f1 | xxd -r -p | base64 -w0)
[ "$suma" = "$SHA512_B64" ] || { echo "la descarga no coincide con la suma publicada; no instalo nada"; exit 1; }
tar xzf "$tmp/caido.tar.gz" -C "$tmp"
sudo install -Dm755 "$tmp/caido-cli" /usr/local/bin/caido-cli
echo "listo: $(caido-cli --version)"
