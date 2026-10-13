#!/bin/sh
# Prepara un Asahi ALARM "Minimal" recien instalado y deja el escritorio armado.
# Pregunta lo necesario (red, teclado, usuario, claves, zona horaria, nombre del
# equipo, idioma, SSH), crea el usuario y lanza hypr/instalar.sh con el.
#
# Se corre como root en el primer arranque:
#     curl -fsSL https://raw.githubusercontent.com/braIntelligent/arch-dotfiles/main/hypr/preparar.sh | sh
# o, para leerlo antes de ejecutarlo:
#     curl -fsSLO https://raw.githubusercontent.com/braIntelligent/arch-dotfiles/main/hypr/preparar.sh
#     sh preparar.sh
#
# DOTFILES_REPO cambia de donde se clona (por ejemplo, un fork propio).

# Todo va dentro de una funcion: asi el script se lee completo antes de ejecutar
# nada (una descarga cortada no corre a medias) y las preguntas pueden leer del
# teclado aunque el script llegue por una tuberia.
principal() {
    set -eu
    REPO=${DOTFILES_REPO:-https://github.com/braIntelligent/arch-dotfiles.git}
    PERMISO=/etc/sudoers.d/99-instalacion-temporal

    paso()  { printf '\n==> %s\n' "$1"; }
    aviso() { printf '    %s\n' "$1"; }
    falla() { printf '\nerror: %s\n' "$1" >&2; exit 1; }

    # pregunta "texto" [valor por defecto]; deja la respuesta en $R
    preguntar() {
        if [ -n "${2:-}" ]; then printf '%s [%s]: ' "$1" "$2"; else printf '%s: ' "$1"; fi
        read -r R || falla "no pude leer la respuesta"
        [ -n "$R" ] || R=${2:-}
    }
    # pide una clave dos veces, sin mostrarla; la deja en $R
    preguntar_clave() {
        while :; do
            printf '%s: ' "$1"; stty -echo; read -r R; stty echo; printf '\n'
            printf 'Repetir: ';  stty -echo; read -r R2; stty echo; printf '\n'
            [ -n "$R" ] || { aviso "no puede quedar vacia"; continue; }
            [ "$R" = "$R2" ] && return 0
            aviso "no coinciden, de nuevo"
        done
    }
    hay_red() { curl -fsS -m 8 -o /dev/null https://archlinuxarm.org 2>/dev/null; }

    [ "$(id -u)" = 0 ] || falla "este script se corre como root (en el primer arranque de ALARM)"
    command -v pacman >/dev/null || falla "esto es para Arch Linux (no encuentro pacman)"
    trap 'stty echo 2>/dev/null; rm -f "$PERMISO"' EXIT

    printf '\nPreparacion de Asahi ALARM. Enter acepta el valor entre corchetes.\n'

    # ------------------------------------------------------------ teclado
    preguntar "Distribucion del teclado (latam, es, us, ...)" us
    TECLADO=$R
    case "$TECLADO" in
        latam) mapa=la-latin1 ;;
        *)     mapa=$TECLADO ;;
    esac
    if loadkeys "$mapa" 2>/dev/null; then
        printf 'KEYMAP=%s\n' "$mapa" > /etc/vconsole.conf
    else
        aviso "la consola no conoce \"$mapa\"; sigue como estaba (el escritorio usara $TECLADO)"
    fi

    # ------------------------------------------------------------ red
    paso "Red"
    until hay_red; do
        aviso "sin conexion a internet"
        command -v nmcli >/dev/null || falla "no hay red ni nmcli para conectar el wifi"
        nmcli -t -f SSID device wifi list 2>/dev/null | grep -v '^$' | sort -u | head -n 15 | sed 's/^/      /'
        preguntar "Nombre de la red wifi"
        red=$R
        printf 'Clave del wifi: '; stty -echo; read -r clave_wifi; stty echo; printf '\n'
        nmcli device wifi connect "$red" password "$clave_wifi" || aviso "no se pudo conectar; de nuevo"
        sleep 3
    done
    aviso "conectado"

    # ------------------------------------------------------------ preguntas
    paso "Usuario"
    while :; do
        preguntar "Nombre de usuario (minusculas, sin espacios)"
        USUARIO=$R
        printf '%s' "$USUARIO" | grep -Eq '^[a-z_][a-z0-9_-]{0,30}$' && break
        aviso "nombre no valido"
    done
    if id "$USUARIO" >/dev/null 2>&1; then
        aviso "el usuario $USUARIO ya existe: se usa tal cual y no se le cambia la clave"
        CLAVE=""
    else
        preguntar_clave "Clave para $USUARIO"
        CLAVE=$R
    fi

    preguntar "Cambiar la clave de root (hoy es \"root\")? s/n" s
    CLAVE_ROOT=""
    case "$R" in
        s|S|si|SI|Si)
            preguntar "Usar la misma clave del usuario? s/n" s
            case "$R" in
                s|S|si|SI|Si) [ -n "$CLAVE" ] && CLAVE_ROOT=$CLAVE ;;
            esac
            [ -n "$CLAVE_ROOT" ] || { preguntar_clave "Clave nueva de root"; CLAVE_ROOT=$R; }
            ;;
    esac

    zona_actual=$(timedatectl show -p Timezone --value 2>/dev/null || echo UTC)
    while :; do
        preguntar "Zona horaria (por ejemplo America/Santiago)" "$zona_actual"
        ZONA=$R
        [ -f "/usr/share/zoneinfo/$ZONA" ] && break
        aviso "no existe esa zona; las hay en /usr/share/zoneinfo"
    done

    preguntar "Nombre del equipo" "$(cat /etc/hostname 2>/dev/null || echo arch)"
    EQUIPO=$R

    while :; do
        preguntar "Idioma del sistema (es_CL, es_ES, es_MX, en_US, ...)" en_US
        IDIOMA=$R
        grep -q "^#\\{0,1\\}$IDIOMA\\.UTF-8 UTF-8" /etc/locale.gen && break
        aviso "no existe ese idioma; la lista esta en /etc/locale.gen"
    done

    # la imagen de ALARM trae SSH encendido y abierto a toda la red
    preguntar "Dejar SSH encendido, para entrar a este equipo desde otro? s/n" n
    case "$R" in
        s|S|si|SI|Si) SSH=si ;;
        *)            SSH=no ;;
    esac

    # ------------------------------------------------------------ sistema
    paso "Zona horaria y nombre del equipo"
    ln -sf "/usr/share/zoneinfo/$ZONA" /etc/localtime
    timedatectl set-ntp true 2>/dev/null || true
    printf '%s\n' "$EQUIPO" > /etc/hostname
    hostname "$EQUIPO" 2>/dev/null || true

    paso "Idioma"
    sed -i "s/^#\\($IDIOMA\\.UTF-8 UTF-8\\)/\\1/" /etc/locale.gen
    locale-gen >/dev/null
    printf 'LANG=%s.UTF-8\n' "$IDIOMA" > /etc/locale.conf
    aviso "$IDIOMA.UTF-8"

    if [ "$SSH" = no ]; then
        # las conexiones ya abiertas siguen; solo deja de aceptar nuevas
        systemctl disable --now sshd.service >/dev/null 2>&1 || true
        aviso "SSH apagado (se enciende con: systemctl enable --now sshd)"
    fi

    paso "Actualizando el sistema"
    pacman -Syu --noconfirm --needed git sudo

    paso "Usuario y permisos"
    if ! id "$USUARIO" >/dev/null 2>&1; then
        useradd -m -G wheel -s /bin/bash "$USUARIO"
        printf '%s:%s\n' "$USUARIO" "$CLAVE" | chpasswd
        aviso "creado: $USUARIO"
    else
        usermod -aG wheel "$USUARIO"
    fi
    if [ -n "$CLAVE_ROOT" ]; then
        printf 'root:%s\n' "$CLAVE_ROOT" | chpasswd
        aviso "clave de root cambiada"
    fi
    # los del grupo wheel pueden usar sudo con su clave
    regla=/etc/sudoers.d/10-wheel
    if [ ! -f "$regla" ]; then
        tmpf=$(mktemp)
        echo '%wheel ALL=(ALL:ALL) ALL' > "$tmpf"
        visudo -cf "$tmpf" >/dev/null || falla "la regla de sudoers no paso la validacion"
        install -m440 -o root -g root "$tmpf" "$regla"
        rm -f "$tmpf"
    fi
    # mientras dura la instalacion, sudo sin clave para ese usuario; se borra al salir
    tmpf=$(mktemp)
    printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$USUARIO" > "$tmpf"
    visudo -cf "$tmpf" >/dev/null || falla "el permiso temporal no paso la validacion"
    install -m440 -o root -g root "$tmpf" "$PERMISO"
    rm -f "$tmpf"

    # ------------------------------------------------------------ escritorio
    paso "Descargando la configuracion"
    casa=$(getent passwd "$USUARIO" | cut -d: -f6)
    destino="$casa/arch-dotfiles"
    if [ -d "$destino/.git" ]; then
        sudo -u "$USUARIO" -H git -C "$destino" pull --ff-only || aviso "no se pudo actualizar; se usa la copia que ya estaba"
    else
        sudo -u "$USUARIO" -H git clone "$REPO" "$destino"
    fi

    paso "Instalando el escritorio (tarda varios minutos)"
    sudo -u "$USUARIO" -H sh "$destino/hypr/instalar.sh" --teclado "$TECLADO"

    paso "Terminado"
    aviso "Escribe 'exit' e inicia sesion como $USUARIO: Hyprland parte solo."
}

principal "$@" < /dev/tty
