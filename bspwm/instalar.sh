#!/bin/sh
# Instala el escritorio bspwm (X11) sobre un Arch Linux ARM ya instalado.
# Pensado para la maquina virtual en VMware Fusion con pantalla Retina.
#
# Uso, desde la carpeta del repositorio:
#     sh bspwm/instalar.sh                    teclado latam
#     sh bspwm/instalar.sh --teclado us       otra distribucion (es, us, ...)
#     sh bspwm/instalar.sh --resolucion 3024x1964   resolucion de la pantalla del Mac
#                                             (por defecto 2560x1600, la del MacBook Air M1)
#
# Se corre como usuario normal: pide sudo cuando lo necesita.
# Se puede repetir: no duplica nada y respalda lo que reemplaza.
# Las herramientas de pentesting van aparte: extras/instalar-blackarch.sh e instalar-herramientas.sh
set -eu

# complemento "sudo" de oh-my-zsh y prompt powerlevel10k: versiones fijas
OMZ_COMMIT=f8bf8f0029a475831ebfba0799975ede20e08742
OMZ_SUDO_SHA256=a57ca50dd7607af2651db558151cfb2fea0139bf2141b1968b87bb67d95c2c59
P10K_TAG=v1.20.0

AQUI=$(cd "$(dirname "$0")" && pwd)     # .../arch-dotfiles/bspwm
RAIZ=$(dirname "$AQUI")                  # .../arch-dotfiles
COMUN="$RAIZ/compartido"                 # lo que comparten las dos variantes
SELLO=$(date +%Y%m%d-%H%M%S)

paso()  { printf '\n==> %s\n' "$1"; }
aviso() { printf '    %s\n' "$1"; }

[ "$(id -u)" != 0 ] || { echo "corre este script como usuario normal, no como root"; exit 1; }
command -v pacman >/dev/null || { echo "esto es para Arch Linux (no encuentro pacman)"; exit 1; }
for d in "$AQUI/scripts" "$AQUI/sxhkd" "$AQUI/polybar" "$AQUI/picom" "$AQUI/rofi" "$AQUI/inicio" "$COMUN/themes" "$COMUN/kitty" "$COMUN/zsh"; do
    [ -d "$d" ] || { echo "falta la carpeta $d: clona el repositorio completo"; exit 1; }
done

TECLADO=latam
RESOLUCION=2560x1600
while [ $# -gt 0 ]; do
    case "$1" in
        --teclado) [ $# -ge 2 ] || { echo "falta el valor de --teclado"; exit 1; }
                   TECLADO=$2; shift ;;
        --resolucion) [ $# -ge 2 ] || { echo "falta el valor de --resolucion"; exit 1; }
                   printf '%s' "$2" | grep -Eq '^[0-9]+x[0-9]+$' || { echo "resolucion no valida: $2 (ejemplo: 2560x1600)"; exit 1; }
                   RESOLUCION=$2; shift ;;
        *) echo "uso: $0 [--teclado DISTRIBUCION] [--resolucion ANCHOxALTO]"; exit 1 ;;
    esac
    shift
done

# copia un archivo; si el destino existe y es distinto, lo respalda primero
poner() {
    if [ -f "$2" ] && ! cmp -s "$1" "$2"; then
        cp "$2" "$2.antes-$SELLO"
        aviso "respaldado: $2.antes-$SELLO"
    fi
    install -Dm"${3:-644}" "$1" "$2"
}

# ---------------------------------------------------------------- paquetes
paso "Actualizando el sistema e instalando paquetes"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
    xorg-server xorg-xinit xorg-xsetroot xorg-xrandr xorg-setxkbmap xorg-xrdb mesa \
    bspwm sxhkd polybar picom rofi dunst libnotify feh \
    kitty maim xclip xdotool xorg-xinput wmctrl i3lock imagemagick jq \
    zsh zsh-autosuggestions zsh-syntax-highlighting fzf lsd bat tmux \
    ttf-hack-nerd ttf-dejavu \
    openvpn neovim git curl wget

# ---------------------------------------------------------------- configuracion
paso "Copiando la configuracion"
C="$HOME/.config"
mkdir -p "$C/bspwm/scripts" "$C/bspwm/themes" "$C/sxhkd/scripts" "$C/polybar/scripts" "$C/rofi" "$C/kitty" "$HOME/.cache"

poner "$AQUI/bspwmrc" "$C/bspwm/bspwmrc" 755
for f in "$AQUI"/scripts/*.sh;          do poner "$f" "$C/bspwm/scripts/$(basename "$f")" 755; done
for f in "$COMUN"/themes/*.sh;          do poner "$f" "$C/bspwm/themes/$(basename "$f")"; done
poner "$AQUI/sxhkd/sxhkdrc" "$C/sxhkd/sxhkdrc"
for f in "$AQUI"/sxhkd/scripts/*.sh;    do poner "$f" "$C/sxhkd/scripts/$(basename "$f")" 755; done
poner "$AQUI/polybar/config.ini" "$C/polybar/config.ini"
poner "$AQUI/polybar/launch.sh"  "$C/polybar/launch.sh" 755
for f in "$AQUI"/polybar/scripts/*.sh;  do poner "$f" "$C/polybar/scripts/$(basename "$f")" 755; done
poner "$AQUI/picom/picom.conf" "$C/picom/picom.conf"
# los colores los escribe el tema: solo se copian si aun no existen
for f in "$AQUI"/rofi/*.rasi; do
    [ "$(basename "$f")" = colors.rasi ] && [ -f "$C/rofi/colors.rasi" ] && continue
    poner "$f" "$C/rofi/$(basename "$f")"
done
[ -f "$C/polybar/colors.ini" ] || install -Dm644 "$AQUI/polybar/colors.ini" "$C/polybar/colors.ini"
[ -f "$C/kitty/color.ini" ]    || install -Dm644 "$COMUN/kitty/color.ini"  "$C/kitty/color.ini"

# kitty: la misma del equipo real, con letra mas chica y algo mas de transparencia
tmpf=$(mktemp)
sed -e 's/^font_size .*/font_size 11/' -e 's/^background_opacity .*/background_opacity 0.90/' \
    "$COMUN/kitty/kitty.conf" > "$tmpf"
poner "$tmpf" "$C/kitty/kitty.conf"
rm -f "$tmpf"

# ---------------------------------------------------------------- inicio de sesion
paso "Arranque de X11 y bspwm al entrar por la primera consola"
tmpf=$(mktemp)
sed -e "s/^setxkbmap .*/setxkbmap $TECLADO/" -e "s/--mode [0-9x]*/--mode $RESOLUCION/" "$AQUI/inicio/xinitrc" > "$tmpf"
poner "$tmpf" "$HOME/.xinitrc"
rm -f "$tmpf"
poner "$AQUI/inicio/Xresources" "$HOME/.Xresources"
poner "$AQUI/inicio/zprofile"   "$HOME/.zprofile"
aviso "teclado: $TECLADO, pantalla: $RESOLUCION  (se cambian en ~/.xinitrc)"

# ---------------------------------------------------------------- shell
paso "zsh, complementos y prompt"
if [ ! -f /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh ]; then
    tmpf=$(mktemp)
    curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/$OMZ_COMMIT/plugins/sudo/sudo.plugin.zsh" -o "$tmpf"
    echo "$OMZ_SUDO_SHA256  $tmpf" | sha256sum -c - >/dev/null
    sudo install -Dm644 "$tmpf" /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
    rm -f "$tmpf"
fi
[ -d "$HOME/powerlevel10k" ] || git clone --depth=1 --branch "$P10K_TAG" https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
poner "$COMUN/zsh/.zshrc"     "$HOME/.zshrc"
poner "$COMUN/zsh/.p10k.zsh"  "$HOME/.p10k.zsh"
poner "$COMUN/zsh/lab.zsh"    "$C/lab.zsh"
poner "$COMUN/zsh/target.zsh" "$C/target.zsh"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]; then
    sudo chsh -s /usr/bin/zsh "$USER"
    aviso "zsh queda como shell desde el proximo inicio de sesion"
fi

# ---------------------------------------------------------------- energia
paso "Permiso para apagar, reiniciar y suspender desde el menu"
regla=/etc/sudoers.d/10-power
if [ ! -f "$regla" ]; then
    tmpf=$(mktemp)
    echo '%wheel ALL=(root) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend' > "$tmpf"
    if sudo visudo -cf "$tmpf" >/dev/null; then
        sudo install -m440 -o root -g root "$tmpf" "$regla"
    else
        aviso "la regla de sudoers no paso la validacion; no se instalo"
    fi
    rm -f "$tmpf"
fi

# ---------------------------------------------------------------- tema
paso "Aplicando el tema"
mkdir -p "$HOME/Pictures/wallpapers" "$HOME/Pictures/capturas"
tema=$(cat "$HOME/.cache/theme" 2>/dev/null || true)
[ -f "$C/bspwm/themes/$tema.sh" ] || tema=negro
"$C/bspwm/scripts/set-theme.sh" "$tema" >/dev/null 2>&1 || true
aviso "tema: $tema"

paso "Listo"
aviso "Cierra la sesion y entra de nuevo por la primera consola: bspwm parte solo."
aviso "Atajos: Super + Shift + D muestra la hoja completa."
