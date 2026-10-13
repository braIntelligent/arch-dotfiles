#!/bin/sh
# Caido (proxy para auditar web): la misma orden lo enciende y lo apaga.
# Encendido, escucha en 127.0.0.1:8080 y abre su interfaz en el navegador. Para
# pasar el trafico del navegador por el: en qutebrowser, las teclas ,p
if pkill -x caido-cli; then
    notify-send "Caido apagado"
    exit 0
fi
command -v caido-cli >/dev/null || { notify-send -u critical "Caido" "No esta instalado: sh extras/instalar-caido.sh del repositorio"; exit 1; }
# --allow-guests: se puede usar sin crear una cuenta de Caido
setsid caido-cli --no-open --allow-guests >/dev/null 2>&1 &
sleep 2
notify-send "Caido encendido" "Proxy e interfaz en 127.0.0.1:8080"
exec qutebrowser "http://127.0.0.1:8080"
