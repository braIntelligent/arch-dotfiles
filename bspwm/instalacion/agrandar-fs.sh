#!/bin/sh
# Extiende la particion raiz (nvme0n1p3) y el ext4 al espacio nuevo del disco.
# Correr DENTRO de la VM, con sudo, despues de agrandar el vdisk en VMware.
# ext4 se agranda en caliente, montado; no se pierde nada.
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }
set -e

disk=/dev/nvme0n1
part=/dev/nvme0n1p3

echo "=== layout actual ==="
lsblk "$disk"
echo

# p3 tiene que ser la ultima particion (su numero = cantidad de particiones)
last=$(lsblk -rno NAME "$disk" | grep -c "nvme0n1p")
if [ "$last" != "3" ]; then
    echo "OJO: hay $last particiones; este script asume que p3 es la ultima. Aborto."
    exit 1
fi

command -v growpart >/dev/null || pacman -S --needed --noconfirm cloud-guest-utils

echo "=== extendiendo particion p3 ==="
growpart "$disk" 3

echo "=== extendiendo el sistema de archivos ext4 ==="
resize2fs "$part"

echo
echo "=== resultado ==="
df -h /
