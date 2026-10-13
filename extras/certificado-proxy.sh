#!/bin/sh
# Hace que el navegador (qutebrowser) confie en el certificado de un proxy como
# Caido o Burp, para poder interceptar paginas HTTPS sin avisos.
# uso: sh extras/certificado-proxy.sh ca.crt [nombre]
# El certificado de Caido se baja desde su interfaz: http://127.0.0.1:8080/ca.crt
# Para quitarlo: certutil -d sql:$HOME/.pki/nssdb -D -n nombre
set -eu
[ $# -ge 1 ] && [ -f "$1" ] || { echo "uso: sh $0 ca.crt [nombre]"; exit 1; }
nombre=${2:-proxy}
db="$HOME/.pki/nssdb"
command -v certutil >/dev/null || sudo pacman -S --needed --noconfirm nss
[ -f "$db/cert9.db" ] || { mkdir -p "$db"; certutil -d "sql:$db" -N --empty-password; }
certutil -d "sql:$db" -D -n "$nombre" 2>/dev/null || true
certutil -d "sql:$db" -A -t "C,," -n "$nombre" -i "$1"
echo "listo: certificado \"$nombre\" agregado. Reinicia qutebrowser."
