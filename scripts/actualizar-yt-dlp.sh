#!/bin/sh
# Instala o actualiza yt-dlp a la ultima version, en ~/.local/bin.
# YouTube cambia seguido y la version de los repositorios queda vieja (error 403 al
# reproducir). Si la musica o los videos de YouTube dejan de abrir, correr esto de nuevo.
# Como usuario normal; no pide sudo. Verifica la descarga contra las sumas del proyecto.
set -eu
base=https://github.com/yt-dlp/yt-dlp/releases/latest/download
dest="$HOME/.local/bin/yt-dlp"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/yt-dlp" "$base/yt-dlp"
curl -fsSL -o "$tmp/SHA2-256SUMS" "$base/SHA2-256SUMS"
( cd "$tmp" && grep ' yt-dlp$' SHA2-256SUMS | sha256sum -c - >/dev/null )
install -Dm755 "$tmp/yt-dlp" "$dest"

# YouTube exige un interprete de JavaScript; se usa node, que ya esta instalado
cfg="$HOME/.config/yt-dlp/config"
mkdir -p "$(dirname "$cfg")"
grep -qs -- '--js-runtimes' "$cfg" || echo '--js-runtimes node' >> "$cfg"

# mpv (y con el ytfzf) usa esta version y no la del sistema
mpvc="$HOME/.config/mpv/mpv.conf"
mkdir -p "$(dirname "$mpvc")"
grep -qs 'ytdl_hook-ytdl_path' "$mpvc" || echo "script-opts-append=ytdl_hook-ytdl_path=$dest" >> "$mpvc"

echo "listo: yt-dlp $("$dest" --version)"
