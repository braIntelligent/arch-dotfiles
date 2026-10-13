#!/bin/sh
# Plugin sudo de oh-my-zsh: Esc Esc antepone "sudo" al comando actual o al anterior.
# Correr como usuario normal (pide sudo para copiar a /usr/share).
set -e
dir=/usr/share/zsh/plugins/zsh-sudo
url=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
tmp=$(mktemp)

curl -fsSL "$url" -o "$tmp"
grep -q 'sudo-command-line' "$tmp" || { echo "la descarga no parece el plugin, no instalo nada"; rm -f "$tmp"; exit 1; }

sudo install -Dm644 "$tmp" "$dir/sudo.plugin.zsh"
rm -f "$tmp"

rc="$HOME/.zshrc"
grep -q 'zsh-sudo/sudo.plugin.zsh' "$rc" || echo "source $dir/sudo.plugin.zsh" >> "$rc"
echo "listo: abre una terminal nueva y prueba con Esc Esc"
