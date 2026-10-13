#!/bin/sh
# Cortafuegos con nftables: bloquea todo lo que entra, salvo lo indicado abajo.
# Lo que sale no se toca. Correr con sudo; se puede repetir.
#     sudo sh extras/cortafuegos.sh           lo instala y lo activa
#     sudo sh extras/cortafuegos.sh quitar    lo desactiva (deja pasar todo)
#
# Entra:  - las respuestas a lo que este equipo pidio
#         - todo lo que llegue por una VPN (tun0, tun1...): ahi van los listeners de
#           las shells inversas y los servidores para pasar archivos en HTB
#         - KDE Connect (1714-1764) y LocalSend (53317), para el telefono
#         - ping
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }
set -eu

if [ "${1:-}" = quitar ]; then
    systemctl disable --now nftables.service
    nft flush ruleset
    echo "listo: cortafuegos desactivado"
    exit 0
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
cat > "$tmp" <<'EOT'
#!/usr/bin/nft -f
# Instalado por extras/cortafuegos.sh de arch-dotfiles
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;

        ct state established,related accept
        ct state invalid drop
        iifname "lo" accept
        meta l4proto { icmp, ipv6-icmp } accept
        udp dport 546 accept comment "DHCPv6"

        iifname "tun*" accept comment "VPN: listeners de HTB"

        tcp dport 1714-1764 accept comment "KDE Connect"
        udp dport 1714-1764 accept comment "KDE Connect"
        tcp dport 53317 accept comment "LocalSend"
        udp dport 53317 accept comment "LocalSend"
    }
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
}
EOT
nft -c -f "$tmp"        # si las reglas tienen un error, se detiene aqui sin tocar nada

[ -f /etc/nftables.conf ] && ! cmp -s "$tmp" /etc/nftables.conf \
    && cp /etc/nftables.conf "/etc/nftables.conf.antes-$(date +%Y%m%d-%H%M%S)"
install -m644 "$tmp" /etc/nftables.conf
systemctl enable nftables.service >/dev/null 2>&1
systemctl restart nftables.service
echo "listo: cortafuegos activo. Para ver las reglas: sudo nft list ruleset"
