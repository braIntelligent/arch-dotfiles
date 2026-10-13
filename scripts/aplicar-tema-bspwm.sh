#!/bin/sh
# Ajusta el bspwmrc existente: 5 escritorios y bordes Tokyo Night.
# Se puede correr mas de una vez sin duplicar nada.
rc="$HOME/.config/bspwm/bspwmrc"
cp "$rc" "$rc.bak"

sed -i 's/^bspc monitor -d.*/bspc monitor -d 1 2 3 4 5/' "$rc"
sed -i '/^# tema tokyo night$/,/^# fin tema$/d' "$rc"

cat >> "$rc" <<'EOF'
# tema tokyo night
bspc config border_width 2
bspc config focused_border_color "#7aa2f7"
bspc config normal_border_color "#24283b"
bspc config active_border_color "#565f89"
bspc config presel_feedback_color "#bb9af7"
# fin tema
EOF

bspc wm -r
echo "listo: respaldo en $rc.bak"
