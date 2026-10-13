#!/bin/sh
# Power menu horizontal. Indices: 0 lock 1 suspend 2 logout 3 reboot 4 apagar
# Apagar/reiniciar/suspender usan sudo (ver instalacion/power-nopasswd.sh para el permiso).
S="$HOME/.config/bspwm/scripts"
i=$(printf '  Bloquear\n  Suspender\n  Cerrar\n  Reiniciar\n  Apagar\n' \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+E" -format i -i -p "Adios $USER" \
           -mesg "Encendido: $(uptime -p | sed 's/^up //')" \
           -theme "$HOME/.config/rofi/row.rasi" \
           -theme-str 'listview { columns: 5; } textbox-prompt-colon { str: ""; }')
# -no-click-to-exit: al venir de un click, este rofi recibe el "soltar" del boton
# fuera de su ventana y se cerraria solo.
confirm() { [ "$(printf 'No\nSi\n' | rofi -dmenu -no-click-to-exit -i -p "$1" -theme "$HOME/.config/rofi/confirm.rasi")" = Si ]; }
case "$i" in
    0) exec "$S/lock.sh" ;;
    1) sudo systemctl suspend ;;
    2) confirm "Cerrar sesion?" && bspc quit ;;
    3) confirm "Reiniciar?"     && sudo systemctl reboot ;;
    4) confirm "Apagar?"        && sudo systemctl poweroff ;;
esac
