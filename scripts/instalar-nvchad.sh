#!/bin/sh
# Neovim + NvChad (repo starter oficial). Correr como usuario normal.
# Si ya habia una config de nvim, la respalda con la fecha en el nombre.
set -e
sudo pacman -S --needed neovim git ripgrep gcc make unzip xclip

stamp=$(date +%Y%m%d-%H%M%S)
for d in "$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -e "$d" ]; then
        mv "$d" "$d.bak-$stamp"
        echo "respaldado: $d.bak-$stamp"
    fi
done

git clone --depth=1 https://github.com/NvChad/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"

nvim --version | head -1
echo "listo: abre 'nvim' en kitty y espera a que termine de bajar los plugins"
