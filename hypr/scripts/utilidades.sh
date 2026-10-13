#!/bin/sh
# Menu de utilidades: todo lo que no tiene tecla propia, en un solo lugar.
S="$HOME/.config/hypr/scripts"
o=$(printf '  Wifi\n  Bluetooth\n  VPN\n  Proxy (Caido)\n  Ventanas\n  Calculadora\n  Color\n  Musica\n  Anotar una captura\n  Actualizar el sistema\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+Shift+U" -i -p "Utilidades" \
           -theme "$HOME/.config/rofi/list.rasi" -theme-str 'window { width: 460px; } listview { lines: 10; }')
case "$o" in
    *Wifi)          exec "$S/wifi.sh" ;;
    *Bluetooth)     exec "$S/bluetooth.sh" ;;
    *VPN)           exec "$S/vpn.sh" ;;
    *Proxy*)        exec "$S/caido.sh" ;;
    *Ventanas)      exec rofi -show window -theme "$HOME/.config/rofi/list.rasi" -theme-str 'window { width: 760px; }' ;;
    *Calculadora)   exec "$S/calc.sh" ;;
    *Color)         exec "$S/color.sh" ;;
    *Musica)        exec "$S/musica.sh" ;;
    *Anotar*)       exec "$S/anotar.sh" ;;
    *Actualizar*)   exec "$S/actualizar.sh" ;;
esac
