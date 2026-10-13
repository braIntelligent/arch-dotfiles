#!/bin/sh
# Agrega el repositorio BlackArch a pacman, verificando la firma del keyring.
# Igual que el strap.sh oficial, pero trae las llaves del firmante por HTTPS
# (API web de keyserver.ubuntu.com) en vez de por el protocolo keyserver,
# que la VM no alcanza. Correr con sudo:  sudo sh instalar-blackarch.sh
set -e
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }

ARCH=$(uname -m)
REPO="https://blackarch.org/blackarch/blackarch/os/$ARCH"
SIGNERS="8F9A9793CB8591147C2EC70566E0CDBD1E01F333
A0917C4147A37007CB54C1CFD295AA940EFDDF62
4345771566D76038C7FEB43863EC0ADBEA87E4E3
F9A6E68A711354D84A9B91637533BAFE69A25079"

tmp=$(mktemp -d)
cd "$tmp"
trap 'gpgconf --kill all 2>/dev/null; rm -rf "$tmp"' EXIT

echo "[+] Bajando base del repo y keyring..."
curl -sfL -O "$REPO/blackarch.db"
pkg=$(bsdtar -xOf blackarch.db 'blackarch-keyring-*/desc' 2>/dev/null |
      awk '/^%FILENAME%$/ { getline; print; exit }')
[ -n "$pkg" ] || { echo "no encontre blackarch-keyring en la base"; exit 1; }
curl -sfL -O "$REPO/$pkg"
curl -sfL -O "$REPO/$pkg.sig"

echo "[+] Importando llaves del firmante por HTTPS..."
export GNUPGHOME="$tmp/gnupg"
mkdir -m 700 "$GNUPGHOME"
for fpr in $SIGNERS; do
  curl -sfL "https://keyserver.ubuntu.com/pks/lookup?op=get&options=mr&search=0x$fpr" \
    | gpg --quiet --import 2>/dev/null || true
done

echo "[+] Verificando la firma del keyring..."
status=$(gpg --status-fd 1 --verify "$pkg.sig" "$pkg" 2>/dev/null || true)
signer=$(printf '%s\n' "$status" | awk '$2 == "VALIDSIG" { print $NF }')
[ -n "$signer" ] || { echo "FIRMA INVALIDA o sin llave; aborto"; exit 1; }
echo "$SIGNERS" | grep -qx "$signer" || { echo "firmado por llave no confiable $signer; aborto"; exit 1; }
echo "    OK, firmado por $signer"
gpgconf --kill all 2>/dev/null; unset GNUPGHOME

echo "[+] Instalando keyring..."
mkdir pkgx
bsdtar -xf "$pkg" -C pkgx usr/share/pacman/keyrings
cp pkgx/usr/share/pacman/keyrings/* /usr/share/pacman/keyrings/
pacman-key --init
pacman-key --populate blackarch
pacman -U --noconfirm --overwrite '/usr/share/pacman/keyrings/blackarch*' "$pkg"

echo "[+] Configurando pacman..."
curl -sfL "https://blackarch.org/blackarch-mirrorlist" -o /etc/pacman.d/blackarch-mirrorlist
if ! grep -q '\[blackarch\]' /etc/pacman.conf; then
  sed -i '/blackarch/{N;d}' /etc/pacman.conf
  printf '\n[blackarch]\nInclude = /etc/pacman.d/blackarch-mirrorlist\n' >> /etc/pacman.conf
fi

pacman -Syu --noconfirm
pacman -S --noconfirm --needed blackarch-mirrorlist
echo "[+] Repo BlackArch listo"
