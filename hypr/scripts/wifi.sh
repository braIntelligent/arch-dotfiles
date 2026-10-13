#!/bin/sh
# Menu de wifi: elegir una red y conectarse. Las redes ya usadas conectan directo;
# las nuevas piden la clave.
L="$HOME/.config/rofi/list.rasi"
K="Escape,Super+space,Super+Shift+U"
estado=$(nmcli -t -f WIFI radio)
if [ "$estado" != enabled ]; then
    o=$(printf '  Encender el wifi\n' | rofi -dmenu -kb-cancel "$K" -i -p "Wifi apagado" -theme "$L" -theme-str 'listview { lines: 1; }')
    [ -n "$o" ] && nmcli radio wifi on
    exit 0
fi

notify-send -a wifi -t 1500 "Buscando redes..."
redes=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan yes 2>/dev/null \
    | awk -F: '$4 != "" && !visto[$4]++ {
        printf "%s  %3s%%  %s  %s\n", ($1 == "*" ? "" : " "), $2, ($3 == "" || $3 == "--" ? "" : ""), $4 }')
o=$(printf '%s\n  Apagar el wifi\n' "$redes" \
    | rofi -dmenu -kb-cancel "$K" -i -p "Wifi" -theme "$L" -theme-str 'window { width: 620px; } listview { lines: 12; }')
[ -n "$o" ] || exit 0
case "$o" in *"Apagar el wifi") nmcli radio wifi off; exit 0 ;; esac

# el nombre de la red es lo que sigue al candado (puede traer espacios)
ssid=$(printf '%s\n' "$o" | sed -E 's/^.*(|)  //')
[ -n "$ssid" ] || exit 0

if nmcli -t -f NAME connection show | grep -qxF "$ssid"; then
    r=$(nmcli connection up id "$ssid" 2>&1)
elif printf '%s' "$o" | grep -q ''; then
    r=$(nmcli device wifi connect "$ssid" 2>&1)
else
    clave=$(rofi -dmenu -password -kb-cancel "$K" -p "Clave de $ssid" -theme "$L" -theme-str 'listview { lines: 0; }')
    [ -n "$clave" ] || exit 0
    r=$(nmcli device wifi connect "$ssid" password "$clave" 2>&1)
fi
if [ $? = 0 ]; then
    notify-send -a wifi "  Conectado a $ssid"
else
    notify-send -u critical "Wifi" "No se pudo conectar a $ssid: $(printf '%s' "$r" | tail -n1)"
fi
