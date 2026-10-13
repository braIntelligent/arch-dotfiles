# Funciones para el laboratorio (HTB y similares). Las carga ~/.zshrc.

# mkt [nombre]: arma las carpetas de trabajo de una maquina y entra en ella
mkt() {
    if [ -n "$1" ]; then mkdir -p "$1" && cd "$1" || return 1; fi
    mkdir -p nmap content exploits scripts
}

# extractPorts <archivo>: saca la IP y los puertos abiertos de un escaneo de nmap en
# formato "grepable" (nmap -oG archivo) y deja los puertos copiados, listos para
# pegarlos en el escaneo siguiente:  nmap -sCV -p<pegar> <ip>
extractPorts() {
    if [ ! -f "$1" ]; then
        echo "uso: extractPorts <archivo de nmap -oG>"
        return 1
    fi
    local ip puertos
    ip=$(grep -oE '^Host: [0-9a-fA-F.:]+' "$1" | head -n1 | cut -d' ' -f2)
    puertos=$(grep -oE '[0-9]{1,5}/open' "$1" | cut -d/ -f1 | sort -un | paste -sd, -)
    if [ -z "$puertos" ]; then
        echo "no hay puertos abiertos en $1"
        return 1
    fi
    echo "  IP:       $ip"
    echo "  Puertos:  $puertos"
    if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null; then
        printf '%s' "$puertos" | wl-copy >/dev/null 2>&1
        echo "  (puertos copiados)"
    elif command -v xclip >/dev/null; then
        printf '%s' "$puertos" | xclip -selection clipboard
        echo "  (puertos copiados)"
    fi
}

# addhost <ip> <nombre> [otro nombre...]: agrega la maquina a /etc/hosts
# delhost <nombre>: quita las lineas que la nombran
addhost() {
    if [ $# -lt 2 ]; then
        echo "uso: addhost <ip> <nombre> [otro nombre...]"
        return 1
    fi
    local ip=$1; shift
    if grep -qE "^$ip[[:space:]]" /etc/hosts; then
        echo "ya hay una linea para $ip:"; grep -E "^$ip[[:space:]]" /etc/hosts
        return 1
    fi
    echo "$ip $*" | sudo tee -a /etc/hosts >/dev/null && echo "agregado: $ip $*"
}
delhost() {
    if [ -z "$1" ]; then
        echo "uso: delhost <nombre>"
        return 1
    fi
    grep -E "[[:space:]]$1([[:space:]]|\$)" /etc/hosts || { echo "no esta: $1"; return 1; }
    sudo sed -i -E "/[[:space:]]$1([[:space:]]|\$)/d" /etc/hosts && echo "quitado"
}
