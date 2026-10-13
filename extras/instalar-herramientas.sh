#!/bin/sh
# Herramientas de red y pentesting para el lab (Arch ARM + repo BlackArch).
# Correr DESPUES de instalar-blackarch.sh. Con sudo:  sudo sh instalar-herramientas.sh
# Instala paquete por paquete: lo que no exista para aarch64 se salta y se reporta.
# No incluye metasploit ni john: no hay build aarch64 en estos repos.
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }

PKGS="nmap masscan rustscan openbsd-netcat socat tcpdump bind whois traceroute \
net-tools arp-scan openvpn wireguard-tools proxychains-ng tor bettercap \
rlwrap jq tmux fzf sshpass wget python-pipx \
gobuster nikto sqlmap wpscan zaproxy ffuf feroxbuster dirsearch wfuzz whatweb nuclei \
hydra medusa hashcat crunch hashid hash-identifier cewl seclists \
impacket netexec smbclient smbmap enum4linux-ng evil-winrm kerbrute chisel ligolo-ng peass \
wireshark-qt burpsuite bloodhound"

pacman -Sy --noconfirm >/dev/null

fallidos=""
for p in $PKGS; do
  if pacman -Qq "$p" >/dev/null 2>&1; then
    continue   # ya instalado
  fi
  echo "==> $p"
  if ! pacman -S --needed --noconfirm "$p"; then
    fallidos="$fallidos $p"
  fi
done

echo
echo "================ resumen ================"
if [ -n "$fallidos" ]; then
  echo "no se pudieron instalar (sin build aarch64 o dependencia faltante):"
  for f in $fallidos; do echo "   - $f"; done
else
  echo "todo instalado"
fi
