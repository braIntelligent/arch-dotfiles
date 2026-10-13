#!/bin/sh
# Permite a los usuarios del grupo wheel apagar/reiniciar/suspender sin password.
# Necesario con startx (sin display manager), donde systemctl poweroff suele fallar.
# Correr con sudo:  sudo sh power-nopasswd.sh
[ "$(id -u)" = 0 ] || { echo "corre con: sudo sh $0"; exit 1; }
f=/etc/sudoers.d/10-power
cat > "$f" <<'EOT'
%wheel ALL=(root) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend
EOT
chmod 440 "$f"
visudo -cf "$f" && echo "listo: permiso de energia configurado" || { rm -f "$f"; echo "error de sintaxis, revertido"; }
