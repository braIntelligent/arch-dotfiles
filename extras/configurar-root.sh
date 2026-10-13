#!/bin/sh
# Copia la configuracion de zsh + powerlevel10k del usuario a root
# y le agrega una identificacion visible de root en el prompt.
# Correr con sudo desde el usuario normal. Se puede repetir: regenera todo.
set -e
if [ "$(id -u)" != 0 ]; then
    echo "hay que correrlo con sudo"
    exit 1
fi
u=${SUDO_USER:?corre este script con sudo desde tu usuario normal}
uh=$(getent passwd "$u" | cut -d: -f6)
for f in "$uh/.zshrc" "$uh/.p10k.zsh" "$uh/powerlevel10k/powerlevel10k.zsh-theme"; do
    [ -e "$f" ] || { echo "falta $f"; exit 1; }
done

rm -rf /root/powerlevel10k
cp -r "$uh/powerlevel10k" /root/powerlevel10k
cp "$uh/.p10k.zsh" /root/.p10k.zsh

# .zshrc del usuario, sin la linea del target (root usa su propia version mas abajo)
sed '/target\.zsh/d' "$uh/.zshrc" > /root/.zshrc

cat >> /root/.zshrc <<'ROOT'

# ---------- solo root ----------
# usuario@host siempre a la izquierda, en rojo y con un rayo
(( ${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(I)context]} )) || \
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context $POWERLEVEL9K_LEFT_PROMPT_ELEMENTS)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#context})
typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE=$'%B %n@%m'
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=196
# simbolo del prompt: "#" rojo en vez de la flecha
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='#'

# target de la barra: escribe en el archivo del usuario para que la barra lo vea
_target_file=@TF@
settarget() {
    if [ -z "$1" ]; then
        echo "uso: settarget <ip> [nombre]"
        return 1
    fi
    echo "$1 $2" > $_target_file
    chown @U@: $_target_file
}
cleartarget() {
    : > $_target_file
    chown @U@: $_target_file
}
ROOT
# la barra de Hyprland lee el target de su propia carpeta; la de bspwm, de la de polybar
tf="$uh/.config/polybar/target"
[ -d "$uh/.config/hypr" ] && tf="$uh/.config/hypr/target"
sed -i "s|@TF@|$tf|g; s|@U@|$u|g" /root/.zshrc

chown -R root:root /root/powerlevel10k /root/.p10k.zsh /root/.zshrc
chsh -s /usr/bin/zsh root >/dev/null
echo "listo: prueba con 'sudo su'"
