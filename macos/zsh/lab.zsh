# Funciones para el laboratorio (HTB y similares). Versión macOS (pbcopy, sed BSD).

# mkt [nombre]: arma las carpetas de trabajo de una maquina y entra en ella
mkt() {
    if [ -n "$1" ]; then mkdir -p "$1" && cd "$1" || return 1; fi
    mkdir -p nmap content exploits scripts
}

# extractPorts <archivo>: IP y puertos abiertos de un nmap -oG; copia los puertos al clipboard
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
    if command -v pbcopy >/dev/null; then
        printf '%s' "$puertos" | pbcopy
        echo "  (puertos copiados)"
    fi
}

# addhost <ip> <nombre> [otro...]: agrega la maquina a /etc/hosts
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
# delhost <nombre>: quita las lineas que la nombran (sed BSD: -i '')
delhost() {
    if [ -z "$1" ]; then
        echo "uso: delhost <nombre>"
        return 1
    fi
    grep -E "[[:space:]]$1([[:space:]]|\$)" /etc/hosts || { echo "no esta: $1"; return 1; }
    sudo sed -i '' -E "/[[:space:]]$1([[:space:]]|\$)/d" /etc/hosts && echo "quitado"
}

# settarget <ip> [nombre] / cleartarget: objetivo mostrado en sketchybar
settarget() {
    if [ -z "$1" ]; then echo "uso: settarget <ip> [nombre]"; return 1; fi
    echo "$1 $2" > ~/.config/sketchybar/target
    command -v sketchybar >/dev/null && sketchybar --trigger target_change >/dev/null 2>&1
    echo "target: $1 $2"
}
cleartarget() {
    : > ~/.config/sketchybar/target
    command -v sketchybar >/dev/null && sketchybar --trigger target_change >/dev/null 2>&1
    echo "target limpiado"
}

# ips: muestra LAN, VPN(tun/utun) y target desde la terminal (sin depender de la barra)
ips() {
    local iface lan vpn tgt
    iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')
    lan=$(ipconfig getifaddr "$iface" 2>/dev/null); [ -z "$lan" ] && lan=$(ipconfig getifaddr en0 2>/dev/null)
    echo "LAN:    ${lan:-sin red}  (${iface:-?})"
    for i in $(ifconfig -l | tr ' ' '\n' | grep -E '^(utun|tun|ipsec)'); do
        ip=$(ifconfig "$i" 2>/dev/null | awk '/inet /{print $2; exit}')
        case "$ip" in 10.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*) vpn="$ip ($i)"; break;; esac
    done
    echo "VPN:    ${vpn:-disconnected}"
    tgt=$(cat ~/.config/sketchybar/target 2>/dev/null)
    echo "TARGET: ${tgt:-no target}"
}

# recargar la config de zsh rapido
alias reload='source ~/.zshrc && echo "zsh recargado"'

# ============ VPN con openvpn directo (binario standalone, sin brew) ============
OVPN_BIN="$HOME/.local/bin/openvpn"   # el CLI que extrajimos de Tunnelblick
OVPN_DIR="$HOME/vpn"                  # aqui van todos tus .ovpn
OVPN_DEFAULT="htb"                    # cual usar si no pasas nombre
OVPN_PID="/tmp/ovpn.pid"
OVPN_LOG="/tmp/ovpn.log"

# detecta la IP del tunel (10.x / 172.16-31.x) o vacio
_vpn_ip() {
  local ifc ip
  for ifc in $(ifconfig -l | tr ' ' '\n' | grep -E '^(utun|tun)'); do
    ip=$(ifconfig "$ifc" 2>/dev/null | awk '/inet /{print $2}')
    case "$ip" in 10.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*) echo "$ip"; return 0;; esac
  done
  return 1
}

# lista los .ovpn disponibles (sin ruta ni extension)
vpnlist() {
  local f found=0
  for f in "$OVPN_DIR"/*.ovpn(N); do found=1; echo "  ${f:t:r}"; done
  [ "$found" = 1 ] || echo "  (no hay .ovpn en $OVPN_DIR)"
}

# vpnup [nombre]  -> levanta ~/vpn/<nombre>.ovpn (o el default)
vpnup() {
  local name="${1:-$OVPN_DEFAULT}"
  local cfg="$OVPN_DIR/$name.ovpn"
  [ -f "$cfg" ] || { echo "no existe $cfg. disponibles:"; vpnlist; return 1; }
  pgrep -f "$OVPN_BIN --config" >/dev/null && { echo "ya hay un openvpn arriba (vpndown primero)"; return 1; }
  echo "levantando VPN '$name' (pide tu contrasena para crear el tun)..."
  sudo "$OVPN_BIN" --config "$cfg" --cd "$OVPN_DIR" --daemon --writepid "$OVPN_PID" --log "$OVPN_LOG"
  echo -n "conectando"
  local ip
  for i in {1..25}; do
    ip=$(_vpn_ip) && { echo " -> $ip"; command -v sketchybar >/dev/null && sketchybar --trigger vpn_change; echo "VPN '$name' arriba: $ip"; return 0; }
    echo -n "."; sleep 1
  done
  echo " timeout. revisa: tail $OVPN_LOG"; command -v sketchybar >/dev/null && sketchybar --trigger vpn_change; return 1
}

vpndown() {
  if [ -f "$OVPN_PID" ]; then sudo kill "$(cat "$OVPN_PID")" 2>/dev/null; sudo rm -f "$OVPN_PID"; fi
  sudo pkill -f "$OVPN_BIN --config" 2>/dev/null
  sleep 1; command -v sketchybar >/dev/null && sketchybar --trigger vpn_change
  echo "VPN abajo"
}

vpnstatus() {
  local ip; ip=$(_vpn_ip) && echo "CONECTADO: $ip" || echo "desconectado"
}

# tab-completion: 'vpnup <TAB>' lista los .ovpn de ~/vpn
_vpnup_complete() { local -a n; n=("$OVPN_DIR"/*.ovpn(N:t:r)); compadd -- "${n[@]}"; }
compdef _vpnup_complete vpnup 2>/dev/null

# y: abre yazi (file browser); al salir, deja la shell en la carpeta navegada
y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# wm: reinicia el gestor de ventanas + la barra (vía LaunchAgents, recarga config)
alias wm='launchctl kickstart -k gui/$(id -u)/com.amnesia.aerospace 2>/dev/null; launchctl kickstart -k gui/$(id -u)/com.amnesia.sketchybar 2>/dev/null; echo "AeroSpace + sketchybar reiniciados"'
