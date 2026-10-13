#!/bin/sh
# lsd, bat y powerlevel10k. Correr como usuario normal (pide sudo para pacman).
# Se puede correr mas de una vez sin duplicar nada.
set -e
sudo pacman -S --needed lsd bat git

rc="$HOME/.zshrc"
touch "$rc"

if ! grep -q '^# lsd y bat$' "$rc"; then
    cat >> "$rc" <<'ALIASES'

# lsd y bat
alias ls='lsd --group-dirs=first'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'
ALIASES
fi

if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
fi
grep -q 'powerlevel10k.zsh-theme' "$rc" || echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> "$rc"

echo "listo: cierra kitty y abrela de nuevo para el asistente de powerlevel10k"
