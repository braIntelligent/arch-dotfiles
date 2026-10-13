#!/bin/sh
# Instantaneas del sistema con snapper (el disco tiene que ser btrfs).
# Deja una foto del sistema antes y despues de cada instalacion o actualizacion
# con pacman, y guarda las ultimas 10. No incluye /home: es para deshacer cambios
# del sistema, no un respaldo de tus archivos.
# Correr con sudo:  sudo sh extras/instantaneas.sh
#
# Para usarlas:
#   sudo snapper list                   ver las instantaneas (van de a pares: pre y post)
#   sudo snapper status 12..13          que archivos cambio esa actualizacion
#   sudo snapper undochange 12..13      deshacer esos cambios
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }
set -eu
[ "$(findmnt -no FSTYPE /)" = btrfs ] || { echo "la raiz no es btrfs: snapper no sirve aqui"; exit 1; }

pacman -S --needed --noconfirm snapper snap-pac
if ! snapper list-configs 2>/dev/null | grep -q '^root '; then
    snapper -c root create-config /
fi
# sin fotos por horario (llenan el disco): solo las de pacman, y se guardan 10
snapper -c root set-config TIMELINE_CREATE=no NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5
systemctl enable --now snapper-cleanup.timer >/dev/null 2>&1
snapper -c root create -d "estado inicial"
echo "listo: desde ahora pacman deja una instantanea antes y despues de cada cambio"
snapper list
