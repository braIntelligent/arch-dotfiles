#!/bin/sh
# Hace que el tema, el fondo y el padding de la barra persistan al reiniciar.
# Correr UNA vez en la VM.
rc="$HOME/.config/bspwm/bspwmrc"
cp "$rc" "$rc.bak"
sed -i '/feh --bg-fill .*Pictures\/fondo.jpg/d' "$rc"
grep -q 'top_padding 48' "$rc" || echo 'bspc config top_padding 48' >> "$rc"
grep -q 'aplicar-fondo.sh' "$rc" || echo '~/.config/bspwm/scripts/aplicar-fondo.sh &' >> "$rc"
grep -q 'set-theme.sh' "$rc" || echo '~/.config/bspwm/scripts/set-theme.sh "$(cat ~/.cache/theme 2>/dev/null || echo tokyonight)" &' >> "$rc"
echo "listo: bspwmrc actualizado (respaldo en $rc.bak)"
