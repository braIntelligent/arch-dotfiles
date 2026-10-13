#!/bin/sh
# Limita la carga de la bateria del Mac (Asahi) al 80 % para alargar su vida util.
# El limite se pierde al reiniciar, asi que ademas deja una regla de udev que lo
# vuelve a poner en cada arranque.
# uso: sudo sh limite-carga.sh [80|100]     sin argumento: 80; con 100 se quita el limite
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }
set -e

lim=${1:-80}
case "$lim" in
    80|100) ;;
    *) echo "uso: sudo sh $0 [80|100]"; exit 1 ;;
esac

attr=/sys/class/power_supply/macsmc-battery/charge_control_end_threshold
[ -e "$attr" ] || { echo "este equipo no tiene limite de carga ($attr no existe)"; exit 1; }

regla=/etc/udev/rules.d/90-limite-carga.rules
if [ "$lim" = 100 ]; then
    rm -f "$regla"
else
    echo 'SUBSYSTEM=="power_supply", KERNEL=="macsmc-battery", ATTR{charge_control_end_threshold}="80"' > "$regla"
fi
echo "$lim" > "$attr"
# la barra muestra el limite como 100 %: se rehace con el valor nuevo
u=${SUDO_USER:-}
if [ -n "$u" ]; then
    uh=$(getent passwd "$u" | cut -d: -f6)
    tema=$(cat "$uh/.cache/theme" 2>/dev/null || true)
    [ -x "$uh/.config/hypr/scripts/set-theme.sh" ] && [ -n "$tema" ] \
        && sudo -u "$u" -H "$uh/.config/hypr/scripts/set-theme.sh" "$tema" >/dev/null 2>&1 || true
fi
echo "listo: limite de carga en $(cat "$attr") %"
