#!/bin/sh
# VPN de HTB (OpenVPN). Elige un archivo .ovpn de ~/vpn y conecta en una ventana
# propia, donde pide la clave de sudo y deja ver el registro. Cerrar esa ventana
# (o Ctrl+C en ella) corta la VPN. Si ya hay una activa, la trae al frente.
dir="$HOME/vpn"; mkdir -p "$dir"
if hyprctl clients -j | jq -e '.[] | select(.class == "vpn")' >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ window = "class:^vpn$" })' >/dev/null
    exit 0
fi
command -v openvpn >/dev/null || { notify-send -u critical "VPN" "Falta openvpn: sudo pacman -S openvpn"; exit 1; }
n=$(ls "$dir"/*.ovpn 2>/dev/null | wc -l)
[ "$n" -gt 0 ] || { notify-send "VPN" "Deja tu archivo .ovpn de HTB en ~/vpn"; exit 0; }
if [ "$n" = 1 ]; then
    f=$(ls "$dir"/*.ovpn)
else
    f=$(ls "$dir"/*.ovpn | sed 's|.*/||' \
        | rofi -dmenu -kb-cancel "Escape,Super+space,Super+Shift+O" -i -p "VPN" \
               -theme "$HOME/.config/rofi/list.rasi" -theme-str 'listview { lines: 6; }')
    [ -n "$f" ] || exit 0
    f="$dir/$f"
fi
[ -f "$HOME/.config/hypr/es-vm" ] && export LIBGL_ALWAYS_SOFTWARE=1
exec kitty --class vpn --title "VPN: $(basename "$f")" -e sudo openvpn --config "$f"
