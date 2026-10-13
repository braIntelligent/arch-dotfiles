#!/bin/sh
# Reintenta los 6 que fallaron, guardando el error exacto de cada uno.
# Con sudo:  sudo sh reintentar-6.sh
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }

echo "=== espacio en disco ==="
df -h / | tail -1
echo

pacman -Sy --noconfirm >/dev/null
log=/tmp/reintento.log
: > "$log"

for p in nuclei hashid hash-identifier seclists netexec smbmap; do
  echo "######## $p ########" | tee -a "$log"
  if pacman -S --needed --noconfirm "$p" >>"$log" 2>&1; then
    echo "   OK $p"
  else
    echo "   FALLO $p -> ultimas lineas:"
    tail -n 6 "$log" | sed 's/^/      /'
  fi
done
echo
echo "log completo en $log"
