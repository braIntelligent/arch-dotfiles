#!/bin/sh
# Instala el escritorio Hyprland sobre un Arch Linux ARM ya instalado.
# Pensado para Mac con Apple Silicon y Asahi ALARM "Minimal".
#
# Uso, desde la carpeta del repositorio:
#     sh hypr/instalar.sh                    detecta solo si es VM o equipo real
#     sh hypr/instalar.sh --teclado latam    distribucion de teclado (latam, es, us, ...)
#     sh hypr/instalar.sh --vm               fuerza los ajustes de maquina virtual
#     sh hypr/instalar.sh --nativo           fuerza la configuracion de equipo real
#
# Se corre como usuario normal: pide sudo cuando lo necesita.
# Se puede repetir: no duplica nada y respalda lo que reemplaza.
set -eu

ROFI_VER=2.0.0
ROFI_SHA256=6a55ee27f189ef9a1435cea329b146805b5dc830d8abc7a08c50a971521a8d8d
# complemento "sudo" de oh-my-zsh y prompt powerlevel10k: versiones fijas
OMZ_COMMIT=f8bf8f0029a475831ebfba0799975ede20e08742
OMZ_SUDO_SHA256=a57ca50dd7607af2651db558151cfb2fea0139bf2141b1968b87bb67d95c2c59
P10K_TAG=v1.20.0

AQUI=$(cd "$(dirname "$0")" && pwd)     # .../arch-dotfiles/hypr
RAIZ=$(dirname "$AQUI")                  # .../arch-dotfiles
COMUN="$RAIZ/compartido"                 # lo que comparten las dos variantes
SELLO=$(date +%Y%m%d-%H%M%S)

paso()  { printf '\n==> %s\n' "$1"; }
aviso() { printf '    %s\n' "$1"; }

[ "$(id -u)" != 0 ] || { echo "corre este script como usuario normal, no como root"; exit 1; }
command -v pacman >/dev/null || { echo "esto es para Arch Linux (no encuentro pacman)"; exit 1; }
for d in "$AQUI/scripts" "$AQUI/waybar" "$AQUI/rofi" "$COMUN/themes" "$COMUN/kitty" "$COMUN/qutebrowser" "$COMUN/yazi" "$COMUN/zsh"; do
    [ -d "$d" ] || { echo "falta la carpeta $d: clona el repositorio completo"; exit 1; }
done

# ---------------------------------------------------------------- modo
MODO=auto
TECLADO=""
while [ $# -gt 0 ]; do
    case "$1" in
        --vm)      MODO=vm ;;
        --nativo)  MODO=nativo ;;
        --teclado) [ $# -ge 2 ] || { echo "falta el valor de --teclado"; exit 1; }
                   TECLADO=$2; shift ;;
        *) echo "uso: $0 [--vm | --nativo] [--teclado DISTRIBUCION]"; exit 1 ;;
    esac
    shift
done
if [ "$MODO" = auto ]; then
    if systemd-detect-virt --quiet 2>/dev/null; then MODO=vm; else MODO=nativo; fi
fi
paso "Modo: $MODO"

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
    hyprland waybar hyprlock hypridle hyprsunset mako swaybg xorg-xwayland \
    kitty qutebrowser python-adblock mpv mpv-mpris yt-dlp nodejs imv zathura zathura-pdf-mupdf thunar tumbler \
    yazi poppler imagemagick 7zip fd ripgrep zoxide \
    wl-clipboard cliphist grim slurp wf-recorder wtype jq libnotify \
    hyprpolkitagent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils \
    pipewire pipewire-pulse wireplumber brightnessctl playerctl \
    bluez bluez-utils bluetui kdeconnect openvpn nss \
    zsh zsh-autosuggestions zsh-syntax-highlighting fzf lsd bat \
    ttf-hack-nerd noto-fonts-emoji \
    zram-generator \
    neovim git curl wget

# En un Mac con Asahi, este paquete trae lo propio del equipo para un escritorio
# (audio de los parlantes, teclas de funcion, etc.). Solo existe en el repositorio de ALARM.
if [ "$MODO" = nativo ] && pacman -Si asahi-desktop-meta >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm asahi-desktop-meta
fi

# El audio parte solo desde el proximo inicio de sesion; esto lo deja andando ya,
# sin tener que salir (si no, las teclas de volumen no hacen nada hasta reiniciar).
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

sudo systemctl enable --now bluetooth.service

# Swap comprimida en memoria (zram). La imagen de ALARM viene sin swap, y sin ella
# el sistema mata procesos de golpe cuando se acaba la RAM. No escribe en el disco.
if [ ! -f /etc/systemd/zram-generator.conf ]; then
    tmpf=$(mktemp)
    printf '[zram0]\nzram-size = min(ram / 2, 4096)\ncompression-algorithm = zstd\n' > "$tmpf"
    sudo install -Dm644 "$tmpf" /etc/systemd/zram-generator.conf
    rm -f "$tmpf"
    sudo systemctl daemon-reload
    sudo systemctl start systemd-zram-setup@zram0.service || aviso "la swap no partio ahora; queda activa desde el proximo arranque"
fi

# ---------------------------------------------------------------- rofi 2
# Los repositorios traen rofi 1.7.5, que solo funciona en X11. La version 2 es
# nativa de Wayland; se compila e instala en /usr/local.
rofi_actual=$(rofi -version 2>/dev/null | awk '{print $2}' | cut -d. -f1)
if [ "${rofi_actual:-0}" -ge 2 ]; then
    paso "rofi $(rofi -version | awk '{print $2}') ya esta instalado"
else
    paso "Compilando rofi $ROFI_VER (nativo de Wayland)"
    sudo pacman -S --needed --noconfirm \
        base-devel meson ninja bison flex \
        glib2 cairo pango gdk-pixbuf2 libxkbcommon libxkbcommon-x11 \
        libxcb xcb-util xcb-util-wm xcb-util-keysyms xcb-util-cursor xcb-util-xrm xcb-imdkit \
        startup-notification wayland wayland-protocols
    tmp=$(mktemp -d)
    (
        cd "$tmp"
        curl -fL -o rofi.tar.xz "https://github.com/davatorium/rofi/releases/download/$ROFI_VER/rofi-$ROFI_VER.tar.xz"
        echo "$ROFI_SHA256  rofi.tar.xz" | sha256sum -c -
        tar xf rofi.tar.xz
        cd "rofi-$ROFI_VER"
        meson setup build --prefix=/usr/local -Dwayland=enabled -Dxcb=enabled -Dcheck=disabled --buildtype=release
        ninja -C build
        sudo ninja -C build install
    )
    rm -rf "$tmp"
    hash -r
    aviso "instalado: $(/usr/local/bin/rofi -version)"
fi

# ---------------------------------------------------------------- configuracion
paso "Copiando la configuracion"
C="$HOME/.config"
mkdir -p "$C/hypr/scripts" "$C/hypr/themes" "$C/waybar/scripts" "$C/rofi" "$C/kitty" "$HOME/.cache"

poner "$AQUI/hyprland.lua"  "$C/hypr/hyprland.lua"
poner "$AQUI/hyprlock.conf" "$C/hypr/hyprlock.conf"
poner "$AQUI/hypridle.conf" "$C/hypr/hypridle.conf"
poner "$AQUI/hyprsunset.conf" "$C/hypr/hyprsunset.conf"
[ -f "$C/hypr/colores.lua" ] || install -Dm644 "$AQUI/colores.lua" "$C/hypr/colores.lua"
for f in "$AQUI"/scripts/*.sh;        do poner "$f" "$C/hypr/scripts/$(basename "$f")" 755; done
for f in "$COMUN"/themes/*.sh;        do poner "$f" "$C/hypr/themes/$(basename "$f")"; done
for f in config.jsonc htb.jsonc modulos.plantilla.jsonc; do poner "$AQUI/waybar/$f" "$C/waybar/$f"; done
poner "$AQUI/waybar/style.css"    "$C/waybar/style.css"
[ -f "$C/waybar/colors.css" ] || install -Dm644 "$AQUI/waybar/colors.css" "$C/waybar/colors.css"
for f in "$AQUI"/waybar/scripts/*.sh; do poner "$f" "$C/waybar/scripts/$(basename "$f")" 755; done
for f in "$AQUI"/rofi/*.rasi; do
    [ "$(basename "$f")" = colors.rasi ] && [ -f "$C/rofi/colors.rasi" ] && continue
    poner "$f" "$C/rofi/$(basename "$f")"
done
poner "$COMUN/kitty/kitty.conf" "$C/kitty/kitty.conf"
poner "$COMUN/qutebrowser/config.py" "$C/qutebrowser/config.py"
for f in "$COMUN"/qutebrowser/greasemonkey/*.js; do poner "$f" "$C/qutebrowser/greasemonkey/$(basename "$f")"; done
for f in yazi.toml keymap.toml package.toml; do poner "$COMUN/yazi/$f" "$C/yazi/$f"; done
ya pkg install >/dev/null 2>&1 || aviso "no se pudo bajar el complemento de yazi; despues: ya pkg install"
[ -f "$C/kitty/color.ini" ] || install -Dm644 "$COMUN/kitty/color.ini" "$C/kitty/color.ini"

# Ajustes propios de este equipo. Se crea una sola vez y despues no se toca:
# es el archivo para cambiar la distribucion del teclado o la escala de la pantalla.
if [ ! -f "$C/hypr/equipo.lua" ]; then
    if [ -z "$TECLADO" ]; then
        # la que ya este en uso en Hyprland; si no, la de la consola; si no, us
        TECLADO=$(hyprctl devices -j 2>/dev/null \
            | jq -r '[.keyboards[] | select(.main == true) | .layout][0] // empty' 2>/dev/null || true)
    fi
    if [ -z "$TECLADO" ]; then
        case "$(sed -n 's/^KEYMAP=//p' /etc/vconsole.conf 2>/dev/null | tr -d '"')" in
            la-latin1|latam) TECLADO=latam ;;
            es*)             TECLADO=es ;;
            *)               TECLADO=us ;;
        esac
    fi
    cat > "$C/hypr/equipo.lua" <<EOT
-- Ajustes de este equipo. instalar.sh lo crea una vez y no lo vuelve a tocar.
return {
    teclado = "$TECLADO",   -- distribucion del teclado: latam, es, us, ...
    escala  = 2,            -- escala de la pantalla del portatil (2 = Retina)
}
EOT
    aviso "teclado: $TECLADO  (se cambia en ~/.config/hypr/equipo.lua)"
elif [ -n "$TECLADO" ]; then
    sed -i "s/teclado *= *\"[^\"]*\"/teclado = \"$TECLADO\"/" "$C/hypr/equipo.lua"
    aviso "teclado: $TECLADO"
fi

if [ "$MODO" = vm ]; then
    : > "$C/hypr/es-vm"
    aviso "marcado como maquina virtual (kitty y el bloqueo dibujan por software)"
else
    rm -f "$C/hypr/es-vm"
fi

# ---------------------------------------------------------------- programas por defecto
# con que se abre cada tipo de archivo: videos en mpv, PDF en zathura, imagenes en imv (las flechas recorren la carpeta), carpetas en thunar
for t in video/mp4 video/x-matroska video/webm video/quicktime; do xdg-mime default mpv.desktop "$t"; done
for t in image/png image/jpeg image/webp image/gif; do xdg-mime default imv-dir.desktop "$t"; done
xdg-mime default thunar.desktop inode/directory
xdg-mime default org.pwmt.zathura.desktop application/pdf
xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop 2>/dev/null || true

# yt-dlp al dia para la musica de YouTube (la version de los repositorios queda vieja)
sh "$RAIZ/extras/actualizar-yt-dlp.sh" || aviso "no se pudo actualizar yt-dlp; despues: sh extras/actualizar-yt-dlp.sh"

# ---------------------------------------------------------------- fondos
paso "Fondos de pantalla"
mkdir -p "$HOME/Pictures/wallpapers" "$HOME/Pictures/capturas" "$HOME/Videos/grabaciones" "$HOME/vpn"
if [ -d "$RAIZ/wallpapers" ]; then
    for f in "$RAIZ"/wallpapers/*; do
        [ -f "$f" ] && [ ! -f "$HOME/Pictures/wallpapers/$(basename "$f")" ] && cp "$f" "$HOME/Pictures/wallpapers/"
    done
fi
if [ ! -s "$HOME/.cache/wall" ]; then
    primero=$(ls "$HOME"/Pictures/wallpapers/* 2>/dev/null | head -n1 || true)
    [ -n "$primero" ] && printf '%s\n' "$primero" > "$HOME/.cache/wall"
fi

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
poner "$COMUN/zsh/.zshrc"    "$HOME/.zshrc"
poner "$COMUN/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
cat > "$C/target.zsh" <<'EOT'
# Maquina objetivo que muestra la barra
settarget() {
    if [ -z "$1" ]; then
        echo "uso: settarget <ip> [nombre]"
        return 1
    fi
    echo "$1 $2" > ~/.config/hypr/target
}
cleartarget() {
    : > ~/.config/hypr/target
}
EOT
if [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]; then
    sudo chsh -s /usr/bin/zsh "$USER"
    aviso "zsh queda como shell desde el proximo inicio de sesion"
fi

# ---------------------------------------------------------------- inicio de sesion
paso "Arranque de Hyprland al entrar por la primera consola"
zp="$HOME/.zprofile"
touch "$zp"
if ! grep -q 'start-hyprland' "$zp"; then
    cp "$zp" "$zp.antes-$SELLO"
    cat >> "$zp" <<'EOT'

# Hyprland al iniciar sesion en la primera consola
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${DISPLAY:-}" ] && [ "${XDG_VTNR:-0}" = 1 ]; then
    start-hyprland > ~/.cache/hyprland-inicio.log 2>&1
fi
EOT
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
tema=$(cat "$HOME/.cache/theme" 2>/dev/null || true)
[ -f "$C/hypr/themes/$tema.sh" ] || tema=tokyonight
"$C/hypr/scripts/set-theme.sh" "$tema"
aviso "tema: $tema"

# ---------------------------------------------------------------- comprobacion
paso "Comprobando la configuracion de Hyprland"
# sin sesion grafica abierta (por ejemplo, lanzado desde preparar.sh) no existe
# XDG_RUNTIME_DIR y Hyprland se niega a correr, aunque solo sea para revisar
rt=${XDG_RUNTIME_DIR:-}
[ -n "$rt" ] || rt=$(mktemp -d)
if XDG_RUNTIME_DIR="$rt" Hyprland --verify-config -c "$C/hypr/hyprland.lua" 2>&1 | grep -q 'config ok'; then
    aviso "config ok"
else
    aviso "la configuracion tiene errores; para verlos:"
    aviso "Hyprland --verify-config -c ~/.config/hypr/hyprland.lua"
fi

paso "Listo"
aviso "Cierra la sesion y entra de nuevo por la primera consola: Hyprland parte solo."
aviso "Atajos: Super + Shift + D muestra la hoja completa."
